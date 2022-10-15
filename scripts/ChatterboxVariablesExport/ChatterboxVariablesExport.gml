/// Returns a string that represents the names and values of all Chatterbox variables (excluding constants)

function ChatterboxVariablesExport()
{
    var _map = ds_map_create();
    ds_map_copy(_map, CHATTERBOX_VARIABLES_MAP);
    
    var _i = 0;
    repeat(ds_list_size(global.__chatterboxConstantList))
    {
        ds_map_delete(CHATTERBOX_VARIABLES_MAP, global.__chatterboxConstantList[| _i]);
        ++_i;
    }
    
    var _result = _map;
    ds_map_destroy(_map);
    return _result;
}