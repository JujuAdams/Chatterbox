/// Sets the default value of the Chatterbox variable with the given name
/// Chatterbox variables are only strings, numbers, or booleans
/// 
/// @param variableName
/// @param value

function ChatterboxVariableDefault(_name, _value)
{
    if (string_pos(" ", _name))
    {
        __ChatterboxError("Chatterbox variable names must not contain spaces (\"", _name, "\")");
        exit;
    }
    
    if (!is_numeric(_value) && !is_string(_value) && !is_bool(_value))
    {
        __ChatterboxError("Chatterbox variable values must be a number, a string, or a boolean (variable = \"", _name, "\", datatype = \"", typeof(_value), "\", value = ", _value, ")");
        exit;
    }
    
    if (ds_map_exists(global.__chatterboxDefaultVariablesMap, _name))
    {
        if (CHATTERBOX_ERROR_REDECLARED_VARIABLE)
        {
            __ChatterboxError("Trying to re-declare default value for Yarn variable $", _name, " (=", __ChatterboxReadableValue(_value), ")");
        }
        else
        {
            __ChatterboxTrace("Warning! Trying to re-declare default value for Yarn variable $", _name, " (=", __ChatterboxReadableValue(_value), ")");
        }
    }
    else
    {
        CHATTERBOX_VARIABLES_MAP[? _name] = _value;
        global.__chatterboxDefaultVariablesMap[? _name] = _value;
        global.__chatterboxDeclaredVariablesMap[? _name] = true;
        ds_list_add(CHATTERBOX_VARIABLES_LIST, _name);
        
        __ChatterboxTrace("Declared Yarn variable $", _name, " (= ", __ChatterboxReadableValue(_value), ")");
    }
}