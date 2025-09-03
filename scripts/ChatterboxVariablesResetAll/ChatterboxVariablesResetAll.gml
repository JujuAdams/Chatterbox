// Feather disable all

function ChatterboxVariablesResetAll()
{
    static _system = __ChatterboxSystem();
    
    __ChatterboxTrace("Resetting all variables...");
    
    var _array = ds_map_keys_to_array(_system.__variablesMap);
    ds_map_clear(_system.__variablesMap);
    
    var _i = 0;
    repeat(array_length(_array))
    {
        ChatterboxVariableReset(_array[_i]);
        ++_i;
    }
    
    __ChatterboxTrace("....variable resetting complete");
}
