/// @param [value...]

var _string = "";

var _i = 0;
repeat(argument_count) _string += string(argument[_i]);

__chatterbox_error("" + _string + "");

return _string;