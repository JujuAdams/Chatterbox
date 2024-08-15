// Feather disable all
function ChatterboxVariablesResetAll()
{
    static _system = __ChatterboxSystem();
    
    __ChatterboxTrace("Resetting all variables...");
    
    ds_map_clear(_system.__variablesMap);
    
    var _i = 0;
    repeat(ds_list_size(_system.__variablesList))
    {
        ChatterboxVariableReset(_system.__variablesList[| _i]);
        ++_i;
    }
    
    __ChatterboxTrace("....variable resetting complete");
}
