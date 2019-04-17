/// @param [filename]
/// @param [singletonText]

var _filename       = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : global.__chatterbox_default_file;
var _singleton_text = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : true;

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

//Create the Chatterbox data structure
var _chatterbox = array_create(__CHATTERBOX.__SIZE);
_chatterbox[@ __CHATTERBOX.FILENAME       ] = _filename;
_chatterbox[@ __CHATTERBOX.TITLE          ] = undefined;
_chatterbox[@ __CHATTERBOX.SINGLETON_TEXT ] = _singleton_text;
_chatterbox[@ __CHATTERBOX.CHILDREN       ] = [];
return _chatterbox;