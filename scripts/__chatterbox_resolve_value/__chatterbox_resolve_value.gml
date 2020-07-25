/// Takes a string and figures out if it's a real, a delimited string, or a variable
/// 
/// @param value

function __chatterbox_resolve_value(_value)
{
	global.__chatterbox_scope         = CHATTERBOX_SCOPE_INVALID;
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
	            _scope = CHATTERBOX_SCOPE_GML_GLOBAL;
	            _value = string_delete(_value, 1, 2);
	        }
	        else if (string_copy(_value, 1, 7) == "global.")
	        {
	            _scope = CHATTERBOX_SCOPE_GML_GLOBAL;
	            _value = string_delete(_value, 1, 7);
	        }
	        else if (string_copy(_value, 1, 2) == "l.")
	        {
	            _scope = CHATTERBOX_SCOPE_GML_LOCAL;
	            _value = string_delete(_value, 1, 2);
	        }
	        else if (string_copy(_value, 1, 6) == "local.")
	        {
	            _scope = CHATTERBOX_SCOPE_GML_LOCAL;
	            _value = string_delete(_value, 1, 6);
	        }
	        else if (string_copy(_value, 1, 2) == "i.")
	        {
	            _scope = CHATTERBOX_SCOPE_INTERNAL;
	            _value = string_delete(_value, 1, 2);
	        }
	        else if (string_copy(_value, 1, 9) == "internal.")
	        {
	            _scope = CHATTERBOX_SCOPE_INTERNAL;
	            _value = string_delete(_value, 1, 9);
	        }
            
	        global.__chatterbox_scope = _scope;
	        global.__chatterbox_variable_name = _value;
            
            #endregion
            
            #region Collect variable value depending on scope and check its datatype
            
	        switch(_scope)
	        {                   
	            case CHATTERBOX_SCOPE_INTERNAL:
	                if (!ds_map_exists(CHATTERBOX_VARIABLES_MAP, _value))
	                {
	                    if (CHATTERBOX_ERROR_ON_MISSING_VARIABLE)
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
                
	            case CHATTERBOX_SCOPE_GML_LOCAL:
	                if (!variable_instance_exists(id, _value))
	                {
	                    if (CHATTERBOX_ERROR_ON_MISSING_VARIABLE)
	                    {
	                        __chatterbox_error("Local variable \"" + _value + "\" doesn't exist");
	                    }
	                    else
	                    {
	                        __chatterbox_trace("WARNING! Local variable \"" + _value + "\" doesn't exist");
	                    }
                                                    
	                    _value = CHATTERBOX_DEFAULT_VARIABLE_VALUE;
	                }
	                else
	                {
	                    _value = variable_instance_get(id, _value);
	                }
	            break;
                
	            case CHATTERBOX_SCOPE_GML_GLOBAL:
	                if (!variable_global_exists(_value))
	                {
	                    if (CHATTERBOX_ERROR_ON_MISSING_VARIABLE)
	                    {
	                        __chatterbox_error("Global variable \"" + _value + "\" doesn't exist!");
	                    }
	                    else
	                    {
	                        __chatterbox_trace("WARNING! Global variable \"" + _value + "\" doesn't exist");
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
	            if (CHATTERBOX_ERROR_ON_INVALID_DATATYPE)
	            {
	                __chatterbox_error("Variable \"" + _value + "\" has an unsupported datatype (" + _typeof + ")");
	            }
	            else
	            {
	                __chatterbox_trace("Warning! Variable \"" + _value + "\" has an unsupported datatype (" + _typeof + ")");
	            }
            
	            _value = string(_value);
	        }
            
            #endregion
	    }
	}
    
	return _value;
}