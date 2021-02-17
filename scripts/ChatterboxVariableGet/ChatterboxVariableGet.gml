/// Returns the value of the Chatterbox variable with the given name
/// Chatterbox variables are only strings, numbers, or booleans
/// If the variable doesn't exist, this function will return <undefined>
/// 
/// @param variableName

function ChatterboxVariableGet(_name)
{
    return global.chatterboxVariablesMap[? _name];
}