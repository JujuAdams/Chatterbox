/// Takes a syntax tree and evaluate it
///
/// This is an internal script, please don't modify it.
///
/// @param filename
/// @param contentArray

function __chatterbox_evaluate(_filename, _content)
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
	                var _function = _resolved_array[_element[0]];
                    
	                var _function_args = array_create(_element_length-2);
	                for(var _i = 2; _i < _element_length; _i++) _function_args[_i-2] = __chatterbox_resolve_value(_resolved_array[_element[_i]]);
                    
	                if (_function == "visited")
	                {
	                    if (_element_length == 3) _function_args[1] = _filename;
	                    _result = CHATTERBOX_VARIABLES_MAP[? "visited(" + _function_args[1] + CHATTERBOX_FILENAME_SEPARATOR + _function_args[0] + ")" ];
	                    _result = (_result == undefined)? false : _result;
	                }
	                else
	                {
	                    _function = global.__chatterbox_permitted_functions[? _function ];
	                    if (_function != undefined)
	                    {
	                        _result = script_execute(_function, _function_args);
                            
	                        var _typeof = typeof(_result);
	                        if ((_typeof == "array") || (_typeof == "ptr") || (_typeof == "null") || (_typeof == "vec3") || (_typeof == "vec4") || (_typeof == "struct") || (_typeof == "method") || (_typeof == "unknown"))
	                        {
	                            if (CHATTERBOX_ERROR_ON_INVALID_DATATYPE)
	                            {
	                                __chatterbox_error("Variable \"" + _result + "\" has an unsupported datatype (" + _typeof + ")");
	                            }
	                            else
	                            {
	                                __chatterbox_trace("WARNING! Variable \"" + _result + "\" has an unsupported datatype (" + _typeof + ")");
	                            }
                                
	                            _result = string(_result);
	                        }
                            
	                        if (_typeof == "bool") || (_typeof == "int32") || (_typeof == "int64")
	                        {
	                            _result = real(_result);
	                        }
	                    }
	                    else
	                    {
	                        //Error!
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
	                if (is_real(_element_value))
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
	                    _value    = __chatterbox_resolve_value(_value);
                    
	                var _result = undefined;
	                if (is_real(_value))
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
	                        __chatterbox_trace("WARNING! 2-length evaluation element with unrecognised operator: \"" + string(_operator) + "\"");
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
                    
	                var _a_value = __chatterbox_resolve_value(_a);
	                var _a_scope = global.__chatterbox_scope;
	                _a = (global.__chatterbox_variable_name != __CHATTERBOX_VARIABLE_INVALID)? global.__chatterbox_variable_name : _a;
	                global.__chatterbox_scope = CHATTERBOX_SCOPE_INVALID;
	                var _b_value = __chatterbox_resolve_value(_b);
                    
                    #endregion
                    
                    #region Resolve binary operators
                    
	                var _result = undefined;
	                var _set = false;
                    
	                var _both_real         = (is_real(_a_value) && is_real(_b_value));
	                var _matching_types    = (typeof(_a_value) == typeof(_b_value));
	                var _either_string     = (is_string(_a_value) || is_string(_b_value));
	                var _neither_undefined = (!is_undefined(_a_value) && !is_undefined(_b_value));
                    
	                if (!_matching_types)
	                {
	                    if (_operator != "+") && (_operator != "+=") && (_operator != "==") && (_operator != "!=")
	                    {
	                        if (CHATTERBOX_ERROR_ON_MISMATCHED_DATATYPE)
	                        {
	                            __chatterbox_error("Mismatched datatypes");
	                        }
	                        else
	                        {
	                            __chatterbox_trace("WARNING! Mismatched datatypes");
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
                        
	                    case "/=": _set = true; if (_both_real) _result = _a_value / _b_value; break;
	                    case "*=": _set = true; if (_both_real) _result = _a_value * _b_value; break;
	                    case "-=": _set = true; if (_both_real) _result = _a_value - _b_value; break;
	                    case "=":  _set = true;                 _result =            _b_value; break;
	                    case "+=":
	                        _set = true;
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
	                        case CHATTERBOX_SCOPE_INTERNAL:   CHATTERBOX_VARIABLES_MAP[? _a ] = _result; break;
	                        case CHATTERBOX_SCOPE_GML_LOCAL:  variable_instance_set(id, _a, _result);    break;
	                        case CHATTERBOX_SCOPE_GML_GLOBAL: variable_global_set(_a, _result);          break;
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
    
	return __chatterbox_resolve_value(_resolved_array[1]);
}