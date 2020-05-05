/// Completes initialisation for Chatterbox
/// This script should be called after chatterbox_init_start() and chatterbox_init_add()
/// 
/// This script goes through a number of steps to parse Yarn source files to prepare them for internal use.
/// 1) Load the source file into a buffer, and break it down into individual nodes
/// 2) Perform bulk findreplace tasks (via init_permit_script())
/// 2) Get the text body of the node, and break it down into individual lines and substrings
///
/// Once we have the body broken down into substrings, we can start to store "instructions".
/// Instructions represent the logic that Chatterbox will execute to work out what text needs to be displayed.
/// Instructions are all stored in a single enormous global list - this helps with redirects and options.
///
/// 3) For each substring, detect whether it's a) text or a shortcut b) a redirect or option c) an action
/// 3a) If a substring is text or shortcut, store it as a simple instruction
/// 3b) If a substring is a redirect or option, work out where it's pointing and store that instruction
/// 3c) If a substring is an action: tokenise, build a syntax tree, add an instruction that holds the syntax tree
/// 4) Add a STOP instruction to the end of the node's instructions to catch any weird behaviour
///
/// "Actions" give Chatterbox an enormous amount of flexibility!
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax().
/// 
/// Once this script has been run, Chatterbox is ready for use!

var _timer = get_timer();

if ( !variable_global_exists("__chatterbox_init_complete" ) )
{
    __chatterbox_error("chatterbox_init_end() should be called after chatterbox_init_start()");
    exit;
}

__chatterbox_trace("Completing initialisation");

var _body_substring_list = ds_list_create();

