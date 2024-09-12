// Feather disable all

/// Sets a callback function that is executed whenever a Chatterbox variable is set. The callback
/// will be executed in the following situations:
/// 
/// - Setting a variable in YarnScript
/// - Calling ChatterboxVariableSet()
/// - Calling ChatterboxVariableReset()
/// 
/// Three arguments are passed to the callback function: the name of the variable, the new value,
/// and the old value (in that order). The callback is executed after the new value is set.

function ChatterboxVariableSetCallback(_function)
{
    static _system = __ChatterboxSystem();
    
    _system.__variablesSetCallback = _function;
}
