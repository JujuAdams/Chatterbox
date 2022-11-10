function ChatterboxVariablesResetAll()
{
    if (CHATTERBOX_VERBOSE) __ChatterboxTrace("Resetting all variables...");
    
    ds_map_clear(global.__chatterboxVariablesMap);
    
    var _i = 0;
    repeat(ds_list_size(global.__chatterboxVariablesList))
    {
        ChatterboxVariableReset(global.__chatterboxVariablesList[| _i]);
        ++_i;
    }
    
    if (CHATTERBOX_VERBOSE) __ChatterboxTrace("....variable resetting complete");
}