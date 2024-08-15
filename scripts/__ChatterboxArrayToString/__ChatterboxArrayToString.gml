// Feather disable all

/// @param array

function __ChatterboxArrayToString(_array)
{
    var _string = "[";

    var _i = 0;
    var _size = array_length(_array);
    repeat(_size)
    {
        _string += __ChatterboxString(_array[_i]);
        ++_i;
        if (_i < _size) _string += ",";
    }
    
    _string += "]";
    
    return _string;
}