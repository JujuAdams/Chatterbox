/// Sets the value of the Chatterbox variable with the given name
/// Chatterbox variables are only strings, numbers, or booleans
/// 
/// @param variableName
/// @param value

function ChatterboxVariableSet(_name, _value)
{
    if (!is_numeric(_value) && !is_string(_value) && !is_bool(_value))
    {
        __ChatterboxError("Chatterbox variable values must be a number, a string, or a boolean (variable = \"", _name, "\", datatype = \"", typeof(_value), "\", value = ", _value, ")");
        exit;
    }
    
    global.chatterboxVariablesMap[? _name] = _value;
}