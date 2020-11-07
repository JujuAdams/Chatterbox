/// @param filename
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
    
    var _substring_list = __chatterbox_split_body(_work_string);
    __chatterbox_compile(_substring_list, root_instruction);
    
    ds_list_destroy(_substring_list);
    
    function mark_visited()
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

/// @param buffer
function __chatterbox_read_utf8_char(_buffer)
{
    var _value = buffer_read(_buffer, buffer_u8);
    if ((_value & $E0) == $C0) //two-byte
    {
        _value  = (                         _value & $1F) <<  6;
        _value += (buffer_read(_buffer, buffer_u8) & $3F);
    }
    else if ((_value & $F0) == $E0) //three-byte
    {
        _value  = (                         _value & $0F) << 12;
        _value += (buffer_read(_buffer, buffer_u8) & $3F) <<  6;
        _value +=  buffer_read(_buffer, buffer_u8) & $3F;
    }
    else if ((_value & $F8) == $F0) //four-byte
    {
        _value  = (                         _value & $07) << 18;
        _value += (buffer_read(_buffer, buffer_u8) & $3F) << 12;
        _value += (buffer_read(_buffer, buffer_u8) & $3F) <<  6;
        _value +=  buffer_read(_buffer, buffer_u8) & $3F;
    }
    
    return _value;
}

/// @param bodyString
function __chatterbox_split_body(_body)
{
    var _body_substring_list = ds_list_create();
    
    var _body_byte_length = string_byte_length(_body);
    var _body_buffer = buffer_create(_body_byte_length+1, buffer_fixed, 1);
    buffer_poke(_body_buffer, 0, buffer_string, _body);
    
    var _line          = 0;
    var _first_on_line = true;
    var _indent        = undefined;
    var _newline       = false;
    var _cache         = "";
    var _cache_type    = "text";
    var _prev_value    = 0;
    var _value         = 0;
    var _next_value    = __chatterbox_read_utf8_char(_body_buffer);
    
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
            
            _cache = __chatterbox_remove_whitespace(_cache, false);
            
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
    
    ds_list_add(_body_substring_list, ["stop", "action", _line, 0]);
    return _body_substring_list;
}

/// @param substringList
/// @param rootInstruction
function __chatterbox_compile(_substring_list, _root_instruction)
{
    if (ds_list_size(_substring_list) <= 0) exit;
    
    var _previous_instruction = _root_instruction;
    
    var _if_stack = [];
    var _if_depth = -1;
    
    var _substring_count = ds_list_size(_substring_list);
    var _s = 0;
    while(_s < _substring_count)
    {
        var _substring_array = _substring_list[| _s];
        var _string          = _substring_array[0];
        var _type            = _substring_array[1];
        var _line            = _substring_array[2];
        var _indent          = _substring_array[3];
        
        var _instruction = undefined;
        
        if (__CHATTERBOX_DEBUG_COMPILER) __chatterbox_trace("ln ", string_format(_line, 4, 0), " ", __chatterbox_generate_indent(_indent), _string);
        
        if (string_copy(_string, 1, 2) == "->") //Shortcut //TODO - Make this part of the substring splitting step
        {
            var _instruction = new __chatterbox_class_instruction("shortcut", _line, _indent);
            _instruction.text = __chatterbox_remove_whitespace(__chatterbox_remove_whitespace(string_delete(_string, 1, 2), true), false);
        }
        else if (_type == "action")
        {
            #region <<action>>
            
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
                case "set":
                case "call":
                    var _instruction = new __chatterbox_class_instruction(_first_word, _line, _indent);
                    _instruction.expression = __chatterbox_parse_expression(_remainder, false);
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
                    var _instruction = new __chatterbox_class_instruction("action", _line, _indent);
                    _instruction.expression = __chatterbox_parse_expression(_string, true);
                break;
            }
            
            #endregion
        }
        else if (_type == "option")
        {
            #region [[option]]
            
            var _pos = string_pos("|", _string);
            if (_pos < 1)
            {
                var _instruction = new __chatterbox_class_instruction("goto", _line, _indent);
                _instruction.destination = __chatterbox_remove_whitespace(__chatterbox_remove_whitespace(_string, true), false);
            }
            else
            {
                var _instruction = new __chatterbox_class_instruction("option", _line, _indent);
                _instruction.text = __chatterbox_remove_whitespace(string_copy(_string, 1, _pos-1), false);
                _instruction.destination = __chatterbox_remove_whitespace(string_delete(_string, 1, _pos), true);
            }
            
            #endregion
        }
        else
        {
            var _instruction = new __chatterbox_class_instruction("content", _line, _indent);
            _instruction.text = _string;
        }
        
        if (_instruction != undefined)
        {
            __chatterbox_instruction_add(_previous_instruction, _instruction);
            _previous_instruction = _instruction;
        }
        
        ++_s;
    }
}



