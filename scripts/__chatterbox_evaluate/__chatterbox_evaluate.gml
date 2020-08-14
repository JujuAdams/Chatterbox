/// Takes a syntax tree and evaluate it
///
/// This is an internal script, please don't modify it.
///
/// @param localScope
/// @param filename
/// @param contentArray

function __chatterbox_evaluate(_local_scope, _filename, _content)
{
    var _resolved_array = array_create(array_length(_content), pointer_null); //Copy the array
    
    var _queue = ds_list_create();
    ds_list_add(_queue, 1);
    repeat(9999)
    {
        if (ds_list_empty(_queue)) break;
        
        var _element_index = _queue[| 0];
        var _element = _content[_element_index];
        
        if (!is_array(_element))
        {
            _resolved_array[_element_index] = _element;
            ds_list_delete(_queue, 0);
        }
        else
        {
            #region Check if all elements have been resolved
            
            var _fully_resolved = true;
            var _element_length = array_length(_element);
            for(var _i = 0; _i < _element_length; _i++)
            {
                var _child_index = _element[_i];
                if (is_ptr(_resolved_array[_child_index]) && (_resolved_array[_child_index] == pointer_null))
                {
                    _fully_resolved = false;
                    ds_list_insert(_queue, 0, _child_index);
                }
            }
            
            #endregion
            
            if (_fully_resolved)
            {
                if ((_element_length >= 2) && (_resolved_array[_element[1]] == "()"))
                {
                    #region Function execution
                    
                    var _result = undefined;
                    var _function_name = _resolved_array[_element[0]];
                    
                    var _function_args = array_create(_element_length-2);
                    for(var _i = 2; _i < _element_length; _i++) _function_args[_i-2] = __chatterbox_resolve_value(_local_scope, _resolved_array[_element[_i]], false);
                    
                    if (_function_name == "visited")
                    {
                        if (_element_length == 3) _function_args[1] = _filename;
                        _result = CHATTERBOX_VARIABLES_MAP[? "visited(" + _function_args[1] + CHATTERBOX_FILENAME_SEPARATOR + _function_args[0] + ")"];
                        _result = (_result == undefined)? false : _result;
                    }
                    else
                    {
                        var _method = global.__chatterbox_functions[? _function_name];
                        if (is_method(_method))
                        {
                            with(_local_scope)
                            {
                                var _result = _method(_function_args);
                            }
                            
                            if (!is_numeric(_result) && !is_string(_result))
                            {
                                var _typeof = typeof(_result);
                                if (CHATTERBOX_ERROR_INVALID_DATATYPE)
                                {
                                    __chatterbox_error("Variable \"" + _result + "\" has an unsupported datatype (" + _typeof + ")");
                                }
                                else
                                {
                                    __chatterbox_trace("Warning! Variable \"" + _result + "\" has an unsupported datatype (" + _typeof + ")");
                                }
                                
                                _result = string(_result);
                            }
                        }
                        else if (is_undefined(_method))
                        {
                            __chatterbox_error("Function definition for \"", _function_name, "\" not found");
                        }
                        else
                        {
                            __chatterbox_error("Function definition for \"", _function_name, "\" is invalid (datatype=", typeof(_method), ")");
                        }
                    }
                    
                    _resolved_array[_element_index] = is_string(_result)? ("\"" + string(_result) + "\"") : string(_result);
                    
                    #endregion
                }
                else if (_element_length == 1)
                {
                    #region Resolve 1-length elements (usually a static value, but you never know)
                    
                    var _result = undefined;
                    var _element_value = _element[0];
                    if (is_numeric(_element_value))
                    {
                        _resolved_array[_element_index] = _resolved_array[_element[0]];
                    }
                    else
                    {
                        _resolved_array[_element_index] = _element[0];
                    }
                    
                    #endregion
                }
                else if (_element_length == 2)
                {
                    #region Resolve unary operators (!variable / -variable)
                    
                    var _operator = _resolved_array[_element[0]];
                    var _value    = _resolved_array[_element[1]];
                        _value    = __chatterbox_resolve_value(_local_scope, _value, false);
                    
                    var _result = undefined;
                    if (is_numeric(_value))
                    {
                        if (_operator == "!")
                        {
                            _result = !_value;
                        }
                        else if (_operator == "-")
                        {
                            _result = -_value;
                        }
                        else
                        {
                            __chatterbox_trace("Warning! 2-length evaluation element with unrecognised operator: \"" + string(_operator) + "\"");
                        }
                    }
                    
                    _resolved_array[_element_index] = is_string(_result)? ("\"" + string(_result) + "\"") : string(_result);
                    
                    #endregion
                }
                else if (_element_length == 3)
                {
                    #region Figure out datatypes and grab variable values
                    
                    var _a        = _resolved_array[_element[0]];
                    var _operator = _resolved_array[_element[1]];
                    var _b        = _resolved_array[_element[2]];
                    
                    var _result = undefined;
                    var _set = false;
                    switch(_operator)
                    {
                        case "/=":
                        case "*=":
                        case "-=":
                        case "=":
                        case "+=":
                            _set = true;
                        break;
                    }
                    
                    var _a_value = __chatterbox_resolve_value(_local_scope, _a, _set);
                    var _a_scope = global.__chatterbox_scope;
                    _a = (global.__chatterbox_variable_name != __CHATTERBOX_VARIABLE_INVALID)? global.__chatterbox_variable_name : _a;
                    global.__chatterbox_scope = undefined;
                    
                    var _b_value = __chatterbox_resolve_value(_local_scope, _b, false);
                    
                    #endregion
                    
                    #region Resolve binary operators
                    
                    if (!_set)
                    {
                        var _both_real         = (is_numeric(_a_value) && is_numeric(_b_value));
                        var _matching_types    = (typeof(_a_value) == typeof(_b_value));
                        var _either_string     = (is_string(_a_value) || is_string(_b_value));
                        var _neither_undefined = (!is_undefined(_a_value) && !is_undefined(_b_value));
                        
                        if (!_matching_types)
                        {
                            if (_operator != "+") && (_operator != "+=") && (_operator != "==") && (_operator != "!=")
                            {
                                if (CHATTERBOX_ERROR_MISMATCHED_DATATYPE)
                                {
                                    __chatterbox_error("Mismatched datatypes");
                                }
                                else
                                {
                                    __chatterbox_trace("Error! Mismatched datatypes");
                                }
                            }
                        }
                    }
                    
                    switch(_operator)
                    {
                        case "/": if (_both_real) _result = _a_value / _b_value; break;
                        case "*": if (_both_real) _result = _a_value * _b_value; break;
                        case "-": if (_both_real) _result = _a_value - _b_value; break;
                        case "+":
                            if (_neither_undefined)
                            {
                                _result = (_either_string)? (string(_a_value) + string(_b_value)) : (_a_value + _b_value);
                            }
                        break;
                        
                        case "/=": if (_both_real) _result = _a_value / _b_value; break;
                        case "*=": if (_both_real) _result = _a_value * _b_value; break;
                        case "-=": if (_both_real) _result = _a_value - _b_value; break;
                        case "=":                  _result =            _b_value; break;
                        case "+=":
                            if (_neither_undefined)
                            {
                                _result = (_either_string)? (string(_a_value) + string(_b_value)) : (_a_value + _b_value);
                            }
                        break;
                        
                        case "||": _result = _both_real?      (_a_value || _b_value) : false; break;
                        case "&&": _result = _both_real?      (_a_value && _b_value) : false; break;
                        case ">=": _result = _both_real?      (_a_value >= _b_value) : false; break;
                        case "<=": _result = _both_real?      (_a_value <= _b_value) : false; break;
                        case ">":  _result = _both_real?      (_a_value >  _b_value) : false; break;
                        case "<":  _result = _both_real?      (_a_value <  _b_value) : false; break;
                        case "!=": _result = _matching_types? (_a_value != _b_value) : true;  break;
                        case "==": _result = _matching_types? (_a_value == _b_value) : false; break;
                    }
                    
                    if (_set)
                    {
                        switch(_a_scope)
                        {                   
                            case "internal": CHATTERBOX_VARIABLES_MAP[? _a] = _result; break;
                            case "local":    variable_instance_set(_local_scope, _a, _result); break;
                            case "global":   variable_global_set(_a, _result);         break;
                        }
                    }
                    
                    _resolved_array[_element_index] = is_string(_result)? ("\"" + string(_result) + "\"") : string(_result);
                    
                    #endregion
                }
                
                ds_list_delete(_queue, 0);
            }
        }
    }
    
    ds_list_destroy(_queue);
    
    return __chatterbox_resolve_value(_local_scope, _resolved_array[1], false);
}

