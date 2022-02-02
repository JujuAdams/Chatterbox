/// @param variableName

function ChatterboxVariableReset(_name)
{
    if (string_pos(" ", _name))
    {
        __ChatterboxError("Chatterbox variable names must not contain spaces (\"", _name, "\")");
        exit;
    }
    
    if (!ds_map_exists(global.__chatterboxDeclaredVariablesMap, _name))
    {
        if (string_copy(_name, 1, 8) != "visited(") //Don't throw an error for "node visited" variables
        {
            if (CHATTERBOX_ERROR_UNDECLARED_VARIABLE)
            {
                __ChatterboxError("Trying to reset Yarn variable $", _name, " but a default value has not been declared");
            }
            else
            {
                __ChatterboxTrace("Warning! Trying to reset Yarn variable $", _name, " but a default value has not been declared. Deleting variable instead");
            }
        }
        
        ds_map_delete(CHATTERBOX_VARIABLES_MAP, _name);
    }
    else if (!ds_map_exists(global.__chatterboxDefaultVariablesMap, _name))
    {
        //If we don't have a default value then just delete the variable
        //This can happen when <<set>> implicitly declares a variable on compile
        ds_map_delete(CHATTERBOX_VARIABLES_MAP, _name);
    }
    else
    {
        var _value = global.__chatterboxDefaultVariablesMap[? _name];
        CHATTERBOX_VARIABLES_MAP[? _name] = _value;
        __ChatterboxTrace("Reset Yarn variable $", _name, " to ", __ChatterboxReadableValue(_value));
    }
}