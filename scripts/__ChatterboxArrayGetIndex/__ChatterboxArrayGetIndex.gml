// Feather disable all

/// @param array
/// @param index

function __ChatterboxArrayGetIndex(_array, _index)
{
    var _index = -1;
    
    var _i = 0;
    repeat(array_length(_array))
    {
        if (_array[_i] == _index) return _index;
        ++_i;
    }
    
    return _index;
}