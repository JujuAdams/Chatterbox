function ChatterboxVariablesResetAll()
{
    __ChatterboxTrace("Resetting all variables...");
    
    ds_map_clear(CHATTERBOX_VARIABLES_MAP);
    
    var _i = 0;
    repeat(ds_list_size(CHATTERBOX_VARIABLES_LIST))
    {
        ChatterboxVariableReset(CHATTERBOX_VARIABLES_LIST[| _i]);
        ++_i;
    }
    
    __ChatterboxTrace("....variable resetting complete");
}