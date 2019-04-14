/// @param chatterbox

var _chatterbox = argument0;

var _new_map = json_decode(_variables_map);
if (_new_map < 0)
{
    show_debug_message("Chatterbox: WARNING! Variable import failed");
    return false;
}

var _variables_map = _chatterbox[| __CHATTERBOX.VARIABLES ];
ds_map_destroy(_variables_map);

_chatterbox[| __CHATTERBOX.VARIABLES ] = _new_map;
ds_list_mark_as_map(_chatterbox, __CHATTERBOX.VARIABLES);

if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox: Variable import successful");

return true;