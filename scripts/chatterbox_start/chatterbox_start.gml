/// @param chatterbox
/// @param name
/// @param [filename]

var _chatterbox = argument[0];
var _name       = argument[1];

if (argument_count > 2)
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
    
    global.__chatterbox_open_file = _filename;
}

var _title_map = global.__chatterbox_data[? global.__chatterbox_open_file ];
if (_title_map == undefined)
{
    show_error("Chatterbox:\nCouldn't find Yarn .json file \"" + string(global.__chatterbox_open_file) + "\"\n ", false);
    return undefined;
}

var _body = _title_map[? _name ];
if (_body == undefined)
{
    show_error("Chatterbox:\nCouldn't find title \"" + string(_name) + "\" in Yarn .json file \"" + string(global.__chatterbox_open_file) + "\"\n ", false);
    return undefined;
}

_chatterbox[@ __CHATTERBOX_HOST.PRIMARY_SCRIBBLE ] = scribble_create(_body);