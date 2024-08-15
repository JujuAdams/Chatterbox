// Feather disable all

/// @param name
/// @param value

function __ChatterboxVariableSetInternal(_name, _value)
{
    static _system = __ChatterboxSystem();
    
    var _oldValue = _system.__variablesMap[? _name];
    _system.__variablesMap[? _name] = _value;
    
    if (is_undefined(_system.__variablesSetCallback))
    {
        //Do nothing!
    }
    else if (is_method(_system.__variablesSetCallback) || script_exists(_system.__variablesSetCallback))
    {
        _system.__variablesSetCallback(_name, _value, _oldValue);
    }
}