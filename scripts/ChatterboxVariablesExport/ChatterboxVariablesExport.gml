/// Returns a string that represents the names and values of all Chatterbox variables (excluding constants)

function ChatterboxVariablesExport()
{
    var _map = ds_map_create();
    ds_map_copy(_map, global.__chatterboxVariablesMap);
    
    var _i = 0;
    repeat(ds_list_size(global.__chatterboxConstantsList))
    {
        ds_map_delete(global.__chatterboxVariablesMap, global.__chatterboxConstantsList[| _i]);
        ++_i;
    }
    
    var _result = _map;
    ds_map_destroy(_map);
    return _result;
}