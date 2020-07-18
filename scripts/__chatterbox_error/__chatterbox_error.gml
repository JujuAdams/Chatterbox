/// @param [value...]
function __chatterbox_error() {

	var _string = "";

	var _i = 0;
	repeat(argument_count)
	{
	    _string += string(argument[_i]);
	    ++_i;
	}

	show_error("Chatterbox:\n" + _string + "\n ", false);

	return _string;


}
