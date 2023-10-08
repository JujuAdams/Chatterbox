// Feather disable all
/// @param localScope
/// @param filename
/// @param expression
/// @param behaviour
/// @param optionUUID

function __ChatterboxEvaluate(_local_scope, _filename, _expression, _behaviour, _optionUUID)
{
    if (!is_struct(_expression)) return _expression;
    
    if (_expression.op == "var") return ChatterboxVariableGet(_expression.name);
    
    var _a = undefined;
    var _b = undefined;
    
    if (_behaviour == "declare valueless")
    {
        if ((_expression.op != "=") && (_expression.op != "paren")) return undefined;
    }
    else switch(_expression.op)
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
            _a = __ChatterboxEvaluate(_local_scope, _filename, _expression.a, undefined, _optionUUID);
            _b = __ChatterboxEvaluate(_local_scope, _filename, _expression.b, undefined, _optionUUID);
        break;
        
        case "!":
        case "neg":
        case "paren":
        case "param":
            _a = __ChatterboxEvaluate(_local_scope, _filename, _expression.a, undefined, _optionUUID);
        break;
        
        case "func":
            var _parameters = _expression.parameters;
            var _parameter_values = array_create(array_length(_parameters), undefined);
            var _p = 0;
            repeat(array_length(_parameters))
            {
                _parameter_values[@ _p] = __ChatterboxEvaluate(_local_scope, _filename, _parameters[_p], undefined, _optionUUID);
                ++_p;
            }
        break;
        
        case "=":
            _b = __ChatterboxEvaluate(_local_scope, _filename, _expression.b, undefined, _optionUUID);
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
                if (_filename == undefined)
                {
                    return 0;
                }
                else
                {
                    return ChatterboxGetVisited(_parameter_values[0], _filename);
                }
            }
            else if (_expression.name == "optionChosen")
            {
                if (_optionUUID == undefined)
                {
                    __ChatterboxError("Cannot use optionChosen() outside of a option condition");
                }
                else
                {
                    return global.__chatterboxVariablesMap[? __CHATTERBOX_OPTION_CHOSEN_PREFIX + _optionUUID];
                }
            }
            else
            {
                var _method = global.__chatterboxFunctions[? _expression.name];
                if (is_method(_method))
                {
                    if (_local_scope == undefined)
                    {
                        if (CHATTERBOX_ERROR_NO_LOCAL_SCOPE)
                        {
                            __ChatterboxError("No local scope available for execution\nThis usually happens when trying to execute a function in a <<declare>> command");
                        }
                        else
                        {
                            __ChatterboxTrace("No local scope available for execution. This usually happens when trying to execute a function in a <<declare>> command");
                        }
                        
                        return undefined;
                    }
                    
                    with (_local_scope)
                    {
                        if (CHATTERBOX_FUNCTION_ARRAY_ARGUMENTS)
                        {
                            return _method(_parameter_values);
                        }
                        else
                        {
                            // Since we can't just execute methods with multiple arguments as is
                            // we break it down instead to make it work with script_execute_ext
                            var _func = method_get_index(_method);
                            var _self = method_get_self(_method) ?? self;
                            
                            with(_self)
                            {
                                return script_execute_ext(_func, _parameter_values);    
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
        
        switch(_behaviour)
        {
            case "declare valueless":
                if (ds_map_exists(global.__chatterboxConstantsMap, _variable_name) && global.__chatterboxConstantsMap[? _variable_name])
                {
                    __ChatterboxError("Trying to declare Chatterbox variable $", _variable_name, " but it has already been declared as a constant");
                }
                else if (!ds_map_exists(global.__chatterboxDeclaredVariablesMap, _variable_name))
                {
                    global.__chatterboxDeclaredVariablesMap[? _variable_name] = true;
                    global.__chatterboxConstantsMap[? _variable_name] = false;
                    ds_list_add(global.__chatterboxVariablesList, _variable_name);
                }
            break;
            
            case "declare":
                ChatterboxVariableDefault(_variable_name, _a);
            break;
            
            case "set":
                ChatterboxVariableSet(_variable_name, _a);
            break;
            
            case "constant":
                ChatterboxVariableSetConstant(_variable_name, _a);
            break;
            
            default:
                __ChatterboxError("Cannot set/declare variable/constant $", _variable_name, " outside of a <<set>> or <<declare>> or <<constant>> command");
            break;
        }
        
        return _a;
    }
    
    return undefined;
}
