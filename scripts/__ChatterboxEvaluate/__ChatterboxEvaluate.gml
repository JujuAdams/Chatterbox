/// @param localScope
/// @param filename
/// @param expression
/// @param behaviour

function __ChatterboxEvaluate(_local_scope, _filename, _expression, _behaviour)
{
    if (!is_struct(_expression)) return _expression;
    
    if (_expression.op == "var")
    {
        #region
        
        if (!ds_map_exists(CHATTERBOX_VARIABLES_MAP, _expression.name))
        {
            __ChatterboxError("Yarn variable \"" + _expression.name + "\" can't be read because it doesn't exist");
        }
        
        var _value = CHATTERBOX_VARIABLES_MAP[? _expression.name];
        
        if (!is_numeric(_value) && !is_string(_value) && !is_bool(_value))
        {
            var _typeof = typeof(_value);
            __ChatterboxError("Variable \"" + _value + "\" has an unsupported datatype (" + _typeof + ")");
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
            _a = __ChatterboxEvaluate(_local_scope, _filename, _expression.a, undefined);
            _b = __ChatterboxEvaluate(_local_scope, _filename, _expression.b, undefined);
        break;
        
        case "!":
        case "neg":
        case "paren":
        case "param":
            _a = __ChatterboxEvaluate(_local_scope, _filename, _expression.a, undefined);
        break;
        
        case "func":
            var _parameters = _expression.parameters;
            var _parameter_values = array_create(array_length(_parameters), undefined);
            var _p = 0;
            repeat(array_length(_parameters))
            {
                _parameter_values[@ _p] = __ChatterboxEvaluate(_local_scope, _filename, _parameters[_p], undefined);
                ++_p;
            }
        break;
        
        case "=":
            _b = __ChatterboxEvaluate(_local_scope, _filename, _expression.b, undefined);
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
                return ChatterboxGetVisited(_parameter_values[0], _filename);
            }
            else
            {
                var _method = global.__chatterboxFunctions[? _expression.name];
                if (is_method(_method))
                {
                    with (_local_scope)
                    {
                        if (CHATTERBOX_FUNCTION_ARRAY_ARGUMENTS)
                        {
                            return _method(_parameter_values);
                        }
                        else
                        {
                            switch (array_length(_parameter_values))
                            {
                                //Reductio Ad Overmars
                                //"Every GameMaker game has the pyramid of doom"
                                case  0: return _method();
                                case  1: return _method(_parameter_values[0]);
                                case  2: return _method(_parameter_values[0], _parameter_values[1]);
                                case  3: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2]);
                                case  4: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3]);
                                case  5: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4]);
                                case  6: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5]);
                                case  7: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6]);
                                case  8: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7]);
                                case  9: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8]);
                                case 10: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9]);
                                case 11: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10]);
                                case 12: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11]);
                                case 13: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12]);
                                case 14: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12], _parameter_values[13]);
                                case 15: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12], _parameter_values[13], _parameter_values[14]);
                                case 16: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12], _parameter_values[13], _parameter_values[14], _parameter_values[15]);
                            }
                        }
                    }
                }
                else
                {
                    __ChatterboxError("Function \"", _expression.name, "\" not defined with ChatterboxAddFunction()");
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
        var _variable_name = _expression.a.name;
        
        if ((_behaviour != "declare") && (_behaviour != "set"))
        {
            __ChatterboxError("Cannot set/declare variable \"", _variable_name, "\" outside of a <<set>> or <<declare>> command");
        }
        else
        {
            if (_behaviour == "declare")
            {
                if (ds_map_exists(CHATTERBOX_VARIABLES_MAP, _variable_name))
                {
                    __ChatterboxTrace("Warning! Trying to re-declare Yarn variable ($", _variable_name, " = ", __ChatterboxReadableValue(_a), ") but it already has a value (", __ChatterboxReadableValue(CHATTERBOX_VARIABLES_MAP[? _variable_name]), ")");
                }
                else
                {
                    CHATTERBOX_VARIABLES_MAP[? _variable_name] = _a;
                    __ChatterboxTrace("Declared Yarn variable $", _variable_name, " as ", __ChatterboxReadableValue(_a));
                }
            }
            else if (_behaviour == "set")
            {
                if (ds_map_exists(CHATTERBOX_VARIABLES_MAP, _variable_name))
                {
                    if (!__ChatterboxVerifyDatatypes(CHATTERBOX_VARIABLES_MAP[? _variable_name], _a))
                    {
                        __ChatterboxError("Cannot set $", _variable_name, " = ", __ChatterboxReadableValue(_a), ", its datatype does not match existing value (", __ChatterboxReadableValue(CHATTERBOX_VARIABLES_MAP[? _variable_name]), ")");
                    }
                }
                else
                {
                    __ChatterboxTrace("Warning! Trying to set Yarn variable $", _variable_name, " but it has not been declared");
                }
                
                CHATTERBOX_VARIABLES_MAP[? _variable_name] = _a;
                __ChatterboxTrace("Set Yarn variable $", _variable_name, " to ", __ChatterboxReadableValue(_a));
            }
        }
        
        return _a;
    }
    
    return undefined;
}