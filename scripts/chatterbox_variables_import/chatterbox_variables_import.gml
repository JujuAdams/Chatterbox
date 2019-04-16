/// @param chatterbox

var _chatterbox = argument0; _chatterbox = _chatterbox; //Stop "only used once error"

var _new_map = json_decode(_variables_map);
if (_new_map < 0)
{
    show_debug_message("Chatterbox: WARNING! Variable import failed");
    return false;
}

if (CHATTERBOX_INTERNAL_VARIABLE_MAP_SCOPE == CHATTERBOX_SCOPE_GML_LOCAL)
{
    var _variables_map = _chatterbox[| __CHATTERBOX.VARIABLES ];
    ds_map_destroy(_variables_map);
    
    _chatterbox[| __CHATTERBOX.VARIABLES ] = _new_map;
    ds_list_mark_as_map(_chatterbox, __CHATTERBOX.VARIABLES);
}
else
{
    ds_map_destroy(global.__chatterbox_variables);
    global.__chatterbox_variables = _new_map;
}

if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox: Variable import successful");

return true;