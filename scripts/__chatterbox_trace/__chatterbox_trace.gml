/// @param [value...]
function __chatterbox_trace() {

	var _string = "";

	var _i = 0;
	repeat(argument_count)
	{
	    _string += __chatterbox_string(argument[_i]);
	    ++_i;
	}

	show_debug_message(string_format(current_time, 8, 0) + " Chatterbox: " + _string);

	return _string;


}
