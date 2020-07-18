/// @param array

function __chatterbox_array_to_string(_array)
{
	var _string = "[";

	var _i = 0;
	var _size = array_length(_array);
	repeat(_size)
	{
	    _string += __chatterbox_string(_array[_i]);
	    ++_i;
	    if (_i < _size) _string += " , ";
	}
    
	_string += "]";
    
	return _string;
}