/// Returns the value of the Chatterbox variable with the given name
/// Chatterbox variables are only strings, numbers, or booleans
/// If the variable doesn't exist, this function will return the default value set by ChatterboxVariableDefault()
/// If no default value has been set, this function will return <undefined>
/// 
/// @param variableName

function ChatterboxVariableGet(_name)
{
    if (!ds_map_exists(global.chatterboxVariablesMap, _name))
    {
        return global.__chatterboxDefaultVariablesMap[? _name];
    }
    else
    {
        return global.chatterboxVariablesMap[? _name];
    }
}