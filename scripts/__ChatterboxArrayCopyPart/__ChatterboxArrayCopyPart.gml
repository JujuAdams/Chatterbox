// Feather disable all

/// @param array
/// @param index
/// @param count

function __ChatterboxArrayCopyPart(_array, _index, _count)
{
    var _new_array = array_create(_count);
    array_copy(_new_array, 0, _array, _index, _count);
    return _new_array;
}