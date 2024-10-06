// Feather disable all

/// @param array
/// @param target

function __ChatterboxArrayGetIndex(_array, _target)
{
    var _index = -1;
    
    var _i = 0;
    repeat(array_length(_array))
    {
        if (_array[_i] == _target) return _index;
        ++_i;
    }
    
    return _index;
}