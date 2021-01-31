/// param filename
/// @param nodeTitle
/// @param bodyString

function __chatterbox_class_node(_filename, _title, _body_string) constructor
{
    if (__CHATTERBOX_DEBUG_COMPILER) __chatterbox_trace("[", _title, "]");
    
    filename         = _filename;
    title            = _title;
    root_instruction = new __chatterbox_class_instruction(undefined, -1, 0);
    
    //Prepare body string for parsing
    var _work_string = _body_string;
    _work_string = string_replace_all(_work_string, "\n\r", "\n");
    _work_string = string_replace_all(_work_string, "\r\n", "\n");
    _work_string = string_replace_all(_work_string, "\r"  , "\n");
    
    //Perform find-replace
    var _i = 0;
    repeat(ds_list_size(global.__chatterbox_findreplace_old_string))
    {
        _work_string = string_replace_all(_work_string,
                                          global.__chatterbox_findreplace_old_string[| _i],
                                          global.__chatterbox_findreplace_new_string[| _i]);
        ++_i;
    }
    
    //Add a trailing newline to make sure we parse correctly
    _work_string += "\n";
    
    var _substring_array = __chatterbox_split_body(_work_string);
    __chatterbox_compile(_substring_array, root_instruction);
    
    static mark_visited = function()
    {
        var _long_name = "visited(" + string(filename) + CHATTERBOX_FILENAME_SEPARATOR + string(title) + ")";
        
        var _value = CHATTERBOX_VARIABLES_MAP[? _long_name];
        if (_value == undefined)
        {
            CHATTERBOX_VARIABLES_MAP[? _long_name] = 1;
        }
        else
        {
            CHATTERBOX_VARIABLES_MAP[? _long_name]++;
        }
    }
    
    function toString()
    {
        return "Node " + string(filename) + CHATTERBOX_FILENAME_SEPARATOR + string(title);
    }
}

