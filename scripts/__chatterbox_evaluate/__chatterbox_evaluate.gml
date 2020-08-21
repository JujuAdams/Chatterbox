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
            case "internal":
                if (!ds_map_exists(CHATTERBOX_VARIABLES_MAP, _expression.name))
                {
                    if (CHATTERBOX_ERROR_MISSING_VARIABLE_GET)
                    {
                        __chatterbox_error("Internal variable \"" + _expression.name + "\" doesn't exist");
                    }
                    else
                    {
                        __chatterbox_trace("Warning! Internal variable \"" + _expression.name + "\" doesn't exist");
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
                        __chatterbox_error("Local variable \"" + _expression.name + "\" doesn't exist");
                    }
                    else
                    {
                        __chatterbox_trace("Warning! Local variable \"" + _expression.name + "\" doesn't exist");
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
                        __chatterbox_error("Global variable \"" + _expression.name + "\" doesn't exist!");
                    }
                    else
                    {
                        __chatterbox_trace("Warning! Global variable \"" + _expression.name + "\" doesn't exist");
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
            _a = __chatterbox_evaluate(_local_scope, _filename, _expression.a);
        break;
        
        case "func":
        //TODO
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
        
        case "/=": _a /= _b; _set = true; break;
        case "*=": _a *= _b; _set = true; break;
        case "-=": _a -= _b; _set = true; break;
        case "+=": _a += _b; _set = true; break;
        case "=":  _a  = _b; _set = true; break;
        
        default: return undefined; break;
    }
    
    if (_set)
    {
        switch(_a.scope)
        {                   
            case "internal": CHATTERBOX_VARIABLES_MAP[? _a.name] = _b; break;
            case "local":    variable_instance_set(_local_scope, _a.name, _b); break;
            case "global":   variable_global_set(_a.name, _b); break;
        }
        
        return _a;
    }
    
    return undefined;
}