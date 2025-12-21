// Feather disable all

/// @param variableName

function ChatterboxVariableReset(_name)
{
    static _system = __ChatterboxSystem();
    
    //Internal variables just get cleaned up
    if ((string_copy(_name, 1, string_length(__CHATTERBOX_VISITED_PREFIX)) == __CHATTERBOX_VISITED_PREFIX)
    ||  (string_copy(_name, 1, string_length(__CHATTERBOX_OPTION_CHOSEN_PREFIX)) == __CHATTERBOX_OPTION_CHOSEN_PREFIX))
    {
        ds_map_delete(_system.__variablesMap, _name);
        return;
    }
    
    if (string_pos(" ", _name))
    {
        __ChatterboxError("Chatterbox variable names must not contain spaces (\"", _name, "\")");
        exit;
    }
    
    if (ds_map_exists(_system.__constantsMap, _name) && _system.__constantsMap[? _name])
    {
        __ChatterboxError("Trying to reset Chatterbox variable $", _name, " but it has been declared as a constant");
    }
    
    if (not ds_map_exists(_system.__declaredVariablesMap, _name))
    {
        ds_map_delete(_system.__variablesMap, _name);
    }
    else if (not ds_map_exists(_system.__defaultVariablesMap, _name))
    {
        //If we don't have a default value then just delete the variable
        //This can happen when <<set>> implicitly declares a variable on compile
        ds_map_delete(_system.__variablesMap, _name);
    }
    else
    {
        var _value = _system.__defaultVariablesMap[? _name];
        __ChatterboxVariableSetInternal(_name, _value);
        __ChatterboxTrace("Reset Chatterbox variable $", _name, " to ", __ChatterboxReadableValue(_value));
    }
}
