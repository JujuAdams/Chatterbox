// Feather disable all
/// @param string
/// @param useAltDirectionSyntax

function __ChatterboxParseExpression(_string, _alt_direction_syntax)
{
    enum __CHATTERBOX_TOKEN
    {
        NULL       = -1,
        UNKNOWN    =  0,
        IDENTIFIER =  1,
        STRING     =  2,
        NUMBER     =  3,
        SYMBOL     =  4,
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
            case __CHATTERBOX_TOKEN.IDENTIFIER: //Identifier (variable/function)
                #region
                
                if ((_byte == ord(","))
                ||  (_byte == ord(")"))
                ||  (_byte == ord(">"))
                ||  (_byte == ord("<"))
                ||  (_byte == ord("=")))
                {
                    _next_state = __CHATTERBOX_TOKEN.SYMBOL;
                }
                else if ((_byte > 32) && (_byte != ord("$"))) //Everything is permitted, except whitespace and a dollar sign
                {
                    _next_state = __CHATTERBOX_TOKEN.IDENTIFIER;
                }
                
                
                if ((_state != _next_state) || (_last_byte == ord("("))) //Cheeky hack to find functions
                {
                    var _is_symbol   = false;
                    var _is_number   = false;
                    var _is_function = (_last_byte == ord("(")); //Cheeky hack to find functions
                    
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
                        array_push(_tokens, { op : _read });
                    }
                    else if (_is_number)
                    {
                        array_push(_tokens, _read);
                    }
                    else if (_is_function)
                    {
                        _read = string_copy(_read, 1, string_length(_read)-1); //Trim off the open bracket
                        array_push(_tokens, { op : "func", name : _read });
                    }
                    else
                    {
                        if (string_char_at(_read, 1) == "$")
                        {
                            _read = string_delete(_read, 1, 1);
                            array_push(_tokens, { op : "var", name : _read });
                        }
                        else if (_alt_direction_syntax)
                        {
                            array_push(_tokens, _read);
                        }
                        else
                        {
                            __ChatterboxError("Token (", _read, ") is invalid:\n- Variables and constants must be prefixed with a $ sign\n- Strings must be delimited with \" quote marks\nIf this token is a function call, please check CHATTERBOX_ACTION_MODE is set correctly");
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
                    
                    if (CHATTERBOX_ESCAPE_EXPRESSION_STRINGS) _read = __ChatterboxUnescapeString(_read);
                    
                    array_push(_tokens, _read);
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
                        __ChatterboxError("Error whilst converting expression value to real\n \n(", _error, ")");
                        return undefined;
                    }
                    
                    array_push(_tokens, _read);
                    
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
                    
                    array_push(_tokens, { op : _read });
                    
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
                _next_state = __CHATTERBOX_TOKEN.IDENTIFIER; //Word/Variable Name
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
                _next_state = __CHATTERBOX_TOKEN.IDENTIFIER; //Word/Variable Name
            }
            else if (_byte == 95) //_
            {
                _next_state = __CHATTERBOX_TOKEN.IDENTIFIER; //Word/Variable Name
            }
            else if ((_byte >= 97) && (_byte <= 122)) //A B C...X Y Z
            {
                _next_state = __CHATTERBOX_TOKEN.IDENTIFIER; //Word/Variable Name
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
    
    __ChatterboxCompileExpression(_tokens);
    
    if (array_length(_tokens) < 1)
    {
        __ChatterboxError("No valid expression tokens found (", _string, ")");
    }
    else
    {
        if (!_alt_direction_syntax)
        {
            if (array_length(_tokens) > 1)
            {
                __ChatterboxError("Expression could not be fully resolved into a single token (", _string, ")");
            }
            else
            {
                return _tokens[0];
            }
        }
        else
        {
            var _name = _tokens[0];
            array_delete(_tokens, 0, 1);
            return { op : "func", name : _name, parameters : _tokens };
        }
    }
}



/// @param array
/// @param startIndex
/// @param endIndex
function __ChatterboxCompileExpression(_source_array)
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
                        array_delete(_source_array, _open, 1);
                        --_t;
                    }
                    
                    _sub_expression_start = _open;
                }
            }
            else if (_token.op == ",")
            {
                if (_depth == 1)
                {
                    var _sub_array = __ChatterboxArrayCopyPart(_source_array, _sub_expression_start, _t - _sub_expression_start);
                    array_delete(_source_array, _sub_expression_start, array_length(_sub_array));
                    __ChatterboxCompileExpression(_sub_array);
                    
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
                    var _sub_array = __ChatterboxArrayCopyPart(_source_array, _sub_expression_start, _t - _sub_expression_start);
                    array_delete(_source_array, _sub_expression_start, array_length(_sub_array));
                    __ChatterboxCompileExpression(_sub_array);
                    
                    if (array_length(_sub_array) > 0)
                    {
                        _source_array[@ _sub_expression_start] = { op : "paren", a : _sub_array[0] };
                    }
                    else
                    {
                        _source_array[@ _sub_expression_start] = undefined;
                    }
                    
                    if (_is_function)
                    {
                        if (array_length(_sub_array) > 0)
                        {
                            var _parameters = __ChatterboxArrayCopyPart(_source_array, _open, 1 + _sub_expression_start - _open);
                            array_delete(_source_array, _open, 1 + _sub_expression_start - _open);
                            _source_array[_open - 1].parameters = _parameters;
                        }
                        else
                        {
                            array_delete(_source_array, _open, 1 + _sub_expression_start - _open);
                            _source_array[_open - 1].parameters = [];
                        }
                        
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
                array_delete(_source_array, _t+1, 1);
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
                if ((_t == 0) || (__chatterboxTokenIsSymbol(_source_array[_t-1], true)))
                {
                    _token.op = "neg";
                    _token.a = _source_array[_t+1];
                    array_delete(_source_array, _t+1, 1);
                }
            }
        }
        
        ++_t;
    }
    
    var _o = 0;
    repeat(ds_list_size(global.__chatterboxOpList))
    {
        var _operator = global.__chatterboxOpList[| _o];
        
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
                    array_delete(_source_array, _t+1, 1);
                    array_delete(_source_array, _t-1, 1);
                    
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
function __chatterboxTokenIsSymbol(_token, _ignore_close_paren)
{
    if (is_struct(_token))
    {
        var _string = _token.op;
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
    }
    
    return false;
}
