/// Takes a syntax tree and evaluate it
///
/// This is an internal script, please don't modify it.
///
/// @param localScope
/// @param filename
/// @param expression
/// @param behaviour

function __chatterbox_evaluate(_local_scope, _filename, _expression, _behaviour)
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
                    __chatterbox_error("Yarn variable \"" + _expression.name + "\" can't be read because it doesn't exist");
                }
                else
                {
                    _value = CHATTERBOX_VARIABLES_MAP[? _expression.name];
                }
            break;
            
            case "local":
                if (!variable_instance_exists(_local_scope, _expression.name))
                {
                    __chatterbox_error("Local variable \"" + _expression.name + "\" can't be read because it doesn't exist");
                }
                else
                {
                    _value = variable_instance_get(_local_scope, _expression.name);
                }
            break;
            
            case "global":
                if (!variable_global_exists(_expression.name))
                {
                    __chatterbox_error("Global variable \"" + _expression.name + "\" can't be read because it doesn't exist!");
                }
                else
                {
                    _value = variable_global_get(_expression.name);
                }
            break;
        }
        
        if (!is_numeric(_value) && !is_string(_value) && !is_bool(_value))
        {
            var _typeof = typeof(_value);
            __chatterbox_error("Variable \"" + _value + "\" has an unsupported datatype (" + _typeof + ")");
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
            _a = __chatterbox_evaluate(_local_scope, _filename, _expression.a, undefined);
            _b = __chatterbox_evaluate(_local_scope, _filename, _expression.b, undefined);
        break;
        
        case "!":
        case "neg":
        case "paren":
        case "param":
            _a = __chatterbox_evaluate(_local_scope, _filename, _expression.a, undefined);
        break;
        
        case "func":
            var _parameters = _expression.parameters;
            var _parameter_values = array_create(array_length(_parameters), undefined);
            var _p = 0;
            repeat(array_length(_parameters))
            {
                _parameter_values[@ _p] = __chatterbox_evaluate(_local_scope, _filename, _parameters[_p], undefined);
                ++_p;
            }
        break;
        
        case "=":
            _b = __chatterbox_evaluate(_local_scope, _filename, _expression.b, undefined);
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
                    if (CHATTERBOX_FUNCTION_ARRAY_ARGUMENTS)
                    {
                        with (_local_scope) return _method(_parameter_values);
                    }
                    else
                    {
                        switch (array_length(_parameter_values))
                        {
                            case 0:
                                with(_local_scope) return _method();
                                break;
                            case 1:
                                with(_local_scope) return _method(_parameter_values[0]);
                                break;
                            case 2:
                                with(_local_scope) return _method(_parameter_values[0], _parameter_values[1]);
                                break;
                            case 3:
                                with(_local_scope) return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2]);
                                break;
                            case 4:
                                with(_local_scope) return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3]);
                                break;
                            case 5:
                                with(_local_scope) return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4]);
                                break;
                            case 6:
                                with(_local_scope) return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5]);
                                break;
                            case 7:
                                with(_local_scope) return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6]);
                                break;
                            case 8:
                                with(_local_scope) return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7]);
                                break;
                            case 9:
                                with(_local_scope) return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8]);
                                break;
                            case 10:
                                with(_local_scope) return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9]);
                                break;
                            case 11:
                                with(_local_scope) return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10]);
                                break;
                            case 12:
                                with(_local_scope) return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11]);
                                break;
                            case 13:
                                with(_local_scope) return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12]);
                                break;
                            case 14:
                                with(_local_scope) return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12], _parameter_values[13]);
                                break;
                            case 15:
                                with(_local_scope) return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12], _parameter_values[13], _parameter_values[14]);
                                break;
                            case 16:
                                with(_local_scope) return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12], _parameter_values[13], _parameter_values[14], _parameter_values[15]);
                                break;
                        }
                    }
                }
                else
                {
                    __chatterbox_error("Function \"", _expression.name, "\" not defined with chatterbox_add_function()");
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
        if ((_behaviour != "declare") && (_behaviour != "set"))
        {
            __chatterbox_error("Cannot set/declare variable \"", _expression.a.name, "\" outside of a <<set>> or <<declare>> command");
        }
        else
        {
            switch(_expression.a.scope)
            {                   
                case "yarn":
                    if (_behaviour == "declare")
                    {
                        if (ds_map_exists(CHATTERBOX_VARIABLES_MAP, _expression.a.name))
                        {
                            __chatterbox_trace("Warning! Trying to re-declare Yarn variable (", _expression.a.name, " = ", __chatterbox_readable_value(_a), ") but it already has a value (", __chatterbox_readable_value(CHATTERBOX_VARIABLES_MAP[? _expression.a.name]), ")");
                        }
                        else
                        {
                            CHATTERBOX_VARIABLES_MAP[? _expression.a.name] = _a;
                            __chatterbox_trace("Declared Yarn variable \"", _expression.a.name, "\" as ", __chatterbox_readable_value(_a));
                        }
                    }
                    else if (_behaviour == "set")
                    {
                        if (!ds_map_exists(CHATTERBOX_VARIABLES_MAP, _expression.a.name))
                        {
                            __chatterbox_trace("Warning! Trying to set Yarn variable \"", _expression.a.name, "\" but it has not been declared");
                        }
                        
                        CHATTERBOX_VARIABLES_MAP[? _expression.a.name] = _a;
                        __chatterbox_trace("Set Yarn variable \"", _expression.a.name, "\" to ", __chatterbox_readable_value(_a));
                    }
                break;
                
                case "local":
                    if (_behaviour == "declare")
                    {
                        if (variable_instance_exists(_local_scope, _expression.a.name))
                        {
                            __chatterbox_trace("Warning! Trying to re-declare local variable (", _expression.a.name, " = ", __chatterbox_readable_value(_a), ") but it already has a value (", __chatterbox_readable_value(variable_instance_get(_local_scope, _expression.a.name)), ", local scope=", _local_scope, ")");
                        }
                        else
                        {
                            variable_instance_set(_local_scope, _expression.a.name, _a);
                            __chatterbox_trace("Declared local variable \"", _expression.a.name, "\" as ", __chatterbox_readable_value(_a), " (local scope=", _local_scope, ")");
                        }
                    }
                    else if (_behaviour == "set")
                    {
                        if (!variable_instance_exists(_local_scope, _expression.a.name))
                        {
                            __chatterbox_trace("Warning! Trying to set local variable \"", _expression.a.name, "\" but it has not been declared (local scope=", _local_scope, ")");
                        }
                        
                        variable_instance_set(_local_scope, _expression.a.name, _a);
                        __chatterbox_trace("Set local variable \"", _expression.a.name, "\" to ", __chatterbox_readable_value(_a), " (local scope=", _local_scope, ")");
                    }
                break;
                
                case "global":
                    if (_behaviour == "declare")
                    {
                        if (variable_global_exists(_expression.a.name))
                        {
                            __chatterbox_trace("Warning! Trying to re-declare global variable (", _expression.a.name, " = ", __chatterbox_readable_value(_a), ") but it already has a value (", __chatterbox_readable_value(variable_global_get(_expression.a.name)), ")");
                        }
                        else
                        {
                            variable_instance_set(_local_scope, _expression.a.name, _a);
                                __chatterbox_trace("Declared global variable \"", _expression.a.name, "\" as ", __chatterbox_readable_value(_a));
                        }
                    }
                    else if (_behaviour == "set")
                    {
                        if (!variable_global_exists(_expression.a.name))
                        {
                            __chatterbox_trace("Warning! Trying to set global variable \"", _expression.a.name, "\" but it has not been declared");
                        }
                        
                        variable_global_set(_expression.a.name, _a);
                        __chatterbox_trace("Set global variable \"", _expression.a.name, "\" to ", __chatterbox_readable_value(_a));
                    }
                break;
            }
        }
        
        return _a;
    }
    
    return undefined;
}