/// @param bodyString
function __chatterbox_split_body(_body)
{
    var _in_substring_array = [];
    
    var _body_byte_length = string_byte_length(_body);
    var _body_buffer = buffer_create(_body_byte_length+1, buffer_fixed, 1);
    buffer_write(_body_buffer, buffer_string, _body);
    buffer_seek(_body_buffer, buffer_seek_start, 0);
    
    var _line          = 0;
    var _first_on_line = true;
    var _indent        = undefined;
    var _newline       = false;
    var _cache         = "";
    var _cache_type    = "text";
    var _prev_value    = 0;
    var _value         = 0;
    var _next_value    = __chatterbox_read_utf8_char(_body_buffer);
    var _in_comment    = false;
    var _in_metadata   = false;
    
    repeat(_body_byte_length)
    {
        if (_next_value == 0) break;
        
        _prev_value = _value;
        _value      = _next_value;
        _next_value = __chatterbox_read_utf8_char(_body_buffer);
        
        var _write_cache = true;
        var _pop_cache   = false;
        
        if ((_value == ord("\n")) || (_value == ord("\r")))
        {
            _newline     = true;
            _pop_cache   = true;
            _write_cache = false;
            _in_comment  = false;
            _in_metadata = false;
        }
        else if (_in_comment)
        {
            _write_cache = false;
        }
        else if (_in_metadata)
        {
            if ((_value == ord("/")) && (_next_value == ord("/")))
            {
                _in_comment  = true;
                _pop_cache   = true;
                _write_cache = false;
            }
            else if ((_value == ord(",")) || (_value == ord("#")))
            {
                _pop_cache   = true;
                _write_cache = false;
            }
        }
        else
        {
            if ((_prev_value != ord("\\")) && (_value == ord("#")))
            {
                _in_metadata = true;
                _pop_cache   = true;
                _write_cache = false;
            }
            else if ((_value == ord("/")) && (_next_value == ord("/")))
            {
                _in_comment  = true;
                _pop_cache   = true;
                _write_cache = false;
            }
            else if (_value == ord(__CHATTERBOX_ACTION_OPEN_DELIMITER))
            {
                if (_next_value == ord(__CHATTERBOX_ACTION_OPEN_DELIMITER))
                {
                    _write_cache = false;
                    _pop_cache   = true;
                }
                else if (_prev_value == ord(__CHATTERBOX_ACTION_OPEN_DELIMITER))
                {
                    _write_cache = false;
                    _cache_type = "command";
                }
            }
            else if (_value == ord(__CHATTERBOX_ACTION_CLOSE_DELIMITER))
            {
                if (_next_value == ord(__CHATTERBOX_ACTION_CLOSE_DELIMITER))
                {
                    _write_cache = false;
                    _pop_cache   = true;
                }
                else if (_prev_value == ord(__CHATTERBOX_ACTION_CLOSE_DELIMITER))
                {
                    _write_cache = false;
                }
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
            else if (_in_metadata)
            {
                _cache = __chatterbox_remove_whitespace(_cache, true);
                _indent = 0;
            }
            
            _cache = __chatterbox_remove_whitespace(_cache, false);
            
            if (_cache != "") array_push(_in_substring_array, [_cache, _cache_type, _line, _indent]);
            _cache = "";
            _cache_type = _in_metadata? "metadata" : "text";
            
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
    
    array_push(_in_substring_array, ["stop", "command", _line, 0]);
    return _in_substring_array;
}

/// @param substringList
/// @param rootInstruction
function __chatterbox_compile(_in_substring_array, _root_instruction)
{
    if (array_length(_in_substring_array) <= 0) exit;
    
    var _previous_instruction = _root_instruction;
    
    var _if_stack = [];
    var _if_depth = -1;
    
    var _substring_count = array_length(_in_substring_array);
    var _s = 0;
    while(_s < _substring_count)
    {
        var _substring_array = _in_substring_array[_s];
        var _string          = _substring_array[0];
        var _type            = _substring_array[1];
        var _line            = _substring_array[2];
        var _indent          = _substring_array[3];
        
        var _instruction = undefined;
        
        if (__CHATTERBOX_DEBUG_COMPILER) __chatterbox_trace("ln ", string_format(_line, 4, 0), " ", __chatterbox_generate_indent(_indent), _string);
        
        if (string_copy(_string, 1, 2) == "->") //Shortcut //TODO - Make this part of the substring splitting step
        {
            var _instruction = new __chatterbox_class_instruction("shortcut", _line, _indent);
            _instruction.text = new __chatterbox_class_text(__chatterbox_remove_whitespace(string_delete(_string, 1, 2), all));
        }
        else if (_type == "command")
        {
            #region <<command>>
            
            _string = __chatterbox_remove_whitespace(_string, true);
            
            var _pos = string_pos(" ", _string);
            if (_pos > 0)
            {
                var _first_word = string_copy(_string, 1, _pos-1);
                var _remainder = string_delete(_string, 1, _pos);
            }
            else
            {
                var _first_word = _string;
                var _remainder = "";
            }
            
            switch(_first_word)
            {
                case "declare":
                    var _instruction = new __chatterbox_class_instruction(_first_word, _line, _indent);
                    _instruction.expression = __chatterbox_parse_expression(_remainder, true);
                break;
                
                case "set":
                    var _instruction = new __chatterbox_class_instruction(_first_word, _line, _indent);
                    _instruction.expression = __chatterbox_parse_expression(_remainder, false);
                break;
                
                case "jump":
                    var _instruction = new __chatterbox_class_instruction("jump", _line, _indent);
                    _instruction.destination = __chatterbox_remove_whitespace(_remainder, all);
                break;
                
                case "if":
                    if (_previous_instruction.line == _line)
                    {
                        _previous_instruction.condition = __chatterbox_parse_expression(_remainder, false);
                        //We *don't* make a new instruction for the if-statement, just attach it to the previous instruction as a condition
                    }
                    else
                    {
                        var _instruction = new __chatterbox_class_instruction("if", _line, _indent);
                        _instruction.condition = __chatterbox_parse_expression(_remainder, false);
                        _if_depth++;
                        _if_stack[@ _if_depth] = _instruction;
                    }
                break;
                    
                case "else":
                    var _instruction = new __chatterbox_class_instruction("else", _line, _indent);
                    if (_if_depth < 0)
                    {
                        __chatterbox_error("<<else>> found without matching <<if>>");
                    }
                    else
                    {
                        _if_stack[_if_depth].branch_reject = _instruction;
                        _if_stack[@ _if_depth] = _instruction;
                    }
                break;
                    
                case "else if":
                    if (CHATTERBOX_ERROR_NONSTANDARD_SYNTAX) __chatterbox_error("<<else if>> is non-standard Yarn syntax, please use <<elseif>>\n \n(Set CHATTERBOX_ERROR_NONSTANDARD_SYNTAX to <false> to hide this error)");
                case "elseif":
                    var _instruction = new __chatterbox_class_instruction("else if", _line, _indent);
                    _instruction.condition = __chatterbox_parse_expression(_remainder, false);
                    if (_if_depth < 0)
                    {
                        __chatterbox_error("<<else if>> found without matching <<if>>");
                    }
                    else
                    {
                        _if_stack[_if_depth].branch_reject = _instruction;
                        _if_stack[@ _if_depth] = _instruction;
                    }
                break;
                
                case "end if":
                    if (CHATTERBOX_ERROR_NONSTANDARD_SYNTAX) __chatterbox_error("<<end if>> is non-standard Yarn syntax, please use <<endif>>\n \n(Set CHATTERBOX_ERROR_NONSTANDARD_SYNTAX to <false> to hide this error)");
                case "endif":
                    var _instruction = new __chatterbox_class_instruction("end if", _line, _indent);
                    if (_if_depth < 0)
                    {
                        __chatterbox_error("<<endif>> found without matching <<if>>");
                    }
                    else
                    {
                        _if_stack[_if_depth].branch_reject = _instruction;
                        _if_depth--;
                    }
                break;
                
                case "wait":
                case "stop":
                    _remainder = __chatterbox_remove_whitespace(_remainder, true);
                    if (_remainder != "")
                    {
                        __chatterbox_error("Cannot use arguments with <<wait>> or <<stop>>\n\Action was \"<<", _string, ">>\"");
                    }
                    else
                    {
                        var _instruction = new __chatterbox_class_instruction(_first_word, _line, _indent);
                    }
                break;
                    
                default:
                    var _instruction = new __chatterbox_class_instruction("direction", _line, _indent);
                    _instruction.text = new __chatterbox_class_text(_string);
                break;
            }
            
            #endregion
        }
        else if (_type == "metadata")
        {
            #region #metadata
            
            if (_previous_instruction != undefined)
            {
                if (_previous_instruction.type != "content")
                {
                    __chatterbox_trace("Warning! Previous instruction wasn't content, metadata \"\#", _string, "\" cannot be applied");
                }
                else if (_previous_instruction.line != _line)
                {
                    __chatterbox_trace("Warning! Previous instruction (ln ", _previous_instruction.line, ") was a different line to metadata (ln ", _line, "), \"\#", _string, "\"");
                }
                else
                {
                    array_push(_previous_instruction.metadata, _string)
                }
            }
            
            #endregion
        }
        else if (_type == "text")
        {
            var _instruction = new __chatterbox_class_instruction("content", _line, _indent);
            _instruction.text = new __chatterbox_class_text(_string);
        }
        
        if (_instruction != undefined)
        {
            __chatterbox_instruction_add(_previous_instruction, _instruction);
            _previous_instruction = _instruction;
        }
        
        ++_s;
    }
    
    show_debug_message("!");
}



/// @param string
/// @param allowActionSyntax
function __chatterbox_parse_expression(_string, _action_syntax)
{
    enum __CHATTERBOX_TOKEN
    {
        NULL     = -1,
        UNKNOWN  =  0,
        VARIABLE =  1,
        STRING   =  2,
        NUMBER   =  3,
        SYMBOL   =  4,
    }
    
    var _tokens = [];
    
    var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
    buffer_write(_buffer, buffer_string, _string);
    
    var _read_start   = 0;
    var _state        = __CHATTERBOX_TOKEN.UNKNOWN;
    var _next_state   = __CHATTERBOX_TOKEN.UNKNOWN;
    var _last_byte    = 0;
    var _new          = false;
    var _change_state = true;
    
    var _b = 0;
    repeat(buffer_get_size(_buffer))
    {
        var _byte = buffer_peek(_buffer, _b, buffer_u8);
        _next_state = (_byte == 0)? __CHATTERBOX_TOKEN.NULL : __CHATTERBOX_TOKEN.UNKNOWN;
        _change_state = true;
        _new = false;
        
        switch(_state)
        {
            case __CHATTERBOX_TOKEN.VARIABLE: //Word/Variable Name
                #region
                
                if (_byte == 46) //.
                {
                    _next_state = __CHATTERBOX_TOKEN.VARIABLE;
                }
                else if ((_byte >= 48) && (_byte <= 57)) //0 1 2 3 4 5 6 7 8 9
                {
                    _next_state = __CHATTERBOX_TOKEN.VARIABLE;
                }
                else if ((_byte >= 65) && (_byte <= 90)) //a b c...x y z
                {
                    _next_state = __CHATTERBOX_TOKEN.VARIABLE;
                }
                else if (_byte == 95) //_
                {
                    _next_state = __CHATTERBOX_TOKEN.VARIABLE;
                }
                else if ((_byte >= 97) && (_byte <= 122)) //A B C...X Y Z
                {
                    _next_state = __CHATTERBOX_TOKEN.VARIABLE;
                }
                else if (_byte == 40) //(
                {
                    _next_state = __CHATTERBOX_TOKEN.VARIABLE;
                }
                
                if ((_state != _next_state) || (_last_byte == 40)) //Cheeky hack to find functions
                {
                    var _is_symbol   = false;
                    var _is_number   = false;
                    var _is_function = (_last_byte == 40); //Cheeky hack to find functions
                    
                    //Just a normal keyboard/variable
                    buffer_poke(_buffer, _b, buffer_u8, 0);
                    buffer_seek(_buffer, buffer_seek_start, _read_start);
                    var _read = buffer_read(_buffer, buffer_string);
                    buffer_poke(_buffer, _b, buffer_u8, _byte);
                    
                    if (!_is_function)
                    {
                        //Convert friendly human-readable operators into symbolic operators
                        //Also handle numeric keywords too
                        switch(_read)
                        {
                            case "and":       _read = "&&";      _is_symbol = true; break;
                            case "le" :       _read = "<";       _is_symbol = true; break;
                            case "gt" :       _read = ">";       _is_symbol = true; break;
                            case "or" :       _read = "||";      _is_symbol = true; break;
                            case "leq":       _read = "<=";      _is_symbol = true; break;
                            case "geq":       _read = ">=";      _is_symbol = true; break;
                            case "eq" :       _read = "==";      _is_symbol = true; break;
                            case "is" :       _read = "==";      _is_symbol = true; break;
                            case "neq":       _read = "!=";      _is_symbol = true; break;
                            case "to" :       _read = "=";       _is_symbol = true; break;
                            case "not":       _read = "!";       _is_symbol = true; break;
                            case "true":      _read = true;      _is_number = true; break;
                            case "false":     _read = false;     _is_number = true; break;
                            case "undefined": _read = undefined; _is_number = true; break;
                            case "null":      _read = undefined; _is_number = true; break;
                        }
                    }
                    
                    if (_is_symbol)
                    {
                        __chatterbox_array_add(_tokens, { op : _read });
                    }
                    else if (_is_number)
                    {
                        __chatterbox_array_add(_tokens, _read);
                    }
                    else if (_is_function)
                    {
                        _read = string_copy(_read, 1, string_length(_read)-1); //Trim off the open bracket
                        __chatterbox_array_add(_tokens, { op : "func", name : _read });
                    }
                    else
                    {
                        //Parse this variable and figure out what scope we're in
                        var _scope = CHATTERBOX_NAKED_VARIABLE_SCOPE;
                        
                        if (string_char_at(_read, 1) == "$")
                        {
                            _scope = CHATTERBOX_DOLLAR_VARIABLE_SCOPE;
                            _read = string_delete(_read, 1, 1);
                        }
                        else if (string_copy(_read, 1, 2) == "g.")
                        {
                            _scope = "global";
                            _read = string_delete(_read, 1, 2);
                        }
                        else if (string_copy(_read, 1, 7) == "global.")
                        {
                            _scope = "global";
                            _read = string_delete(_read, 1, 7);
                        }
                        else if (string_copy(_read, 1, 2) == "l.")
                        {
                            _scope = "local";
                            _read = string_delete(_read, 1, 2);
                        }
                        else if (string_copy(_read, 1, 6) == "local.")
                        {
                            _scope = "local";
                            _read = string_delete(_read, 1, 6);
                        }
                        else if (string_copy(_read, 1, 2) == "y.")
                        {
                            _scope = "yarn";
                            _read = string_delete(_read, 1, 2);
                        }
                        else if (string_copy(_read, 1, 9) == "yarn.")
                        {
                            _scope = "yarn";
                            _read = string_delete(_read, 1, 9);
                        }
                        
                        if (_scope == "string")
                        {
                            __chatterbox_array_add(_tokens, _read);
                        }
                        else
                        {
                            __chatterbox_array_add(_tokens, { op : "var", scope : _scope, name : _read });
                        }
                    }
                    
                    _new = true;
                    _next_state = __CHATTERBOX_TOKEN.UNKNOWN;
                }
                
                #endregion
            break;
            
            case __CHATTERBOX_TOKEN.STRING: //Quote-delimited String
                #region
                
                if ((_byte == 0) || ((_byte == 34) && (_last_byte != 92))) //null "
                {
                    _change_state = false;
                    
                    if (_read_start < _b - 1)
                    {
                        buffer_poke(_buffer, _b, buffer_u8, 0);
                        buffer_seek(_buffer, buffer_seek_start, _read_start+1);
                        var _read = buffer_read(_buffer, buffer_string);
                        buffer_poke(_buffer, _b, buffer_u8, _byte);
                    }
                    else
                    {
                        var _read = "";
                    }
                    
                    __chatterbox_array_add(_tokens, _read);
                    _new = true;
                }
                else
                {
                    _next_state = __CHATTERBOX_TOKEN.STRING; //Quote-delimited String
                }
                
                #endregion
            break;
            
            case __CHATTERBOX_TOKEN.NUMBER: //Number
                #region
                
                if (_byte == 46) //.
                {
                    _next_state = __CHATTERBOX_TOKEN.NUMBER;
                }
                else if ((_byte >= 48) && (_byte <= 57)) //0 1 2 3 4 5 6 7 8 9
                {
                    _next_state = __CHATTERBOX_TOKEN.NUMBER;
                }
                
                if (_state != _next_state)
                {
                    buffer_poke(_buffer, _b, buffer_u8, 0);
                    buffer_seek(_buffer, buffer_seek_start, _read_start);
                    var _read = buffer_read(_buffer, buffer_string);
                    buffer_poke(_buffer, _b, buffer_u8, _byte);
                    
                    try
                    {
                        _read = real(_read);
                    }
                    catch(_error)
                    {
                        __chatterbox_error("Error whilst converting expression value to real\n \n(", _error, ")");
                        return undefined;
                    }
                    
                    __chatterbox_array_add(_tokens, _read);
                    
                    _new = true;
                }
                
                #endregion
            break;
            
            case __CHATTERBOX_TOKEN.SYMBOL: //Symbol
                #region
                
                if (_byte == 61) //=
                {
                    if ((_last_byte == 33)  // !=
                    ||  (_last_byte == 42)  // *=
                    ||  (_last_byte == 43)  // +=
                    ||  (_last_byte == 45)  // +=
                    ||  (_last_byte == 47)  // /=
                    ||  (_last_byte == 60)  // <=
                    ||  (_last_byte == 61)  // ==
                    ||  (_last_byte == 62)) // >=
                    {
                        _next_state = __CHATTERBOX_TOKEN.SYMBOL; //Symbol
                    }
                }
                else if ((_byte == 38) && (_last_byte == 38)) //&
                {
                    _next_state = __CHATTERBOX_TOKEN.SYMBOL; //Symbol
                }
                else if ((_byte == 124) && (_last_byte == 124)) //|
                {
                    _next_state = __CHATTERBOX_TOKEN.SYMBOL; //Symbol
                }
                
                if (_state != _next_state)
                {
                    buffer_poke(_buffer, _b, buffer_u8, 0);
                    buffer_seek(_buffer, buffer_seek_start, _read_start);
                    var _read = buffer_read(_buffer, buffer_string);
                    buffer_poke(_buffer, _b, buffer_u8, _byte);
                    
                    __chatterbox_array_add(_tokens, { op : _read });
                    
                    _new = true;
                }
                
                #endregion
            break;
        }
        
        if (_change_state && (_next_state == __CHATTERBOX_TOKEN.UNKNOWN))
        {
            #region
            
            //TODO - Compress this down
            if (_byte == 33) //!
            {
                _next_state = __CHATTERBOX_TOKEN.SYMBOL; //Symbol
            }
            else if ((_byte == 34) && (_last_byte != 92)) //"
            {
                _next_state = __CHATTERBOX_TOKEN.STRING; //Quote-delimited String
            }
            else if (_byte == 36) //$
            {
                _next_state = __CHATTERBOX_TOKEN.VARIABLE; //Word/Variable Name
            }
            else if ((_byte == 37) || (_byte == 38)) //% &
            {
                _next_state = __CHATTERBOX_TOKEN.SYMBOL; //Symbol
            }
            else if ((_byte == 40) || (_byte == 41)) //( )
            {
                _next_state = __CHATTERBOX_TOKEN.SYMBOL; //Symbol
            }
            else if ((_byte == 42) || (_byte == 43)) //* +
            {
                _next_state = __CHATTERBOX_TOKEN.SYMBOL; //Symbol
            }
            else if (_byte == 44) //,
            {
                _next_state = __CHATTERBOX_TOKEN.SYMBOL; //Symbol
            }
            else if (_byte == 45) //-
            {
                _next_state = __CHATTERBOX_TOKEN.SYMBOL; //Symbol
            }
            else if (_byte == 46) //.
            {
                _next_state = __CHATTERBOX_TOKEN.NUMBER; //Number
            }
            else if (_byte == 47) // /
            {
                _next_state = __CHATTERBOX_TOKEN.SYMBOL; //Symbol
            }
            else if ((_byte >= 48) && (_byte <= 57)) //0 1 2 3 4 5 6 7 8 9
            {
                _next_state = __CHATTERBOX_TOKEN.NUMBER; //Number
            }
            else if ((_byte == 60) || (_byte == 61) || (_byte == 62)) //< = >
            {
                _next_state = __CHATTERBOX_TOKEN.SYMBOL; //Symbol
            }
            else if ((_byte >= 65) && (_byte <= 90)) //a b c...x y z
            {
                _next_state = __CHATTERBOX_TOKEN.VARIABLE; //Word/Variable Name
            }
            else if (_byte == 95) //_
            {
                _next_state = __CHATTERBOX_TOKEN.VARIABLE; //Word/Variable Name
            }
            else if ((_byte >= 97) && (_byte <= 122)) //A B C...X Y Z
            {
                _next_state = __CHATTERBOX_TOKEN.VARIABLE; //Word/Variable Name
            }
            else if (_byte == 124) // |
            {
                _next_state = __CHATTERBOX_TOKEN.SYMBOL; //Symbol
            }
            
            #endregion
        }
        
        if (_new || (_state != _next_state)) _read_start = _b;
        _state = _next_state;
        if (_state == __CHATTERBOX_TOKEN.NULL) break;
        _last_byte = _byte;
        
        ++_b;
    }
    
    buffer_delete(_buffer);
    
    __chatterbox_compile_expression(_tokens);
    
    if (!_action_syntax)
    {
        return _tokens[0];
    }
    else
    {
        //We're using the weirdo Python-esque syntax for generic actions
        
        //If we've already got a function as the first operation, just return that
        if (_tokens[0].op == "func") return _tokens[0];
        
        //If the first token isn't a variable (i.e. isn't something that might be a function name) then just return the first token
        if (_tokens[0].op != "var") return _tokens[0];
        
        //Otherwise formulate a function operation
        var _name = _tokens[0].name;
        __chatterbox_array_delete(_tokens, 0, 1);
        return { op : "func", name : _name, parameters : _tokens };
    }
}



/// @param array
/// @param startIndex
/// @param endIndex
function __chatterbox_compile_expression(_source_array)
{
    //Handle parentheses
    var _depth = 0;
    var _open = undefined;
    var _sub_expression_start = undefined;
    var _is_function = false;
    var _t = 0;
    while(_t < array_length(_source_array))
    {
        var _token = _source_array[_t];
        if (is_struct(_token))
        {
            if ((_token.op == "(") || (_token.op == "func"))
            {
                ++_depth;
                if (_depth == 1)
                {
                    if (_token.op == "func")
                    {
                        _is_function = true;
                        _open = _t + 1;
                    }
                    else
                    {
                        _open = _t;
                        _is_function = false;
                        __chatterbox_array_delete(_source_array, _open, 1);
                        --_t;
                    }
                    
                    _sub_expression_start = _open;
                }
            }
            else if (_token.op == ",")
            {
                if (_depth == 1)
                {
                    var _sub_array = __chatterbox_array_copy_part(_source_array, _sub_expression_start, _t - _sub_expression_start);
                    __chatterbox_array_delete(_source_array, _sub_expression_start, array_length(_sub_array));
                    __chatterbox_compile_expression(_sub_array);
                    
                    _source_array[@ _sub_expression_start] = { op : "param", a : _sub_array[0] };
                    
                    _t = _sub_expression_start;
                    ++_sub_expression_start;
                }
            }
            else if (_token.op == ")")
            {
                --_depth;
                if (_depth == 0)
                {
                    var _sub_array = __chatterbox_array_copy_part(_source_array, _sub_expression_start, _t - _sub_expression_start);
                    __chatterbox_array_delete(_source_array, _sub_expression_start, array_length(_sub_array));
                    __chatterbox_compile_expression(_sub_array);
                    
                    _source_array[@ _sub_expression_start] = { op : "paren", a : _sub_array[0] };
                    
                    if (_is_function)
                    {
                        var _parameters = __chatterbox_array_copy_part(_source_array, _open, 1 + _sub_expression_start - _open);
                        __chatterbox_array_delete(_source_array, _open, 1 + _sub_expression_start - _open);
                        
                        _source_array[_open - 1].parameters = _parameters;
                        _t = _open - 1;
                    }
                    else
                    {
                        _t = _open;
                    }
                }
            }
        }
        
        ++_t;
    }
    
    //Scan for negation (! / NOT)
    var _t = 0;
    while(_t < array_length(_source_array))
    {
        var _token = _source_array[_t];
        if (is_struct(_token))
        {
            if (_token.op == "!")
            {
                _token.a = _source_array[_t+1];
                __chatterbox_array_delete(_source_array, _t+1, 1);
            }
        }
        
        ++_t;
    }
    
    //Scan for negative signs
    var _t = 0;
    while(_t < array_length(_source_array))
    {
        var _token = _source_array[_t];
        if (is_struct(_token))
        {
            if (_token.op == "-")
            {
                //If this token was preceded by a symbol (or nothing) then it's a negative sign
                if ((_t == 0) || (__chatterbox_string_is_symbol(_source_array[_t-1], true)))
                {
                    _token.op = "neg";
                    _token.a = _source_array[_t+1];
                    __chatterbox_array_delete(_source_array, _t+1, 1);
                }
            }
        }
        
        ++_t;
    }
    
    var _o = 0;
    repeat(ds_list_size(global.__chatterbox_op_list))
    {
        var _operator = global.__chatterbox_op_list[| _o];
        
        var _t = 0;
        while(_t < array_length(_source_array))
        {
            var _token = _source_array[_t];
            if (is_struct(_token))
            {
                if (_token.op == _operator)
                {
                    _token.a = _source_array[_t-1];
                    _token.b = _source_array[_t+1];
                    
                    //Order of operation very important here!
                    __chatterbox_array_delete(_source_array, _t+1, 1);
                    __chatterbox_array_delete(_source_array, _t-1, 1);
                    
                    //Correct for token deletion
                    --_t;
                }
            }
            
            ++_t;
        }
        
        ++_o;
    }
    
    return _source_array;
}



/// @param string
/// @param ignoreCloseParentheses
function __chatterbox_string_is_symbol(_string, _ignore_close_paren)
{
    if ((_string == "(" )
    || ((_string == ")" ) && !_ignore_close_paren)
    ||  (_string == "!" )
    ||  (_string == "/=")
    ||  (_string == "/" )
    ||  (_string == "*=")
    ||  (_string == "*" )
    ||  (_string == "+" )
    ||  (_string == "+=")
    ||  (_string == "-" )
    ||  (_string == "-=")
    ||  (_string == "||")
    ||  (_string == "&&")
    ||  (_string == ">=")
    ||  (_string == "<=")
    ||  (_string == ">" )
    ||  (_string == "<" )
    ||  (_string == "!=")
    ||  (_string == "==")
    ||  (_string == "=" ))
    {
        return true;
    }
    
    return false;
}