//Iterate over every source file added
var _font_count = ds_map_size(global.__chatterbox_file_data);
var _name = ds_map_find_first(global.__chatterbox_file_data);
repeat(_font_count)
{
    var _font_data = global.__chatterbox_file_data[? _name ];
    __chatterbox_trace("  Processing file \"" + _name + "\"");
    
    var _filename  = _font_data[__CHATTERBOX_FILE.FILENAME];
    var _file_type = _font_data[__CHATTERBOX_FILE.FORMAT  ];
    
    
    
    ds_list_add(global.__chatterbox_vm, _filename);
    var _instruction_file_offset = ds_list_size(global.__chatterbox_vm);
    global.__chatterbox_goto[? _filename] = _instruction_file_offset;
    if (CHATTERBOX_DEBUG_PARSER) __chatterbox_trace("  File instruction offset is " + string(_instruction_file_offset));
    
    
    
    var _node_list = undefined;
    
    var _buffer = buffer_load(global.__chatterbox_font_directory + _filename);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    
    switch(_file_type)
    {
        case __CHATTERBOX_FORMAT.YARN:
            #region Parse .yarn file into a JSON
            
            var _node_list = ds_list_create();
            
            _string = string_replace_all(_string, "\n\r", "\n");
            _string = string_replace_all(_string, "\r\n", "\n");
            _string = string_replace_all(_string, "\r"  , "\n");
            _string += "\n";
            
            var _body      = "";
            var _title     = "";
            var _in_header = true;
            
            var _pos = string_pos("\n", _string);
            while(_pos > 0)
            {
                var _substring = string_copy(_string, 1, _pos-1);
                _string        = string_delete(_string, 1, _pos);
                _pos           = string_pos("\n", _string);
                
                if (_in_header)
                {
                    if (string_copy(_substring, 1, 6) == "title:")
                    {
                        _title = string_delete(_substring, 1, 6);
                        _title = __chatterbox_remove_whitespace(__chatterbox_remove_whitespace(_title, true), false);
                    }
                    
                    if (string_copy(_substring, 1, 3) == "---")
                    {
                        _in_header = false;
                        _body = "";
                    }
                }
                else
                {
                    if (string_copy(_substring, 1, 3) == "===")
                    {
                        var _map = ds_map_create();
                        _map[? "body" ] = _body;
                        _map[? "title"] = _title;
                        ds_list_add(_node_list, _map);
                        ds_list_mark_as_map(_node_list, ds_list_size(_node_list)-1);
                        
                        _in_header = true;
                        _body      = "";
                        _title     = "";
                    }
                    else
                    {
                        _body += _substring + "\n";
                    }
                }
            }
            
            #endregion
        break;
        
        case __CHATTERBOX_FORMAT.JSON:
            #region Read and verify JSON
            
            var _yarn_json = json_decode(_string);
            
            //Test for JSON made by the standard Yarn editor
            var _node_list = _yarn_json[? "default" ];
            if (_node_list != undefined) __chatterbox_trace("    File was made in standard Yarn editor");
            
            //Test for JSON made by Jacquard
            if (_node_list == undefined)
            {
                var _node_list = _yarn_json[? "nodes" ];
                if (_node_list != undefined) __chatterbox_trace("    File was made by Jacquard");
            }
            
            //Divorce the node list from the JSON
            _yarn_json[? "default" ] = undefined;
            _yarn_json[? "nodes"   ] = undefined;
            ds_map_destroy(_yarn_json);
            
            #endregion
        break;
    }
    
    //If both of these fail, it's some wacky JSON that we don't recognise
    if (_node_list == undefined)
    {
        __chatterbox_error("Format for \"" + _name + "\" is unrecognised.\nThis source file will be ignored.");
        _name = ds_map_find_next(global.__chatterbox_file_data, _name);
        continue;
    }
    
    var _node_count = ds_list_size(_node_list);
    
    if (CHATTERBOX_DEBUG_TITLES)
    {
        #region Debug output that displays all the nodes in a file
        
        if (_node_count > 0)
        {
            __chatterbox_trace("    Found " + string(_node_count) + " nodes/titles:");
            var _string = "      ";
            
            var _i = 0;
            for(var _node = 0; _node < _node_count; _node++)
            {
                var _node_map = _node_list[| _node];
                
                _string += "\"" + _node_map[? "title" ] + "\"";
                if (_node < _node_count-1)
                {
                    _string += ", ";
                    _i++;
                    if (_i >= 10)
                    {
                        __chatterbox_trace(_string);
                        _string = "      ";
                        _i = 0;
                    }
                }
            }
            if (_i > 0) __chatterbox_trace(_string);
        }
        
        #endregion
    }
    
    //Iterate over all the nodes we found in this source file
    for(var _node = 0; _node < _node_count; _node++)
    {
        var _node_map = _node_list[| _node];
        var _title = _node_map[? "title"];
        var _body  = _node_map[? "body" ];
        
        //Prepare body string for parsing
        _body = string_replace_all(_body, "\n\r", "\n");
        _body = string_replace_all(_body, "\r\n", "\n");
        _body = string_replace_all(_body, "\r"  , "\n");
        
        //Perform find-replace
        var _size = ds_list_size(global.__chatterbox_findreplace_old_string);
        for(var _i = 0; _i < _size; _i++)
        {
            _body = string_replace_all(_body,
                                       global.__chatterbox_findreplace_old_string[| _i ],
                                       global.__chatterbox_findreplace_new_string[| _i ]);
        }
        
        if (CHATTERBOX_DEBUG_PARSER)
        {
            __chatterbox_trace("    Processing \"" + string(_title) + "\" = \"" + string_replace_all(string(_body), "\n", "\\n") + "\"");
        }
        _body += "\n";
        
        ds_list_add(global.__chatterbox_vm, _filename + CHATTERBOX_FILENAME_SEPARATOR + _title);
        var _instruction_node_offset = ds_list_size(global.__chatterbox_vm);
        global.__chatterbox_goto[? _filename + CHATTERBOX_FILENAME_SEPARATOR + _title ] = _instruction_node_offset;
        if (CHATTERBOX_DEBUG_PARSER) __chatterbox_trace("    Node instruction offset is " + string(_instruction_node_offset));
        
        
        
        #region Break down body into substring
        
        ds_list_clear(_body_substring_list);
        
        var _body_byte_length = string_byte_length(_body);
        var _body_buffer = buffer_create(_body_byte_length+1, buffer_fixed, 1);
        buffer_poke(_buffer, 0, buffer_string, _body);
        
        var _line          = 0;
        var _first_on_line = true;
        var _indent        = undefined;
        var _newline       = false;
        var _cache         = "";
        var _cache_type    = "text";
        var _prev_value    = 0;
        var _value         = 0;
        var _next_value    = buffer_read(_body_buffer, buffer_u8);
        
        repeat(_body_byte_length)
        {
            _prev_value = _value;
            _value      = _next_value;
            _next_value = buffer_read(_body_buffer, buffer_u8);
            
            var _write_cache = true;
            var _pop_cache   = false;
            
            if ((_value == ord("\n")) || (_value == ord("\r")))
            {
                _newline     = true;
                _pop_cache   = true;
                _write_cache = false;
            }
            else if (_value == ord(CHATTERBOX_OPTION_OPEN_DELIMITER))
            {
                if (_next_value == ord(CHATTERBOX_OPTION_OPEN_DELIMITER))
                {
                    _write_cache = false;
                    _pop_cache   = true;
                }
                else if (_prev_value == ord(CHATTERBOX_OPTION_OPEN_DELIMITER))
                {
                    _write_cache = false;
                    _cache_type = "option";
                }
            }
            else if (_value == ord(CHATTERBOX_OPTION_CLOSE_DELIMITER))
            {
                if (_next_value == ord(CHATTERBOX_OPTION_CLOSE_DELIMITER))
                {
                    _write_cache = false;
                    _pop_cache   = true;
                }
                else if (_prev_value == ord(CHATTERBOX_OPTION_CLOSE_DELIMITER))
                {
                    _write_cache = false;
                }
            }
            else if (_value == ord(CHATTERBOX_ACTION_OPEN_DELIMITER))
            {
                if (_next_value == ord(CHATTERBOX_ACTION_OPEN_DELIMITER))
                {
                    _write_cache = false;
                    _pop_cache   = true;
                }
                else if (_prev_value == ord(CHATTERBOX_ACTION_OPEN_DELIMITER))
                {
                    _write_cache = false;
                    _cache_type = "action";
                }
            }
            else if (_value == ord(CHATTERBOX_ACTION_CLOSE_DELIMITER))
            {
                if (_next_value == ord(CHATTERBOX_ACTION_CLOSE_DELIMITER))
                {
                    _write_cache = false;
                    _pop_cache   = true;
                }
                else if (_prev_value == ord(CHATTERBOX_ACTION_CLOSE_DELIMITER))
                {
                    _write_cache = false;
                }
            }
            
            if (_write_cache) _cache += chr(_value);
            
            if (_pop_cache)
            {
                if (_first_on_line)
                {
                    _cache = __chatterbox_remove_whitespace(_cache, true);
                    _indent = global.__chatterbox_indent_size;
                }
                
                if (_cache != "") ds_list_add(_body_substring_list, [_cache, _cache_type, _line, _indent]);
                _cache = "";
                _cache_type = "text";
                
                if (_newline)
                {
                    _newline = false;
                    ++_line;
                    _first_on_line = true;
                    _indent = undefined;
                }
                else
                {
                    _first_on_line = false;
                }
            }
        }
        
        buffer_delete(_body_buffer);
        
        #endregion
        
        
        
        global.__chatterbox_insert_pos = ds_list_size(global.__chatterbox_vm);
        var _branch_stack = ds_list_create();
        var _previous_line = -1;
        var _body_substring_count = ds_list_size(_body_substring_list);
        for(var _sub = 0; _sub < _body_substring_count; _sub++)
        {
            var _substring_array  = _body_substring_list[| _sub];
            var _string           = _substring_array[0];
            var _substring_type   = _substring_array[1];
            var _substring_line   = _substring_array[2];
            var _substring_indent = _substring_array[3];
            
            if (_substring_line > _previous_line)
            {
                var _branch_top = _branch_stack[| ds_list_size(_branch_stack)-1];
                while (is_array(_branch_top) && (_substring_indent <= _branch_top[2]))
                {
                    ds_list_delete(_branch_stack, ds_list_size(_branch_stack)-1);
                    if (_branch_top[3]) __chatterbox_new_instruction(_branch_top[0], _branch_top[2]);
                    _branch_top = _branch_stack[| ds_list_size(_branch_stack)-1];
                }
            }
            
            if (_substring_type == "option")
            {
                #region [[option]]
            
                var _pos = string_pos("|", _string);
                if (_pos < 1)
                {
                    __chatterbox_new_instruction(__CHATTERBOX_VM_REDIRECT, _substring_indent,
                                                 [__chatterbox_remove_whitespace(__chatterbox_remove_whitespace(_string, true), false)]);
                }
                else
                {
                    __chatterbox_new_instruction(__CHATTERBOX_VM_OPTION, _substring_indent,
                                                 [__chatterbox_remove_whitespace(string_copy(_string, 1, _pos-1), false),
                                                  __chatterbox_remove_whitespace(string_delete(_string, 1, _pos), true)]);
                }
            
                #endregion
            }
            else if (_substring_type == "action")
            {
                var _content = __chatterbox_tokenize_action(_string);
                
                #region Add instruction based on content array
            
                if (_content[0] == "if")
                {
                    if (_substring_line > _previous_line)
                    {
                        //If-statement on its own on a line
                        __chatterbox_new_instruction(__CHATTERBOX_VM_IF, _substring_indent, _content);
                        ds_list_add(_branch_stack, [__CHATTERBOX_VM_ENDIF,            //Type
                                                    global.__chatterbox_insert_pos-1, //Start position
                                                    _substring_indent,                //Indentation
                                                    false]);                          //Automatically create an ENDIF
                    }
                    else
                    {
                        //If-statement suffixed to another token
                        __chatterbox_new_instruction(__CHATTERBOX_VM_IF, _substring_indent, _content, global.__chatterbox_insert_pos-1);
                        ds_list_insert(_branch_stack, ds_list_size(_branch_stack)-1,
                                                      [__CHATTERBOX_VM_ENDIF,            //Type
                                                       global.__chatterbox_insert_pos-1, //Start position
                                                       _substring_indent,                //Indentation
                                                       true]);                           //Automatically create an ENDIF
                        global.__chatterbox_insert_pos++;
                    }
                }
                else if ((_content[0] == "else") || (_content[0] == "elseif") || (_content[0] == "else if"))
                {
                    __chatterbox_new_instruction(__CHATTERBOX_VM_ELSEIF, _substring_indent, _content);
                }
                else if ((_content[0] == "endif") || (_content[0] == "end if"))
                {
                    __chatterbox_new_instruction(__CHATTERBOX_VM_ENDIF, _substring_indent);
                }
                else if (_content[0] == "set")
                {
                    __chatterbox_new_instruction(__CHATTERBOX_VM_SET, _substring_indent, _content);
                }
                else if (_content[0] == "stop")
                {
                    __chatterbox_new_instruction(__CHATTERBOX_VM_STOP, _substring_indent);
                }
                else if (_content[0] == "wait")
                {
                    __chatterbox_new_instruction(__CHATTERBOX_VM_WAIT, _substring_indent);
                }
                else if (ds_map_exists(global.__chatterbox_actions, _content[0]))
                {
                    __chatterbox_new_instruction(__CHATTERBOX_VM_CUSTOM_ACTION, _substring_indent, _content);
                }
                else
                {
                    __chatterbox_new_instruction(__CHATTERBOX_VM_GENERIC_ACTION, _substring_indent, [_string]);
                }
            
                #endregion
                
                #endregion
            }
            else if (string_copy(_string, 1, 2) == "->") //Shortcut
            {
                __chatterbox_new_instruction(__CHATTERBOX_VM_SHORTCUT, _substring_indent,
                                             [__chatterbox_remove_whitespace(string_delete(_string, 1, 2), true)]);
                
                ds_list_add(_branch_stack, [__CHATTERBOX_VM_SHORTCUT_END,     //Type
                                            global.__chatterbox_insert_pos-1, //Start position
                                            _substring_indent,                //Indentation
                                            true]);                           //Automatically create a SHORTCUT_END
            }
            else //Text
            {
                __chatterbox_new_instruction(__CHATTERBOX_VM_TEXT, _substring_indent, [_string]);
            }
            
            _previous_line = _substring_line;
        }
        
        ds_list_destroy(_branch_stack);
        
        __chatterbox_new_instruction(__CHATTERBOX_VM_STOP, 0, undefined, ds_list_size(global.__chatterbox_vm));
        
        
        
        if (CHATTERBOX_DEBUG_PARSER)
        {
            #region Debug output that enumerates all instructions for this node
            
            var _i = _instruction_node_offset;
            repeat(ds_list_size(global.__chatterbox_vm) - _instruction_node_offset)
            {
                var _array = global.__chatterbox_vm[| _i];
                
                if (is_array(_array))
                {
                    _string = "";
                    
                    var _type    = _array[__CHATTERBOX_INSTRUCTION.TYPE   ];
                    var _indent  = _array[__CHATTERBOX_INSTRUCTION.INDENT ];
                    var _content = _array[__CHATTERBOX_INSTRUCTION.CONTENT];
                    
                    repeat(_indent) _string += " ";
                    _string += string(_type);
                    
                    if (_content != undefined)
                    {
                        if (is_array(_content))
                        {
                            _string += " " + __chatterbox_array_to_string(_content);
                        }
                        else
                        {
                            _string += " " + string(_content);
                        }
                    }
                }
                else
                {
                    _string = string(_array);
                }
                
                __chatterbox_trace("      " + _string);
                
                _i++;
            }
            
            #endregion
        }
    }
    
    _name = ds_map_find_next(global.__chatterbox_file_data, _name);
    ds_list_destroy(_node_list);
}



ds_list_destroy(_body_substring_list);

__chatterbox_trace("VM has " + string(ds_list_size(global.__chatterbox_vm)) + " instructions");
__chatterbox_trace("Initialisation complete, took " + string((get_timer() - _timer)/1000) + "ms");

global.__chatterbox_init_complete = true;