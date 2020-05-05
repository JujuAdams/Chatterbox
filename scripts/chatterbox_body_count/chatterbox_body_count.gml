/// @param chatterboxHost

var _chatterbox = argument0;

var _count = 0;
var _child_array = _chatterbox[__CHATTERBOX_HOST.CHILDREN];

var _i = 0;
repeat(array_length_1d(_child_array))
{
    var _array = _child_array[_i];
    if (_array[__CHATTERBOX_CHILD.TYPE] == __CHATTERBOX_CHILD_TYPE.BODY) _count++;
    ++_i;
}

return _count;