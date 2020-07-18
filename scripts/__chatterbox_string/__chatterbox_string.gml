/// @param value
function __chatterbox_string(argument0) {

	if (is_array(argument0)) return __chatterbox_array_to_string(argument0);
	return string(argument0);


}
