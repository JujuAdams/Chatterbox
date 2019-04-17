/// @param [filename]

var _filename = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : global.__chatterbox_default_file;

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
var _chatterbox = ds_list_create();
_chatterbox[| __CHATTERBOX.FILENAME    ] = _filename;
_chatterbox[| __CHATTERBOX.TITLE       ] = undefined;
_chatterbox[| __CHATTERBOX.VARIABLES   ] = ds_map_create();
_chatterbox[| __CHATTERBOX.CHILD_LIST  ] = ds_list_create();
ds_list_mark_as_map( _chatterbox, __CHATTERBOX.VARIABLES );
ds_list_mark_as_list(_chatterbox, __CHATTERBOX.CHILD_LIST);
return _chatterbox;