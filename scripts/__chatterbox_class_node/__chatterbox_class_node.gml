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
            #region <<action>>   (includes if/elseif/endif)
            
            var _parsed_expression = __chatterbox_parse_expression(_string);
            switch(_parsed_expression.instruction)
            {
                case "set":
                    var _instruction = new __chatterbox_class_instruction("set", _line, _indent);
                    _instruction.expression = _parsed_expression.expression;
                break;
                
                case "if":
                    if (_previous_instruction.line == _line)
                    {
                        _previous_instruction.condition = _parsed_expression.expression;
                        //We *don't* make a new instruction for the if-statement, just attach it to the previous instruction as a condition
                    }
                    else
                    {
                        var _instruction = new __chatterbox_class_instruction("if", _line, _indent);
                        _instruction.condition = _parsed_expression.expression;
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
                    
                case "elseif":
                case "else if":
                    var _instruction = new __chatterbox_class_instruction("else if", _line, _indent);
                    _instruction.condition = _parsed_expression.expression;
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
                    
                case "endif":
                case "end if":
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
                    var _instruction = new __chatterbox_class_instruction("wait", _line, _indent);
                break;
                
                case "stop":
                    var _instruction = new __chatterbox_class_instruction("stop", _line, _indent);
                break;
                    
                default:
                    var _instruction = new __chatterbox_class_instruction("action", _line, _indent);
                    _instruction.expression = _parsed_expression.expression;
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
function __chatterbox_parse_expression(_string)
{
    _string = __chatterbox_remove_whitespace(__chatterbox_remove_whitespace(_string, true), false);
    
    if (_string == "end if")
    {
        if (CHATTERBOX_ERROR_NONSTANDARD_SYNTAX) __chatterbox_error("<<end if>> is non-standard Yarn syntax, please use <<endif>>\n \n(Set CHATTERBOX_ERROR_NONSTANDARD_SYNTAX to <false> to hide this error)");
        return { instruction : _string };
    }
    else if ((_string == "wait") || (_string == "stop"))
    {
        return { instruction : _string };
    }
    
    var _instruction = "expression";
    if (string_copy(_string, 1, 3) == "if ")
    {
        _string = string_delete(_string, 1, 3);
        _instruction = "if";
    }
    else if (string_copy(_string, 1, 4) == "set ")
    {
        _string = string_delete(_string, 1, 4);
        _instruction = "set";
    }
    else if (string_copy(_string, 1, 7) == "elseif ")
    {
        _string = string_delete(_string, 1, 7);
        _instruction = "elseif";
    }
    else if (string_copy(_string, 1, 8) == "else if ")
    {
        if (CHATTERBOX_ERROR_NONSTANDARD_SYNTAX) __chatterbox_error("<<else if>> is non-standard Yarn syntax, please use <<elseif>>\n \n(Set CHATTERBOX_ERROR_NONSTANDARD_SYNTAX to <false> to hide this error)");
    }
    
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
                
                if ((_byte >= 48) && (_byte <= 57)) //0 1 2 3 4 5 6 7 8 9
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
                
                if (_state != _next_state)
                {
                    buffer_poke(_buffer, _b, buffer_u8, 0);
                    buffer_seek(_buffer, buffer_seek_start, _read_start);
                    var _read = buffer_read(_buffer, buffer_string);
                    buffer_poke(_buffer, _b, buffer_u8, _byte);
                    
                    //Convert friendly humand-readable operators into symbolic operators
                    var _is_symbol = false;
                    switch(_read)
                    {
                        case "and": _read = "&&"; _is_symbol = true; break;
                        case "le" : _read = "<";  _is_symbol = true; break;
                        case "gt" : _read = ">";  _is_symbol = true; break;
                        case "or" : _read = "||"; _is_symbol = true; break;
                        case "leq": _read = "<="; _is_symbol = true; break;
                        case "geq": _read = ">="; _is_symbol = true; break;
                        case "eq" : _read = "=="; _is_symbol = true; break;
                        case "is" : _read = "=="; _is_symbol = true; break;
                        case "neq": _read = "!="; _is_symbol = true; break;
                        case "to" : _read = "=";  _is_symbol = true; break;
                        case "not": _read = "!";  _is_symbol = true; break;
                    }
                    
                    if (_is_symbol)
                    {
                        __chatterbox_array_add(_tokens, { op : _read });
                    }
                    else
                    {
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
                        else if (string_copy(_read, 1, 2) == "i.")
                        {
                            _scope = "internal";
                            _read = string_delete(_read, 1, 2);
                        }
                        else if (string_copy(_read, 1, 9) == "internal.")
                        {
                            _scope = "internal";
                            _read = string_delete(_read, 1, 9);
                        }
                        
                        __chatterbox_array_add(_tokens, { op : "var", scope : _scope, name : _read });
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
                        return { instruction : "error", expression : {} };
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
    
    show_message(_string + "\n\n" + string(_tokens));
    show_debug_message(_tokens);
    
    __chatterbox_compile_expression(_tokens, 0, array_length(_tokens)-1);
    
    show_message(_string + "\n\n" + string(_tokens));
    show_debug_message(_tokens);
    
    return { instruction : _instruction, expression : _tokens };
}



/// @param array
/// @param startIndex
/// @param endIndex
function __chatterbox_compile_expression(_source_array, _start, _end)
{
    //TODO - Handle function calls
    //Handle parentheses
    var _depth = 0;
    var _open = undefined;
    var _t = _start;
    while(_t <= _end)
    {
        var _token = _source_array[_t];
        if (is_struct(_token))
        {
            if (_token.op == "(")
            {
                ++_depth;
                if (_depth == 1)
                {
                    _open = _t;
                    
                    __chatterbox_array_delete(_source_array, _t);
                    --_t; //Correct for token deletion
                }
            }
            else if (_token.op == ")")
            {
                --_depth;
                if (_depth == 0)
                {
                    __chatterbox_array_delete(_source_array, _t);
                    --_t; //Correct for token deletion
                    
                    __chatterbox_compile_expression(_source_array, _open, _t);
                    _source_array[@ _open] = { op : "paren", a : _source_array[_open] };
                }
            }
        }
        
        ++_t;
    }
    
    //Scan for negation (! / NOT)
    var _t = _start;
    while(_t <= _end)
    {
        var _token = _source_array[_t];
        if (is_struct(_token))
        {
            if (_token.op == "!")
            {
                _token.a = _source_array[_t+1];
                __chatterbox_array_delete(_source_array, _t+1);
                --_t; //Correct for token deletion
            }
        }
        
        ++_t;
    }
    
    //Scan for negative signs
    var _t = _start;
    while(_t <= _end)
    {
        var _token = _source_array[_t];
        if (is_struct(_token))
        {
            if (_token.op == "-")
            {
                //If this token was preceded by a symbol (or nothing) then it's a negative sign
                if ((_t == _start) || (__chatterbox_string_is_symbol(_source_array[_t-1], true)))
                {
                    _token.op = "neg";
                    _token.a = _source_array[_t+1];
                    __chatterbox_array_delete(_source_array, _t+1);
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
        
        var _t = _start;
        while(_t <= _end)
        {
            var _token = _source_array[_t];
            if (is_struct(_token))
            {
                if (_token.op == _operator)
                {
                    _token.a = _source_array[_t-1];
                    _token.b = _source_array[_t+1];
                    
                    //Order of operation very important here!
                    __chatterbox_array_delete(_source_array, _t+1);
                    __chatterbox_array_delete(_source_array, _t-1);
                    
                    //Correct for token deletion
                    --_t;
                }
            }
            
            ++_t;
        }
        
        ++_o;
    }
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



/// @param string
function __chatterbox_tokenize_action__old(_string)
{
    var _content = [];
    
    if ((_string == "end if") || (_string == "else if"))
    {
        if (CHATTERBOX_ERROR_NONSTANDARD_SYNTAX) __chatterbox_error("<<" + _string + ">> is non-standard Yarn syntax, please use <<endif>>\n \n(Set CHATTERBOX_ERROR_NONSTANDARD_SYNTAX to <false> to hide this error)");
        _content[0] = _string;
    }
    else
    {
        #region Break down string into tokens
        
        var _in_string = false;
        var _in_symbol = false;
        
        _string += " ";
        var _work_length = string_length(_string);
        var _work_char = "";
        var _work_char_prev = "";
        var _work_read_prev = 1;
        for(var _work_read = 1; _work_read <= _work_length; _work_read++)
        {
            var _read = false;
            var _read_add_char = 0;
            var _read_parse_operator = false;
            
            _work_char_prev = _work_char;
            var _work_char = string_char_at(_string, _work_read);
            
            if (_in_string)
            {
                //Ignore all behaviours until we hit a quote mark
                if (_work_char == "\"") && (_work_char_prev != "\\")
                {
                    _read_add_char = 1; //Make sure we get the quote mark in the string
                    _in_string = false;
                    _read = true;
                    //show_debug_message("  found closing quote mark");
                }
            }
            else if (_work_char == "\"") && (_work_char_prev != "\\")
            {
                //If we've got an unescaped quote mark, start a string
                _in_string = true;
                _read = true;
                //show_debug_message("  found open quote mark");
            }
            else if (_work_char == "!")
                 || (_work_char == "=")
                 || (_work_char == "<")
                 || (_work_char == ">")
                 || (_work_char == "+")
                 || (_work_char == "-")
                 || (_work_char == "*")
                 || (_work_char == "/")
                 || (_work_char == "&")
                 || (_work_char == "|")
                 || (_work_char == "^")
                 || (_work_char == "`")
            {
                if (!_in_symbol)
                {
                    //If we've found an operator symbol then do a standard read and begin reading a symbol
                    _in_symbol = true;
                    _read = true;
                    //show_debug_message("  found symbol start");
                }
            }
            else if (_in_symbol)
            {
                //If we're reading a symbol but this character *isn't* a symbol character, do a read
                _in_symbol = false;
                _read = true;
                _read_parse_operator = true;
                //show_debug_message("  found symbol end");
            }
            else if (_work_char == " ")
                    || (_work_char == ",")
            {
                //Always read at spaces and commas
                _read = true;
                //show_debug_message("  found space or comma");
            }
            else if (_work_char == "(") || (_work_char == ")")
            {
                //Always read at brackets
                _read = true;
                //show_debug_message("  found bracket");
            }
            else if (_work_char_prev == "(") || (_work_char_prev == ")")
            {
                //Always read at brackets
                _read = true;
                //show_debug_message("  found bracket pt.2");
            }
            
            if (_read)
            {
                var _out_string = string_copy(_string, _work_read_prev, _work_read + _read_add_char - _work_read_prev);
                //show_debug_message("    copied \"" + _out_string + "\"");
                _out_string = __chatterbox_remove_whitespace(_out_string, true);
                _out_string = __chatterbox_remove_whitespace(_out_string, false);
                _out_string = string_replace_all(_out_string, "\\\"", "\""); //Replace \" with "
                
                switch(_out_string)
                {
                    case "and": _out_string = "&&"; break;
                    case "&"  : _out_string = "&&"; break;
                    case "le" : _out_string = "<";  break;
                    case "gt" : _out_string = ">";  break;
                    case "or" : _out_string = "||"; break;
                    case "`"  : _out_string = "||"; break;
                    case "|"  : _out_string = "||"; break;
                    case "leq": _out_string = "<="; break;
                    case "geq": _out_string = ">="; break;
                    case "eq" : _out_string = "=="; break;
                    case "is" : _out_string = "=="; break;
                    case "neq": _out_string = "!="; break;
                    case "to" : _out_string = "=";  break;
                    case "not": _out_string = "!";  break;
                }
                
                if (_out_string != "")
                {
                    _content[array_length(_content)] = _out_string;
                    if (array_length(_content) == 1)
                    {
                        _content[1] = undefined; //Reserve a slot for the top-level node in the evaluation tree
                        _content[2] = "()";      //Reserve a slot for the generic function token
                    }
                }
                 
                _work_read_prev = _work_read + _read_add_char;
            }
        }
        
        #endregion
        
        #region BUild evaluation tree
        
        var _content_length = array_length(_content);
        var _eval_tree_root = array_create(_content_length-3);
        for(var _i = 3; _i < _content_length; _i++) _eval_tree_root[_i-3] = _i;
        _content[1] = _eval_tree_root;
        _content[2] = "()";
        
        var _queue = ds_list_create();
        ds_list_add(_queue, 1);
        
        repeat(9999)
        {
            if (ds_list_empty(_queue)) break;
            
            var _element_index = _queue[| 0];
            ds_list_delete(_queue, 0);
            
            var _element = _content[_element_index];
            if (!is_array(_element)) continue;
            var _element_length = array_length(_element);
            
            var _break = false;
            for(var _op = 0; _op < ds_list_size(global.__chatterbox_op_list); _op++)
            {
                var _operator = global.__chatterbox_op_list[| _op];
                
                for(var _e = _element_length-1; _e > 0; _e--) //Go backwards. This solves issues with nested brackets
                {
                    var _value = _content[_element[_e]];
                    
                    if (_value == _operator)
                    {
                        if (_operator == "(")
                        {
                            #region Split up bracketed expressions
                            
                            //Find the first close bracket token
                            for(var _f = _e+1; _f < _element_length; _f++) if (_content[_element[_f]] == ")") break;
                            
                            if (_f < _element_length)
                            {
                                var _function = undefined;
                                if (_e > 0)
                                {
                                    _function = _content[_element[_e-1]];
                                    if (!is_string(_function) || (_function == "()") || (ds_list_find_index(global.__chatterbox_op_list, _function) >= 0)) _function = undefined;
                                }
                                
                                if (_function == undefined)
                                {
                                    //Standard "structural" bracket
                                            
                                    var _new_element = [];
                                    array_copy(_new_element, 0,   _element, _e+1, _f-_e-1);
                                            
                                    _content[array_length(_content)] = _new_element; //Add the new sub-array to the overall content array
                                    ds_list_add(_queue, array_length(_content)-1);   //Add the index of the new sub-array to the processing queue
                                            
                                    _replacement_element = array_create(_element_length + _e - _f); //Create a new element array
                                    array_copy(_replacement_element, 0,   _element, 0, _e);
                                    _replacement_element[_e] = array_length(_content)-1; //Set the index of the new sub-array in the replacement element array
                                    array_copy(_replacement_element, _e+1,   _element, _f+1, _element_length-_f);
                                    
                                    _content[_element_index] = _replacement_element;
                                    ds_list_add(_queue, _element_index); //Add the index of the replacement array to the processing queue
                                }
                                else
                                {
                                    //Function call
                                    
                                    var _new_element = [_element[_e-1], 2];
                                    array_copy(_new_element, 2,   _element, _e+1, _f-_e-1);
                                    
                                    _content[array_length(_content)] = _new_element; //Add the new sub-array to the overall content array
                                    ds_list_add(_queue, array_length(_content)-1);   //Add the index of the new sub-array to the processing queue
                                    
                                    _replacement_element = array_create(_element_length - 1 + _e - _f); //Create a new element array
                                    array_copy(_replacement_element, 0,   _element, 0, _e-1);
                                    _replacement_element[_e-1] = array_length(_content)-1; //Set the index of the new sub-array in the replacement element array
                                    array_copy(_replacement_element, _e+1,   _element, _f+1, _element_length-_f);
                                    
                                    _content[_element_index] = _replacement_element;
                                    ds_list_add(_queue, _element_index); //Add the index of the replacement array to the processing queue
                                }
                            }
                            else
                            {
                                //Error!
                                __chatterbox_error("Syntax error");
                                _content[_element_index] = undefined;
                            }
                            
                            #endregion
                        }
                        else if (_operator == "!") || ((_operator == "-") && (_op == global.__chatterbox_negative_op_index))
                        {
                            #region Unary operators
                            
                            if (_e < _element_length-1) //For a unary operator, we cannot be the last element
                            {
                                var _new_element = [];
                                array_copy(_new_element, 0,   _element, _e, 2);
                                
                                _content[array_length(_content)] = _new_element; //Add the new sub-array to the overall content array
                                ds_list_add(_queue, array_length(_content)-1);   //Add the index of the new sub-array to the processing queue
                                
                                _replacement_element = array_create(_element_length-1); //Create a new element array
                                array_copy(_replacement_element, 0,   _element, 0, _e);
                                _replacement_element[_e] = array_length(_content)-1; //Set the index of the new sub-array in the replacement element array
                                array_copy(_replacement_element, _e+1,   _element, _e+2, _element_length-(_e+2));
                                
                                _content[_element_index] = _replacement_element;
                                ds_list_add(_queue, _element_index); //Add the index of the replacement array to the processing queue
                            }
                            else
                            {
                                //Error!
                                __chatterbox_error("Syntax error");
                                _content[_element_index] = undefined;
                            }
                            
                            #endregion
                        }
                        else
                        {
                            #region Binary operators
                            
                            if (_element_length < 3) //For a binary operator, we need at least three tokens in the array
                            {
                                if !((_operator == "-") && (_op == 8) && (_e == 0)) //Don't report this error if the subtraction sign might be a negative sign
                                {
                                    //Error!
                                    __chatterbox_error("Syntax error");
                                    _content[_element_index] = undefined;
                                }
                            }
                            else if (_e <= 0) || (_e >= _element_length-1) //A binary operator must be in-between two tokens
                            {
                                if !((_operator == "-") && (_op == 8) && (_e == 0)) //Don't report this error if the subtraction sign might be a negative sign
                                {
                                    //Error!
                                    __chatterbox_error("Syntax error");
                                    _content[_element_index] = undefined;
                                }
                            }
                            else if (_element_length > 3)
                            {
                                var _replacement_element = [_element[0],
                                                            _element[_e],
                                                            _element[_element_length-1]];
                                
                                //Split up the left-hand side of the array
                                if (_e > 1)
                                {
                                    var _new_element = [];
                                    array_copy(_new_element, 0,   _element, 0, _e);
                                    
                                    _content[array_length(_content)] = _new_element;    //Add the new sub-array to the overall content array
                                    ds_list_add(_queue, array_length(_content)-1);      //Add the index of the new sub-array to the processing queue
                                    _replacement_element[0] = array_length(_content)-1; //Set the index of the new sub-array in the replacement element array
                                }
                                
                                //Split up the right-hand side of the array
                                if (_e < _element_length-2)
                                {
                                    var _new_element = [];
                                    array_copy(_new_element, 0,   _element, _e+1, _element_length-_e-1);
                                    
                                    _content[array_length(_content)] = _new_element;    //Add the new sub-array to the overall content array
                                    ds_list_add(_queue, array_length(_content)-1);      //Add the index of the new sub-array to the processing queue
                                    _replacement_element[2] = array_length(_content)-1; //Set the index of the new sub-array in the replacement element array
                                }
                                
                                _content[_element_index] = _replacement_element;
                            }
                            else
                            {
                                //No action needed
                            }
                            
                            #endregion
                        }
                        
                        _break = true;
                        break;
                    }
                }
                
                if (_break) break;
            }
        }
        
        ds_list_destroy(_queue);
        
        #endregion
    }
    
    return _content;
}