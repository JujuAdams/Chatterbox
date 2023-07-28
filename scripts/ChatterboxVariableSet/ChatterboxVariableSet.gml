// Feather disable all
/// Sets the value of the Chatterbox variable with the given name
/// Chatterbox variables are only strings, numbers, or booleans
/// 
/// @param variableName
/// @param value

function ChatterboxVariableSet(_name, _value)
{
    if (string_pos(" ", _name))
    {
        __ChatterboxError("Chatterbox variable names must not contain spaces (\"", _name, "\")");
        exit;
    }
    
    if (!is_numeric(_value) && !is_string(_value) && !is_bool(_value))
    {
        __ChatterboxError("Chatterbox variable values must be a number, a string, or a boolean (variable = ", _name, ", datatype = \"", typeof(_value), "\", value = ", _value, ")");
        exit;
    }
    
    if (ds_map_exists(global.__chatterboxConstantsMap, _name) && global.__chatterboxConstantsMap[? _name])
    {
        __ChatterboxError("Trying to set Chatterbox variable $", _name, " but it has been declared as a constant");
    }
    
    if (!ds_map_exists(global.__chatterboxDeclaredVariablesMap, _name))
    {
        if (CHATTERBOX_ERROR_UNDECLARED_VARIABLE)
        {
            __ChatterboxError("Trying to set Chatterbox variable $", _name, " but it has not been declared");
        }
        else
        {
            __ChatterboxTrace("Warning! Trying to set Chatterbox variable $", _name, " but it has not been declared");
        }
    }
    else
    {
        if (!__ChatterboxVerifyDatatypes(global.__chatterboxVariablesMap[? _name], _value))
        {
            __ChatterboxError("Cannot set $", _name, " = ", __ChatterboxReadableValue(_value), ", its datatype does not match existing value (", __ChatterboxReadableValue(global.__chatterboxVariablesMap[? _name]), ")");
        }
    }
    
    global.__chatterboxVariablesMap[? _name] = _value;
    global.__chatterboxConstantsMap[? _name] = false;
    if (CHATTERBOX_VERBOSE) __ChatterboxTrace("Set Chatterbox variable $", _name, " to ", __ChatterboxReadableValue(_value));
}
