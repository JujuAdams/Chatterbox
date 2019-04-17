/// @param chatterbox
/// @param type
/// @param index

var _chatterbox = argument0;
var _type       = argument1;
var _index      = argument2;

var _count = 0;
var _child_array = _chatterbox[| __CHATTERBOX.CHILDREN ];
var _size = array_length_1d(_child_array);
for(var _i = 0; _i < _size; _i++)
{
    var _array = _child_array[ _i ];
    if (_array[ __CHATTERBOX_CHILD.TYPE ] == _type)
    {
        if (_count == _index) return _array[ __CHATTERBOX_CHILD.STRING ];
        _count++;
    }
}

return undefined;