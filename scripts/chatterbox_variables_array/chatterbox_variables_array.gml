/// @param chatterbox
/// @param [alphabetise]

var _chatterbox  = argument[0];
var _alphabetise = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : false;

var _variables_map = __CHATTERBOX_VARIABLE_MAP;
var _array = array_create(ds_map_size(_variables_map));

if (_alphabetise)
{
    var _list = ds_list_create();
    
    var _key = ds_map_find_first(_variables_map);
    repeat(ds_map_size(_variables_map))
    {
        ds_list_add(_list, _key);
        _key = ds_map_find_next(_variables_map, _key);
    }
    
    ds_list_sort(_list, true);
    
    var _i = 0;
    repeat(ds_list_size(_list))
    {
        _array[_i] = _list[| _i];
        _i++;
    }
    
    ds_list_destroy(_list);
}
else
{
    var _key = ds_map_find_first(_variables_map);
    var _i = 0;
    repeat(ds_map_size(_variables_map))
    {
        _array[_i] = _key;
        _key = ds_map_find_next(_variables_map, _key);
        _i++;
    }
}

return _array;