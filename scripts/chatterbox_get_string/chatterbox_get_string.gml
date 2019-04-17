/// @param chatterbox
/// @param type
/// @param index

var _chatterbox = argument0;
var _type       = argument1;
var _index      = argument2;

var _count = 0;
var _child_list = _chatterbox[| __CHATTERBOX.CHILD_LIST ];
var _size = ds_list_size(_child_list);
for(var _i = 0; _i < _size; _i++)
{
    var _array = _child_list[| _i ];
    if (_array[ __CHATTERBOX_CHILD.TYPE ] == _type)
    {
        if (_count == _index) return _array;
        _count++;
    }
}

return undefined;