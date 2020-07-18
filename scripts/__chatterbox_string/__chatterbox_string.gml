/// @param value

function __chatterbox_string(_value)
{
	if (is_array(_value)) return __chatterbox_array_to_string(_value);
	return string(_value);
}