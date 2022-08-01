/// @param localScope
/// @param filename
/// @param expression
/// @param behaviour

function __ChatterboxEvaluate(_local_scope, _filename, _expression, _behaviour)
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
                if (_filename == undefined)
                {
                    return 0;
                }
                else
                {
                    return ChatterboxGetVisited(_parameter_values[0], _filename);
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
                            var _func = method_get_index(_func);
                            var _self = method_get_self(_func) ?? self;
                            
                            with(_self) {
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
        
        if ((_behaviour != "declare") && (_behaviour != "declare valueless") && (_behaviour != "set"))
        {
            __ChatterboxError("Cannot set/declare variable \"", _variable_name, "\" outside of a <<set>> or <<declare>> command");
        }
        else
        {
            if (_behaviour == "declare valueless")
            {
                if (!ds_map_exists(global.__chatterboxDeclaredVariablesMap, _variable_name))
                {
                    global.__chatterboxDeclaredVariablesMap[? _variable_name] = true;
                    ds_list_add(CHATTERBOX_VARIABLES_LIST, _variable_name);
                }
            }
            else if (_behaviour == "declare")
            {
                ChatterboxVariableDefault(_variable_name, _a);
            }
            else if (_behaviour == "set")
            {
                ChatterboxVariableSet(_variable_name, _a);
            }
        }
        
        return _a;
    }
    
    return undefined;
}