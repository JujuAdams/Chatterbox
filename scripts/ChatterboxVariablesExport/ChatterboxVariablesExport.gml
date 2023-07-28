// Feather disable all
/// Returns a string that represents the names and values of all Chatterbox variables (excluding constants)

function ChatterboxVariablesExport()
{
    var _map = ds_map_create();
    ds_map_copy(_map, global.__chatterboxVariablesMap);
    
    var _i = 0;
    repeat(ds_list_size(global.__chatterboxConstantsList))
    {
        ds_map_delete(_map, global.__chatterboxConstantsList[| _i]);
        ++_i;
    }
    
    var _result = json_encode(_map);
    ds_map_destroy(_map);
    return _result;
}
