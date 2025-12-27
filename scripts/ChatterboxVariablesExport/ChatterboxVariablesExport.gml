// Feather disable all

/// Returns a string that represents the names and values of all Chatterbox variables. The exported
/// data will not contain constant values oe `optionChosen` values.

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
    
    var _namesArray = ds_map_keys_to_array(_map);
    var _stringLength = string_length(__CHATTERBOX_OPTION_CHOSEN_PREFIX);
    
    var _i = 0;
    repeat(array_length(_namesArray))
    {
        var _name = _namesArray[_i];
        if (string_copy(_name, 1, _stringLength) == __CHATTERBOX_OPTION_CHOSEN_PREFIX)
        {
            ds_map_delete(_map, _name);
        }
        else
        {
            ++_i;
        }
    }
    
    var _result = json_encode(_map);
    ds_map_destroy(_map);
    return _result;
}
