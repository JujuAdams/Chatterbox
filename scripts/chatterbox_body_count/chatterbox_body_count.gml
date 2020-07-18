/// @param chatterboxHost

function chatterbox_body_count(_chatterbox)
{
	var _count = 0;
	var _child_array = _chatterbox.children;
    
	var _i = 0;
	repeat(array_length(_child_array))
	{
	    var _array = _child_array[_i];
	    if (_array[__CHATTERBOX_CHILD.TYPE] == "body") _count++;
	    ++_i;
	}
    
	return _count;
}