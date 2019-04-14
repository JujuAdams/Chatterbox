/// @param chatterbox
/// @param value

var _chatterbox = argument0;
var _value      = argument1;

var _filename      = _chatterbox[| __CHATTERBOX.FILENAME  ];
var _variables_map = _chatterbox[| __CHATTERBOX.VARIABLES ];

//Look for a prefixed ! to indicate negation
var _negate = false;
if (string_char_at(_value, 1) == "!")
{
    _negate = true;
    _value = string_delete(_value, 1, 1);
}
                                
if (string_char_at(_value, 1) == "\"") && (string_char_at(_value, string_length(_value)) == "\"")
{
    //It's a string!
    _value = string_copy(_value, 2, string_length(_value)-2);
}
else
{
    var _variable = false;
                                    
    #region Figure out if this value is a real
                                    
    var _hit_number = false;
    var _j = string_length(_value);
    repeat(string_length(_value))
    {
        var _character = string_char_at(_value, _j);
        if (_character == "0") || (_character == "1") || (_character == "2") || (_character == "3")
        || (_character == "4") || (_character == "5") || (_character == "6") || (_character == "7")
        || (_character == "8") || (_character == "9") || (_character == ".") || (_character == "-")
        {
            _hit_number = true;
        }
        else
        {
            _variable = true;
            break;
        }
        _j--;
    }
                                    
    if (!_variable)
    {
        if (string_count("-", _value) > 1) _variable = true;
        if (string_count(".", _value) > 1) _variable = true;
                                        
        var _negative_pos = string_pos("-", _value);
        if (_negative_pos > 1) _variable = true;
        if (string_pos(".", _value) == (1+_negative_pos)) _variable = true;
                                        
        if (!_variable) _value = real(_value);
    }
                                    
    #endregion
                                    
    #region Figure out if this value is a keyword: true / false / undefined / null
                                    
    if (_variable)
    {
        if (_value == "true")
        {
            _value = true;
            _variable = false;
        }
        else if (_value == "false")
        {
            _value = false;
            _variable = false;
        }
        else if (_value == "undefined") || (_value == "null")
        {
            _value = undefined;
            _variable = false;
        }
    }
                                    
    #endregion
                                    
    if (_variable)
    {
        #region Find the variable's scope based on prefix
        
        var _scope = CHATTERBOX_NAKED_VARIABLE_SCOPE;
        
        if (string_char_at(_value, 1) == "$")
        {
            _scope = CHATTERBOX_DOLLAR_VARIABLE_SCOPE;
            _value = string_delete(_value, 1, 1);
        }
        else if (string_copy(_value, 1, 2) == "g.")
        {
            _scope = CHATTERBOX_SCOPE.GML_GLOBAL;
            _value = string_delete(_value, 1, 2);
        }
        else if (string_copy(_value, 1, 7) == "global.")
        {
            _scope = CHATTERBOX_SCOPE.GML_GLOBAL;
            _value = string_delete(_value, 1, 7);
        }
        else if (string_copy(_value, 1, 2) == "l.")
        {
            _scope = CHATTERBOX_SCOPE.GML_LOCAL;
            _value = string_delete(_value, 1, 2);
        }
        else if (string_copy(_value, 1, 6) == "local.")
        {
            _scope = CHATTERBOX_SCOPE.GML_LOCAL;
            _value = string_delete(_value, 1, 6);
        }
        else if (string_copy(_value, 1, 2) == "i.")
        {
            _scope = CHATTERBOX_SCOPE.INTERNAL;
            _value = string_delete(_value, 1, 2);
        }
        else if (string_copy(_value, 1, 9) == "internal.")
        {
            _scope = CHATTERBOX_SCOPE.INTERNAL;
            _value = string_delete(_value, 1, 9);
        }
        else if (string_copy(_value, 1, 9) == "visited(\"")
        {
            _scope = CHATTERBOX_SCOPE.INTERNAL;
            
            if (!CHATTERBOX_VISITED_NO_FILENAME)
            {
                //Make sure this visited() call has a filename attached to it
                var _pos = string_pos(CHATTERBOX_VISITED_SEPARATOR, _value);
                if (_pos <= 0) _value = string_insert(_filename + CHATTERBOX_VISITED_SEPARATOR, _value, 9);
            }
        }
        
        #endregion
        
        #region Collect variable value depending on scope and check its datatype
        
        switch(_scope)
        {                   
            case CHATTERBOX_SCOPE.INTERNAL:
                if (!ds_map_exists(_variables_map, _value))
                {
                    if (CHATTERBOX_ERROR_ON_MISSING_VARIABLE)
                    {
                        show_error("Chatterbox:\nInternal variable \"" + _value + "\" doesn't exist\n ", false);
                    }
                    else
                    {
                        show_debug_message("Chatterbox: WARNING! Internal variable \"" + _value + "\" doesn't exist");
                    }
                                                    
                    _value = CHATTERBOX_DEFAULT_VARIABLE_VALUE;
                }
                else
                {
                    _value = _variables_map[? _value ];
                }
            break;
            
            case CHATTERBOX_SCOPE.GML_LOCAL:
                if (!variable_instance_exists(id, _value))
                {
                    if (CHATTERBOX_ERROR_ON_MISSING_VARIABLE)
                    {
                        show_error("Chatterbox:\nLocal variable \"" + _value + "\" doesn't exist\n ", false);
                    }
                    else
                    {
                        show_debug_message("Chatterbox: WARNING! Local variable \"" + _value + "\" doesn't exist");
                    }
                                                    
                    _value = CHATTERBOX_DEFAULT_VARIABLE_VALUE;
                }
                else
                {
                    _value = variable_instance_get(id, _value);
                }
            break;
            
            case CHATTERBOX_SCOPE.GML_GLOBAL:
                if (!variable_global_exists(_value))
                {
                    if (CHATTERBOX_ERROR_ON_MISSING_VARIABLE)
                    {
                        show_error("Chatterbox:\nGlobal variable \"" + _value + "\" doesn't exist!\n ", false);
                    }
                    else
                    {
                        show_debug_message("Chatterbox: WARNING! Global variable \"" + _value + "\" doesn't exist");
                    }
                                                    
                    _value = CHATTERBOX_DEFAULT_VARIABLE_VALUE;
                }
                else
                {
                    _value = variable_global_get(_value);
                }
            break;
        }
        
        var _typeof = typeof(_value);
        if (_typeof == "array") || (_typeof == "ptr") || (_typeof == "null") || (_typeof == "vec3") || (_typeof == "vec4")
        {
            if (CHATTERBOX_ERROR_ON_INVALID_DATATYPE)
            {
                show_error("Chatterbox:\nVariable \"" + _value + "\" has an unsupported datatype (" + _typeof + ")\n ", false);
            }
            else
            {
                show_debug_message("Chatterbox: WARNING! Variable \"" + _value + "\" has an unsupported datatype (" + _typeof + ")");
            }
            
            _value = string(_value);
        }
        
        if (_typeof == "bool") || (_typeof == "int32") || (_typeof == "int64")
        {
            _value = real(_value);
        }
                                        
        #endregion
    }
}
                                
if (_negate)
{
    if (is_real(_value))
    {
        _value = !_value;
    }
    else if (is_string(_value))
    {
        _value = "";
    }
}

return _value;