/// @param localScope
/// @param value
/// @param amSetting
function __chatterbox_resolve_value(_local_scope, _in_value, _am_setting)
{
    var _value = _in_value;
    
    global.__chatterbox_scope         = undefined;
    global.__chatterbox_variable_name = __CHATTERBOX_VARIABLE_INVALID;
    
    if (is_numeric(_value))
    {
        //It's a number!
        return _value;
    }
    else if (!is_string(_value))
    {
        __chatterbox_error("__chatterbox_resolve_value() given invalid datatype (", typeof(_value), ")");
        return undefined;
    }
    else if (string_char_at(_value, 1) == "\"") && (string_char_at(_value, string_length(_value)) == "\"")
    {
        //It's a string!
        return string_copy(_value, 2, string_length(_value)-2);
    }
    else
    {
        //Figure out if this value is a real
        try
        {
            _value = real(_value);
            var _variable = false;
        }
        catch(_)
        {
            var _variable = true;
        }
        
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
                _scope = "global";
                _value = string_delete(_value, 1, 2);
            }
            else if (string_copy(_value, 1, 7) == "global.")
            {
                _scope = "global";
                _value = string_delete(_value, 1, 7);
            }
            else if (string_copy(_value, 1, 2) == "s.")
            {
                _scope = "local";
                _value = string_delete(_value, 1, 2);
            }
            else if (string_copy(_value, 1, 6) == "local.")
            {
                _scope = "local";
                _value = string_delete(_value, 1, 6);
            }
            else if (string_copy(_value, 1, 2) == "i.")
            {
                _scope = "internal";
                _value = string_delete(_value, 1, 2);
            }
            else if (string_copy(_value, 1, 9) == "internal.")
            {
                _scope = "internal";
                _value = string_delete(_value, 1, 9);
            }
            
            global.__chatterbox_scope = _scope;
            global.__chatterbox_variable_name = _value;
            
            #endregion
            
            if (_am_setting)
            {
                _value = undefined;
            }
            else
            {
                #region Collect variable value depending on scope and check its datatype
                
                switch(_scope)
                {                   
                    case "internal":
                        if (!ds_map_exists(CHATTERBOX_VARIABLES_MAP, _value))
                        {
                            if (CHATTERBOX_ERROR_MISSING_VARIABLE_GET)
                            {
                                __chatterbox_error("Internal variable \"" + _value + "\" doesn't exist");
                            }
                            else
                            {
                                __chatterbox_trace("Warning! Internal variable \"" + _value + "\" doesn't exist");
                            }
                            
                            _value = CHATTERBOX_DEFAULT_VARIABLE_VALUE;
                        }
                        else
                        {
                            _value = CHATTERBOX_VARIABLES_MAP[? _value ];
                        }
                    break;
                    
                    case "local":
                        if (!variable_instance_exists(_local_scope, _value))
                        {
                            if (CHATTERBOX_ERROR_MISSING_VARIABLE_GET)
                            {
                                __chatterbox_error("Local variable \"" + _value + "\" doesn't exist");
                            }
                            else
                            {
                                __chatterbox_trace("Warning! Local variable \"" + _value + "\" doesn't exist");
                            }
                            
                            _value = CHATTERBOX_DEFAULT_VARIABLE_VALUE;
                        }
                        else
                        {
                            _value = variable_instance_get(_local_scope, _value);
                        }
                    break;
                    
                    case "global":
                        if (!variable_global_exists(_value))
                        {
                            if (CHATTERBOX_ERROR_MISSING_VARIABLE_GET)
                            {
                                __chatterbox_error("Global variable \"" + _value + "\" doesn't exist!");
                            }
                            else
                            {
                                __chatterbox_trace("Warning! Global variable \"" + _value + "\" doesn't exist");
                            }
                            
                            _value = CHATTERBOX_DEFAULT_VARIABLE_VALUE;
                        }
                        else
                        {
                            _value = variable_global_get(_value);
                        }
                    break;
                }
                
                if (!is_numeric(_value) && !is_string(_value))
                {
                    var _typeof = typeof(_value);
                    if (CHATTERBOX_ERROR_INVALID_DATATYPE)
                    {
                        __chatterbox_error("Variable \"" + _value + "\" has an unsupported datatype (" + _typeof + ")");
                    }
                    else
                    {
                        __chatterbox_trace("Error! Variable \"" + _value + "\" has an unsupported datatype (" + _typeof + ")");
                    }
                    
                    _value = string(_value);
                }
                
                #endregion
            }
        }
    }
    
    return _value;
}