/// @param chatterboxHost

function chatterbox_option_count(argument0)
{
	var _chatterbox = argument0;
    
	var _count = 0;
	var _child_array = _chatterbox.children;
    
	var _i = 0;
	repeat(array_length(_child_array))
	{
	    var _array = _child_array[_i];
	    if (_array[__CHATTERBOX_CHILD.TYPE] == "option") _count++;
	    ++_i;
	}
    
	return _count;
}