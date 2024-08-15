// Feather disable all

/// @param name
/// @param value

function __ChatterboxVariableSetInternal(_name, _value)
{
    var _oldValue = global.__chatterboxVariablesMap[? _name];
    global.__chatterboxVariablesMap[? _name] = _value;
    
    if (is_undefined(global.__chatterboxVariablesSetCallback))
    {
        //Do nothing!
    }
    else if (is_method(global.__chatterboxVariablesSetCallback) || script_exists(global.__chatterboxVariablesSetCallback))
    {
        global.__chatterboxVariablesSetCallback(_name, _value, _oldValue);
    }
}