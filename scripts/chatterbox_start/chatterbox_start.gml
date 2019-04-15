/// @param chatterbox
/// @param nodeTitle
/// @param [filename]

var _chatterbox = argument[0];
var _node_title = argument[1];

if (argument_count > 2) && (argument[2] != undefined)
{
    var _filename = argument[2];
    
    if (!is_string(_filename))
    {
        show_error("Chatterbox:\nYarn .json filenames must be strings (Got \"" + string(_filename) + "\")\n ", false);
        return undefined;
    }
    
    if (!ds_map_exists(global.__chatterbox_file_data, _filename))
    {
        show_error("Chatterbox:\nCannot find Yarn .json \"" + _filename + "\"\n ", false);
        return undefined;
    }
    
    _chatterbox[| __CHATTERBOX.FILENAME ] = _filename;
}
else
{
    _filename = _chatterbox[| __CHATTERBOX.FILENAME ];
}

var _instruction_list = global.__chatterbox_data[? _filename + __CHATTERBOX_FILENAME_SEPARATOR + _node_title ];
if (_instruction_list == undefined)
{
    show_error("Chatterbox:\nCouldn't find title \"" + string(_node_title) + "\" from Yarn .json file \"" + string(_filename) + "\"\n ", false);
    return false;
}

if (!ds_exists(_instruction_list, ds_type_list))
{
    show_error("Chatterbox:\nds_list not found for title \"" + string(_node_title) + "\" in Yarn .json file \"" + string(_filename) + "\"\nThis is a weird error and should never happen!\n ", false);
    return false;
}

_chatterbox[| __CHATTERBOX.TITLE    ] = _node_title;
_chatterbox[| __CHATTERBOX.FILENAME ] = _filename;

if (ds_list_size(_instruction_list) == 0)
{
    return false;
}

show_debug_message("Chatterbox: Starting node \"" + _node_title + "\" from \"" + _filename + "\"");

_chatterbox[| __CHATTERBOX.INITIALISED ] = false;
_chatterbox[| __CHATTERBOX.INSTRUCTION ] = 0;

var _variables_map = _chatterbox[| __CHATTERBOX.VARIABLES ];
if (CHATTERBOX_VISITED_NO_FILENAME)
{
    _variables_map[? "visited(" + _node_title + ")" ] = true;
    if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox:   Set \"visited(" + _node_title + ")\" to <true>");
}
else
{
    _variables_map[? "visited(" + _filename + __CHATTERBOX_FILENAME_SEPARATOR + _node_title + ")" ] = true;
    if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox:   Set \"visited(" + _filename + __CHATTERBOX_FILENAME_SEPARATOR + _node_title + ")\" to <true>");
}

chatterbox_step(_chatterbox);
return true;