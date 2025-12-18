// Feather disable all

function ChatterboxVariablesResetAll()
{
    static _system = __ChatterboxSystem();
    
    __ChatterboxTrace("Resetting all variables...");
    
    var _constantsMap = _system.__constantsMap;
    
    var _array = ds_map_keys_to_array(_system.__variablesMap);
    ds_map_clear(_system.__variablesMap);
    
    var _i = 0;
    repeat(array_length(_array))
    {
        var _variableName = _array[_i];
        if (_constantsMap[? _variableName] != true) //Don't try to reset constants
        {
            ChatterboxVariableReset(_variableName);
        }
        
        ++_i;
    }
    
    __ChatterboxTrace("....variable resetting complete");
}
