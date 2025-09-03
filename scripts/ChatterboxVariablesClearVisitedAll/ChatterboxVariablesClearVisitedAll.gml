// Feather disable all

/// Resets the visited state of every node
/// Future calls to Chatterbox's "visited()" function for all nodes will return 0

function ChatterboxVariablesClearVisitedAll()
{
    static _system = __ChatterboxSystem();
    
    var _map = _system.__variablesMap;
    var _array = ds_map_keys_to_array(_map);
    
    var _i = 0;
    repeat(array_length(_array))
    {
        var _key = _array[_i];
        if (string_copy(_key, 1, 8) == "visited(")
        {
            ds_map_delete(_map, _key);
        }
        
        ++_i;
    }
}
