// Feather disable all
/// Returns a string that represents the names and values of all Chatterbox variables (excluding constants)

function ChatterboxVariablesExport()
{
    static _system = __ChatterboxSystem();
    
    var _map = ds_map_create();
    ds_map_copy(_map, _system.__variablesMap);
    
    var _i = 0;
    repeat(ds_list_size(_system.__constantsList))
    {
        ds_map_delete(_map, _system.__constantsList[| _i]);
        ++_i;
    }
    
    var _result = json_encode(_map);
    ds_map_destroy(_map);
    return _result;
}
