/// @param string

var _string = argument0;

var _new_map = json_decode(_string);
if (_new_map < 0)
{
    show_debug_message("Chatterbox: WARNING! Variable import failed");
    return false;
}

ds_map_destroy(CHATTERBOX_VARIABLES_MAP);
CHATTERBOX_VARIABLES_MAP = _new_map;
if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox: Variable import successful");

return true;