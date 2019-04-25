/// Adds a Yarn .json file definition to Chatterbox. This file is loaded and parsed in chatterbox_init_end().
///
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax().
///
/// @param fileName  Name of the Yarn .json file to add

if ( !variable_global_exists("__chatterbox_init_complete") )
{
    show_error("Chatterbox:\nchatterbox_init_add() should be called after chatterbox_init_start()\n ", true);
    return undefined;
}

if (global.__chatterbox_init_complete)
{
    show_error("Chatterbox:\nchatterbox_init_add() should be called before chatterbox_init_end()\n ", true);
    return undefined;
}

var _file = argument0;

if (ds_map_exists(global.__chatterbox_file_data, _file))
{
    show_error("Chatterbox:\n\"" + _file + "\" has already been defined\n ", false);
    return undefined;
}

if (!is_string(_file))
{
    show_error("Chatterbox:\nSource files should be initialised using their filename as a string.\n(Input was an invalid datatype)\n ", false);
    return undefined;
}

if (global.__chatterbox_default_file == "") global.__chatterbox_default_file = _file;

var _data;
_data[ __CHATTERBOX_FILE.FILENAME ] = _file;
_data[ __CHATTERBOX_FILE.NAME     ] = _file;
_data[ __CHATTERBOX_FILE.TYPE     ] = __CHATTERBOX_FILE_YARN;
global.__chatterbox_file_data[? _file ] = _data;

show_debug_message("Chatterbox: Added \"" + _file + "\" as a source file");