/// @param chatterboxHost
/// @param index

function chatterbox_option_get(_chatterbox, _index)
{
	var _count = 0;
	var _child_array = _chatterbox.children;
    
	var _i = 0;
	repeat(array_length(_child_array))
	{
	    var _array = _child_array[ _i ];
	    if (_array[__CHATTERBOX_CHILD.TYPE] == "option")
	    {
	        if (_count == _index) return _array[__CHATTERBOX_CHILD.STRING];
	        _count++;
	    }
        
	    ++_i;
	}
    
	return undefined;
}