/// Takes a syntax tree and evaluate it
///
/// This is an internal script, please don't modify it.
///
/// @param localScope
/// @param filename
/// @param expression

function __chatterbox_evaluate(_local_scope, _filename, _expression)
{
    if (!is_struct(_expression)) return _expression;
    
    if (_expression.op == "var")
    {
        #region
        
        var _value = undefined;
        switch(_expression.scope)
        {
            case "yarn":
                if (!ds_map_exists(CHATTERBOX_VARIABLES_MAP, _expression.name))
                {
                    if (CHATTERBOX_ERROR_MISSING_VARIABLE_GET)
                    {
                        __chatterbox_error("Yarn variable \"" + _expression.name + "\" can't be read because it doesn't exist");
                    }
                    else
                    {
                        __chatterbox_trace("Warning! Yarn variable \"" + _expression.name + "\" can't be read because it doesn't exist");
                    }
                    
                    _value = CHATTERBOX_DEFAULT_VARIABLE_VALUE;
                }
                else
                {
                    _value = CHATTERBOX_VARIABLES_MAP[? _expression.name];
                }
            break;
            
            case "local":
                if (!variable_instance_exists(_local_scope, _expression.name))
                {
                    if (CHATTERBOX_ERROR_MISSING_VARIABLE_GET)
                    {
                        __chatterbox_error("Local variable \"" + _expression.name + "\" can't be read because it doesn't exist");
                    }
                    else
                    {
                        __chatterbox_trace("Warning! Local variable \"" + _expression.name + "\" can't be read because it doesn't exist");
                    }
                    
                    _value = CHATTERBOX_DEFAULT_VARIABLE_VALUE;
                }
                else
                {
                    _value = variable_instance_get(_local_scope, _expression.name);
                }
            break;
            
            case "global":
                if (!variable_global_exists(_expression.name))
                {
                    if (CHATTERBOX_ERROR_MISSING_VARIABLE_GET)
                    {
                        __chatterbox_error("Global variable \"" + _expression.name + "\" can't be read because it doesn't exist!");
                    }
                    else
                    {
                        __chatterbox_trace("Warning! Global variable \"" + _expression.name + "\" can't be read because it doesn't exist");
                    }
                    
                    _value = CHATTERBOX_DEFAULT_VARIABLE_VALUE;
                }
                else
                {
                    _value = variable_global_get(_expression.name);
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
        
        return _value;
        
        #endregion
    }
    
    var _a = undefined;
    var _b = undefined;
    
    switch(_expression.op)
    {
        case "/":
        case "*":
        case "-":
        case "+":
        case "||":
        case "&&":
        case ">=":
        case "<=":
        case ">":
        case "<":
        case "!=":
        case "==":
        case "/=":
        case "*=":
        case "-=":
        case "+=":
            _a = __chatterbox_evaluate(_local_scope, _filename, _expression.a);
            _b = __chatterbox_evaluate(_local_scope, _filename, _expression.b);
        break;
        
        case "!":
        case "neg":
        case "paren":
        case "param":
            _a = __chatterbox_evaluate(_local_scope, _filename, _expression.a);
        break;
        
        case "func":
            var _parameters = _expression.parameters;
            var _parameter_values = array_create(array_length(_parameters), undefined);
            var _p = 0;
            repeat(array_length(_parameters))
            {
                _parameter_values[@ _p] = __chatterbox_evaluate(_local_scope, _filename, _parameters[_p]);
                ++_p;
            }
        break;
        
        case "=":
            _b = __chatterbox_evaluate(_local_scope, _filename, _expression.b);
        break;
    }
    
    var _set = false;
    switch(_expression.op)
    {
        case "/":  return _a /  _b; break;
        case "*":  return _a *  _b; break;
        case "-":  return _a -  _b; break;
        case "+":  return _a +  _b; break;
        case "||": return _a || _b; break;
        case "&&": return _a && _b; break;
        case ">=": return _a >= _b; break;
        case "<=": return _a <= _b; break;
        case ">":  return _a >  _b; break;
        case "<":  return _a <  _b; break;
        case "!=": return _a != _b; break;
        case "==": return _a == _b; break;
        
        case "!":     return !_a; break;
        case "neg":   return -_a; break;
        case "paren": return  _a; break;
        case "param": return  _a; break;
        
        case "func":
            if (_expression.name == "visited")
            {
                return chatterbox_visited(_parameter_values[0], _filename);
            }
            else
            {
                var _method = global.__chatterbox_functions[? _expression.name];
                
                if (is_method(_method))
                {
                    with(_local_scope) return _method(_parameter_values);
                }
                else
                {
                    if (CHATTERBOX_ERROR_MISSING_FUNCTION)
                    {
                        __chatterbox_error("Function \"", _expression.name, "\" not defined with chatterbox_add_function()");
                    }
                    else
                    {
                        __chatterbox_trace("Error! Function \"", _expression.name, "\" not defined with chatterbox_add_function()");
                    }
                }
                
                return undefined;
            }
        break;
        
        case "/=": _a /= _b; _set = true; break;
        case "*=": _a *= _b; _set = true; break;
        case "-=": _a -= _b; _set = true; break;
        case "+=": _a += _b; _set = true; break;
        case "=":  _a  = _b; _set = true; break;
    }
    
    if (_set)
    {
        switch(_expression.a.scope)
        {                   
            case "yarn":
                CHATTERBOX_VARIABLES_MAP[? _expression.a.name] = _a;
                __chatterbox_trace("Set Yarn variable \"", _expression.a.name, "\" to ", _a);
            break;
            
            case "local":
                variable_instance_set(_local_scope, _expression.a.name, _a);
                __chatterbox_trace("Set local variable \"", _expression.a.name, "\" to ", _a, " (local scope=", _local_scope, ")");
            break;
            
            case "global":
                variable_global_set(_expression.a.name, _a);
                __chatterbox_trace("Set global variable \"", _expression.a.name, "\" to ", _a);
            break;
        }
        
        return _a;
    }
    
    return undefined;
}