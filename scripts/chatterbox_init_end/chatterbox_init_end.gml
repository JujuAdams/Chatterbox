/// Completes initialisation for Chatterbox
/// This script should be called after chatterbox_init_start() and chatterbox_init_add()
///
/// https://github.com/thesecretlab/YarnSpinner/blob/master/Documentation/YarnSpinner-Dialogue/Yarn-Syntax.md
/// 
/// Once this script has been run, Chatterbox is ready for use!

var _timer = get_timer();

if ( !variable_global_exists("__chatterbox_init_complete" ) )
{
    show_error("Chatterbox:\nchatterbox_init_end() should be called after chatterbox_init_start()\n ", false);
    exit;
}

show_debug_message("Chatterbox: Initialisation started");



var _font_count = ds_map_size(global.__chatterbox_file_data);
var _name = ds_map_find_first(global.__chatterbox_file_data);
repeat(_font_count)
{
    var _font_data = global.__chatterbox_file_data[? _name ];
    show_debug_message("Chatterbox:   Processing file \"" + _name + "\"");
    
    var _filename = _font_data[ __CHATTERBOX_FILE.FILENAME ];
    
    var _buffer = buffer_load(global.__chatterbox_font_directory + _filename);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    
    var _chatterbox_map = ds_map_create();
    ds_map_add_map(global.__chatterbox_data, _filename, _chatterbox_map);
    
    var _yarn_json = json_decode(_string);
    
    //Test for JSON made by the standard Yarn editor
    var _node_list = _yarn_json[? "default" ];
    if (_node_list != undefined) show_debug_message("Chatterbox:   File was made in standard Yarn editor");
    
    //Test for JSON made by Jacquard
    if (_node_list == undefined)
    {
        var _node_list = _yarn_json[? "nodes" ];
        if (_node_list != undefined) show_debug_message("Chatterbox:   File was made by Jacquard");
    }
    
    //If both of these fail, it's some wacky JSON that we don't recognise
    if (_node_list == undefined)
    {
        show_error("Chatterbox:\nJSON format for \"" + _name + "\" is unrecognised.\nThis source file will be ignored.\n ", false);
        continue;
    }
    
    var _node_count = ds_list_size(_node_list);
    var _title_string = "Chatterbox:     Found " + string(_node_count) + " titles: ";
    var _title_count = 0;
    for(var _node = 0; _node < _node_count; _node++)
    {
        var _node_map = _node_list[| _node];
        var _title = _node_map[? "title" ];
        var _body  = _node_map[? "body"  ];
        
        var _instruction_list = ds_list_create();
        ds_map_add_list(_chatterbox_map, _title, _instruction_list);
        
        
        
        //Debug output that displays all the nodes in a file
        _title_string += "\"" + _title + "\"";
        if (_node < _node_count-1)
        {
            _title_string += ", ";
            _title_count++;
            if (_title_count >= 30)
            {
                show_debug_message(_title_string);
                _title_string = "Chatterbox:     ";
                _title_count = 0;
            }
        }
        
        
        
        //Prepare body string for parsing
        _body = string_replace_all(_body, "\n\r", "\n");
        _body = string_replace_all(_body, "\r\n", "\n");
        _body = string_replace_all(_body, "\r"  , "\n");
        if (__CHATTERBOX_DEBUG_PARSER)
        {
            if (_node == 0) show_debug_message("Chatterbox:");
            show_debug_message("Chatterbox:     \"" + string(_title) + "\" : \"" + string_replace_all(string(_body), "\n", "\\n") + "\"");
        }
        _body += "\n";
        
        
        
        #region Parse the body text for this node
        
        var _body_read = 0;
        var _body_read_prev = 1;
        repeat(string_length(_body))
        {
            _body_read++;
            var _body_char = string_char_at(_body, _body_read);
            
            if (_body_char == "\n")
            {
                var _line_string = string_copy(_body, _body_read_prev, _body_read - _body_read_prev);
                _body_read_prev = _body_read+1;
                
                //Strip whitespace from the start of the string
                _line_string = __chatterbox_remove_whitespace(_line_string, true);
                var _indent = global.__chatterbox_indent_size;
                if (CHATTERBOX_ROUND_UP_INDENTS) _indent = CHATTERBOX_TAB_INDENT_SIZE*ceil(_indent/CHATTERBOX_TAB_INDENT_SIZE);
                if (_line_string == "") continue;
                
                //Strip whitespace from the end of the string
                _line_string = __chatterbox_remove_whitespace(_line_string, false);
                
                var _in_option = false;
                var _in_action = false;
                var _first_token = true;
                var _line_read = 0;
                var _line_char = "";
                var _line_read_prev = 1;
                var _line_char_prev = "";
                var _length = string_length(_line_string);
                repeat(_length)
                {
                    _line_read++;
                    var _string = "";
                    
                    _line_char_prev = _line_char;
                    var _line_char = string_char_at(_line_string, _line_read);
                    
                    if (_line_char_prev == _line_char)
                    && (  ( _in_option && (_line_char == CHATTERBOX_OPTION_CLOSE_DELIMITER))
                       || ( _in_action && (_line_char == CHATTERBOX_ACTION_CLOSE_DELIMITER))
                       || (!_in_option && (_line_char == CHATTERBOX_OPTION_OPEN_DELIMITER))
                       || (!_in_action && (_line_char == CHATTERBOX_ACTION_OPEN_DELIMITER))  )
                    {
                            _string = string_copy(_line_string, _line_read_prev, _line_read-1 - _line_read_prev);
                            _line_read_prev = _line_read+1;
                    }
                    else if (_line_read == _length)
                    {
                        _string = string_copy(_line_string, _line_read_prev, 1 + _line_read - _line_read_prev);
                    }
                    
                    if (_string != "")
                    {
                        _string = __chatterbox_remove_whitespace(__chatterbox_remove_whitespace(_string, true), false);
                        if (_string != "")
                        {
                            var _array = array_create(__CHATTERBOX_INSTRUCTION.__SIZE);
                            _array[ __CHATTERBOX_INSTRUCTION.TYPE    ] = __CHATTERBOX_VM_UNKNOWN;
                            _array[ __CHATTERBOX_INSTRUCTION.INDENT  ] = 0;
                            _array[ __CHATTERBOX_INSTRUCTION.CONTENT ] = undefined;
                            
                            if (_in_option)
                            {
                                _in_option = false;
                        
                                #region [[option]]
                        
                                var _pos = string_pos("|", _string);
                                if (_pos < 1)
                                {
                                    _array[@ __CHATTERBOX_INSTRUCTION.TYPE    ] = __CHATTERBOX_VM_REDIRECT;
                                    _array[@ __CHATTERBOX_INSTRUCTION.INDENT  ] = _indent;
                                    _array[@ __CHATTERBOX_INSTRUCTION.CONTENT ] = [_string];
                                }
                                else
                                {
                                    var _content = [ __chatterbox_remove_whitespace(string_copy(_string, 1, _pos-1), false),
                                                     __chatterbox_remove_whitespace(string_delete(_string, 1, _pos), true) ];
                                    _array[@ __CHATTERBOX_INSTRUCTION.TYPE    ] = __CHATTERBOX_VM_OPTION;
                                    _array[@ __CHATTERBOX_INSTRUCTION.INDENT  ] = _indent;
                                    _array[@ __CHATTERBOX_INSTRUCTION.CONTENT ] = _content;
                                }
                        
                                #endregion
                            }
                            else if (_in_action)
                            {
                                _in_action = false;
                        
                                #region <<action>>
                                
                                if (string_copy(_string, 1, 3) == "if ") || (string_copy(_string, 1, 7) == "elseif ") || (string_copy(_string, 1, 4) == "set ")
                                {
                                    var _content = [];
                                    repeat(9999)
                                    {
                                        var _pos = string_pos(" ", _string);
                                        if (_pos <= 0) _pos = string_length(_string)+1;
                                        _content[ array_length_1d(_content) ] = string_copy(_string, 1, _pos-1);
                                        _string = __chatterbox_remove_whitespace(string_delete(_string, 1, _pos), true);
                                        if (_string == "") break;
                                    }
                            
                                    if (_content[0] == "if")
                                    {
                                        if (_first_token)
                                        {
                                            //If-statement on its own on a line
                                            _array[@ __CHATTERBOX_INSTRUCTION.TYPE    ] = __CHATTERBOX_VM_IF;
                                            _array[@ __CHATTERBOX_INSTRUCTION.INDENT  ] = _indent;
                                            _array[@ __CHATTERBOX_INSTRUCTION.CONTENT ] = _content;
                                        }
                                        else
                                        {
                                            //If-statement suffixed to another token
                                            var _insert_array = array_create(__CHATTERBOX_INSTRUCTION.__SIZE);
                                            _insert_array[ __CHATTERBOX_INSTRUCTION.TYPE    ] = __CHATTERBOX_VM_IF;
                                            _insert_array[ __CHATTERBOX_INSTRUCTION.INDENT  ] = _indent;
                                            _insert_array[ __CHATTERBOX_INSTRUCTION.CONTENT ] = _content;
                                            ds_list_insert(_instruction_list, ds_list_size(_instruction_list)-1, _insert_array);
                                    
                                            _array[@ __CHATTERBOX_INSTRUCTION.TYPE   ] = __CHATTERBOX_VM_IF_END;
                                            _array[@ __CHATTERBOX_INSTRUCTION.INDENT ] = _indent;
                                        }
                                    }
                                    else if (_content[0] == "elseif")
                                    {
                                        _array[@ __CHATTERBOX_INSTRUCTION.TYPE    ] = __CHATTERBOX_VM_ELSEIF;
                                        _array[@ __CHATTERBOX_INSTRUCTION.INDENT  ] = _indent;
                                        _array[@ __CHATTERBOX_INSTRUCTION.CONTENT ] = _content;
                                    }
                                    else if (_content[0] == "set")
                                    {
                                        _array[@ __CHATTERBOX_INSTRUCTION.TYPE    ] = __CHATTERBOX_VM_SET;
                                        _array[@ __CHATTERBOX_INSTRUCTION.INDENT  ] = _indent;
                                        _array[@ __CHATTERBOX_INSTRUCTION.CONTENT ] = _content;
                                    }
                                }
                                else if (_string == "endif")
                                {
                                    _array[@ __CHATTERBOX_INSTRUCTION.TYPE   ] = __CHATTERBOX_VM_IF_END;
                                    _array[@ __CHATTERBOX_INSTRUCTION.INDENT ] = _indent;
                                }
                                else if (_string == "else")
                                {
                                    _array[@ __CHATTERBOX_INSTRUCTION.TYPE   ] = __CHATTERBOX_VM_ELSE;
                                    _array[@ __CHATTERBOX_INSTRUCTION.INDENT ] = _indent;
                                }
                                else if (_string == "stop")
                                {
                                    _array[@ __CHATTERBOX_INSTRUCTION.TYPE    ] = __CHATTERBOX_VM_STOP;
                                    _array[@ __CHATTERBOX_INSTRUCTION.INDENT  ] = _indent;
                                }
                                else
                                {
                                    _array[@ __CHATTERBOX_INSTRUCTION.TYPE    ] = __CHATTERBOX_VM_ACTION;
                                    _array[@ __CHATTERBOX_INSTRUCTION.INDENT  ] = _indent;
                                    _array[@ __CHATTERBOX_INSTRUCTION.CONTENT ] = [_string];
                                }
                        
                                #endregion
                            }
                            else
                            {
                                #region Text
                        
                                if (string_copy(_string, 1, 2) == "->")
                                {
                                    _array[@ __CHATTERBOX_INSTRUCTION.TYPE    ] = __CHATTERBOX_VM_SHORTCUT;
                                    _array[@ __CHATTERBOX_INSTRUCTION.INDENT  ] = _indent;
                                    _array[@ __CHATTERBOX_INSTRUCTION.CONTENT ] = [__chatterbox_remove_whitespace(string_delete(_string, 1, 2), true)];
                                }
                                else
                                {
                                    _array[@ __CHATTERBOX_INSTRUCTION.TYPE    ] = __CHATTERBOX_VM_TEXT;
                                    _array[@ __CHATTERBOX_INSTRUCTION.INDENT  ] = _indent;
                                    _array[@ __CHATTERBOX_INSTRUCTION.CONTENT ] = [_string];
                                }
                        
                                #endregion
                            }
                            
                            ds_list_add(_instruction_list, _array);
                            _first_token = false;
                        }
                    }
                    
                    if (_line_char_prev == CHATTERBOX_OPTION_OPEN_DELIMITER) && (_line_char == CHATTERBOX_OPTION_OPEN_DELIMITER)
                    {
                        _in_option = true;
                    }
                    else if (_line_char_prev == CHATTERBOX_ACTION_OPEN_DELIMITER) && (_line_char == CHATTERBOX_ACTION_OPEN_DELIMITER)
                    {
                        _in_action = true;
                    }
                }
            }
        }
        
        #endregion
        
        //Make sure we always have an STOP instruction at the end
        var _array = array_create(__CHATTERBOX_INSTRUCTION.__SIZE);
        _array[ __CHATTERBOX_INSTRUCTION.TYPE    ] = __CHATTERBOX_VM_STOP;
        _array[ __CHATTERBOX_INSTRUCTION.INDENT  ] = 0;
        _array[ __CHATTERBOX_INSTRUCTION.CONTENT ] = undefined;
        ds_list_add(_instruction_list, _array);
        
        
        
        //Debug output that enumerates all instructions for this node
        if (__CHATTERBOX_DEBUG_PARSER)
        {
            var _i = 0;
            repeat(ds_list_size(_instruction_list))
            {
                var _array = _instruction_list[| _i];
                _string = "";
                
                var _size = array_length_1d(_array);
                for(var _j = 0; _j < _size; _j++)
                {
                    _string += string(_array[_j]);
                    if (_j < _size-1) _string += ", ";
                }
                show_debug_message("Chatterbox:       " + _string);
                
                _i++;
            }
            show_debug_message("Chatterbox:");
        }
    }
    
    //Debug output that displays all the nodes in a file
    show_debug_message(_title_string);
    
    ds_map_destroy(_yarn_json);
}



show_debug_message("Chatterbox: Initialisation complete, took " + string((get_timer() - _timer)/1000) + "ms");
show_debug_message("Chatterbox: Thanks for using Chatterbox!");

global.__chatterbox_init_complete = true;