// Feather disable all
function ChatterboxVariablesResetAll()
{
    __ChatterboxTrace("Resetting all variables...");
    
    ds_map_clear(global.__chatterboxVariablesMap);
    
    var _i = 0;
    repeat(ds_list_size(global.__chatterboxVariablesList))
    {
        ChatterboxVariableReset(global.__chatterboxVariablesList[| _i]);
        ++_i;
    }
    
    __ChatterboxTrace("....variable resetting complete");
}
