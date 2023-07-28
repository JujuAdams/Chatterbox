// Feather disable all
/// Returns the value of the Chatterbox variable with the given name
/// Chatterbox variables are only strings, numbers, or booleans
/// If the variable doesn't exist, this function will return the given default value,
//  or CHATTERBOX_VARIABLE_MISSING_VALUE if no default value is specified
/// 
/// @param variableName
/// @param [defaultValue]

function ChatterboxVariableGet()
{
    var _name    = argument[0];
    var _default = (argument_count > 1)? argument[1] : CHATTERBOX_VARIABLE_MISSING_VALUE;
    
    if (string_pos(" ", _name))
    {
        __ChatterboxError("Chatterbox variable names must not contain spaces (\"", _name, "\")");
        exit;
    }
    
    if (!ds_map_exists(global.__chatterboxVariablesMap, _name))
    {
        if (CHATTERBOX_ERROR_UNSET_VARIABLE)
        {
            __ChatterboxError("Chatterbox variable \"", _name, "\" cannot be read because it has not been set");
        }
        else
        {
            __ChatterboxTrace("Warning! Chatterbox variable \"", _name, "\" cannot be read because it has not been set. Returning default value ", __ChatterboxReadableValue(_default));
        }
        
        return _default;
    }
    
    var _value = global.__chatterboxVariablesMap[? _name];
        
    if (!is_numeric(_value) && !is_string(_value) && !is_bool(_value))
    {
        var _typeof = typeof(_value);
        __ChatterboxError("Variable \"" + _name + "\" has an unsupported datatype (" + _typeof + " = ", __ChatterboxReadableValue(_value), ")");
    }
    
    return _value;
}
