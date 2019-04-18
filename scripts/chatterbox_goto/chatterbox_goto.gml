/// @param chatterbox
/// @param nodeTitle
/// @param [filename]

var _chatterbox = argument[0];
var _node_title = argument[1];

if (!is_string(_node_title))
{
    show_debug_message("Chatterbox: Stopping");
    _chatterbox[@ __CHATTERBOX.TITLE ] = undefined;
    exit;
}

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
    
    _chatterbox[@ __CHATTERBOX.FILENAME ] = _filename;
}
else
{
    _filename = _chatterbox[ __CHATTERBOX.FILENAME ];
}

var _key = _filename + CHATTERBOX_FILENAME_SEPARATOR + _node_title;
var _instruction = global.__chatterbox_goto[? _key ];
if (_instruction == undefined)
{
    show_error("Chatterbox:\nCouldn't find title \"" + string(_node_title) + "\" from Yarn .json file \"" + string(_filename) + "\"\n ", false);
    return false;
}

_chatterbox[@ __CHATTERBOX.TITLE    ] = _node_title;
_chatterbox[@ __CHATTERBOX.FILENAME ] = _filename;

show_debug_message("Chatterbox: Starting node \"" + _node_title + "\" from \"" + _filename + "\"");

CHATTERBOX_VARIABLES_MAP[? "visited(" + _key + ")" ] = true;
if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox:   Set \"visited(" + _key + ")\" to <true>");

//Create a fake option
var _new_array = array_create(__CHATTERBOX_CHILD.__SIZE);
_new_array[@ __CHATTERBOX_CHILD.STRING            ] = "";
_new_array[@ __CHATTERBOX_CHILD.TYPE              ] = CHATTERBOX_OPTION;
_new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_START ] = _instruction;
_new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_END   ] = _instruction;

var _child_array = []; //Wipe all children
_chatterbox[@ __CHATTERBOX.CHILDREN ] = _child_array;
_child_array[@ array_length_1d(_child_array) ] = _new_array;

return chatterbox_select(_chatterbox, 0);