/// @param string
/// @param allowActionSyntax
function __chatterbox_parse_expression(_string, _action_syntax)
{
    var _tokens = [];
    
    var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
    buffer_write(_buffer, buffer_string, _string);
    
    var _read_start   = 0;
    var _state        = 0;
    var _next_state   = 0;
    var _last_byte    = 0;
    var _new          = false;
    var _change_state = true;
    
    var _b = 0;
    repeat(buffer_get_size(_buffer))
    {
        var _byte = buffer_peek(_buffer, _b, buffer_u8);
        _next_state = (_byte == 0)? -1 : 0;
        _change_state = true;
        _new = false;
        
        switch(_state)
        {
            case 1: //Word/Variable Name
                #region
                
                if (_byte == 46) //.
                {
                    _next_state = 1;
                }
                else if ((_byte >= 48) && (_byte <= 57)) //0 1 2 3 4 5 6 7 8 9
                {
                    _next_state = 1;
                }
                else if ((_byte >= 65) && (_byte <= 90)) //a b c...x y z
                {
                    _next_state = 1;
                }
                else if (_byte == 95) //_
                {
                    _next_state = 1;
                }
                else if ((_byte >= 97) && (_byte <= 122)) //A B C...X Y Z
                {
                    _next_state = 1;
                }
                else if (_byte == 40) //(
                {
                    _next_state = 1;
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
                }
                
                #endregion
            break;
            
            case 2: //Quote-delimited String
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
                    _next_state = 2; //Quote-delimited String
                }
                
                #endregion
            break;
            
            case 3: //Number
                #region
                
                if (_byte == 46) //.
                {
                    _next_state = 3;
                }
                else if ((_byte >= 48) && (_byte <= 57)) //0 1 2 3 4 5 6 7 8 9
                {
                    _next_state = 3;
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
            
            case 4: //Symbol
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
                        _next_state = 4; //Symbol
                    }
                }
                else if ((_byte == 38) && (_last_byte == 38)) //&
                {
                    _next_state = 4; //Symbol
                }
                else if ((_byte == 124) && (_last_byte == 124)) //|
                {
                    _next_state = 4; //Symbol
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
        
        if (_change_state && (_next_state == 0))
        {
            #region
            
            //TODO - Compress this down
            if (_byte == 33) //!
            {
                _next_state = 4; //Symbol
            }
            else if ((_byte == 34) && (_last_byte != 92)) //"
            {
                _next_state = 2; //Quote-delimited String
            }
            else if (_byte == 36) //$
            {
                _next_state = 1; //Word/Variable Name
            }
            else if ((_byte == 37) || (_byte == 38)) //% &
            {
                _next_state = 4; //Symbol
            }
            else if ((_byte == 40) || (_byte == 41)) //( )
            {
                _next_state = 4; //Symbol
            }
            else if ((_byte == 42) || (_byte == 43)) //* +
            {
                _next_state = 4; //Symbol
            }
            else if (_byte == 44) //,
            {
                _next_state = 4; //Symbol
            }
            else if (_byte == 45) //-
            {
                _next_state = 4; //Symbol
            }
            else if (_byte == 46) //.
            {
                _next_state = 3; //Number
            }
            else if (_byte == 47) // /
            {
                _next_state = 4; //Symbol
            }
            else if ((_byte >= 48) && (_byte <= 57)) //0 1 2 3 4 5 6 7 8 9
            {
                _next_state = 3; //Number
            }
            else if ((_byte == 60) || (_byte == 61) || (_byte == 62)) //< = >
            {
                _next_state = 4; //Symbol
            }
            else if ((_byte >= 65) && (_byte <= 90)) //a b c...x y z
            {
                _next_state = 1; //Word/Variable Name
            }
            else if (_byte == 95) //_
            {
                _next_state = 1; //Word/Variable Name
            }
            else if ((_byte >= 97) && (_byte <= 122)) //A B C...X Y Z
            {
                _next_state = 1; //Word/Variable Name
            }
            else if (_byte == 124) // |
            {
                _next_state = 4; //Symbol
            }
            
            #endregion
        }
        
        if (_new || (_state != _next_state)) _read_start = _b;
        _state = _next_state;
        if (_state < 0) break;
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
                --_t; //Correct for token deletion
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
                    --_t; //Correct for token deletion
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