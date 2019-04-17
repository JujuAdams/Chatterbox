/// @param chatterbox
/// @param type

var _chatterbox = argument0;
var _type       = argument1;

var _count = 0;
var _child_array = _chatterbox[ __CHATTERBOX.CHILDREN ];
var _size = array_length_1d(_child_array);
for(var _i = 0; _i < _size; _i++)
{
    var _array = _child_array[ _i ];
    if (_array[ __CHATTERBOX_CHILD.TYPE ] == _type) _count++;
}

return _count;