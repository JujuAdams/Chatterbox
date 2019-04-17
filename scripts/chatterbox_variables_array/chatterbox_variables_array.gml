/// @param chatterbox
/// @param [alphabetise]

var _chatterbox  = argument[0]; _chatterbox = _chatterbox; //Stop "only used once error"
var _alphabetise = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : false;

var _array = array_create(ds_map_size(global.__chatterbox_variables));

if (_alphabetise)
{
    var _list = ds_list_create();
    
    var _key = ds_map_find_first(global.__chatterbox_variables);
    repeat(ds_map_size(global.__chatterbox_variables))
    {
        ds_list_add(_list, _key);
        _key = ds_map_find_next(global.__chatterbox_variables, _key);
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
    var _key = ds_map_find_first(global.__chatterbox_variables);
    var _i = 0;
    repeat(ds_map_size(global.__chatterbox_variables))
    {
        _array[_i] = _key;
        _key = ds_map_find_next(global.__chatterbox_variables, _key);
        _i++;
    }
}

return _array;