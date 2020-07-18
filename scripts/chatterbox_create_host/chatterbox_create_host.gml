/// Creates a Chatterbox host
/// 
/// Chatterbox uses a "host" to keep track of various bits of data.
/// Hosts are arrays and, as a result, are automatically cleaned up by GameMaker without needing to be explicitly destroyed.
/// 
/// The "singletonText" parameter controls how dialogue is displayed:
/// 
/// If singletonText is set to <true> then dialogue will be outputted one line at a time. This is typical behaviour for RPGs
/// like Pokémon or Final Fantasy where characters talk one at a time. Only one piece of dialogue will be shown at a time.
/// In this mode, the <<wait>> command will not be functional.
/// 
/// However, if singletonText is set to <false> then dialogue will be outputted multiple lines at a time. More modern narrative
/// games, especially those by Inkle or Failbetter, tend to show larger blocks of text. Dialogue will be stacked up until
/// Chatterbox reaches a command that requires user input: a shortcut, an option, or a <<stop>> or <<wait>> command.
/// 
/// @param [filename]
/// @param [singletonText]
function chatterbox_create_host() {

	var _filename       = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : global.__chatterbox_default_file;
	var _singleton_text = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : true;

	if (!is_string(_filename))
	{
	    __chatterbox_error("Source files must be strings (Got \"" + string(_filename) + "\")");
	    return undefined;
	}

	if (!ds_map_exists(global.__chatterbox_file_data, _filename))
	{
	    __chatterbox_error("Cannot find \"" + _filename + "\"");
	    return undefined;
	}

	//Create the Chatterbox data structure
	var _chatterbox = array_create(__CHATTERBOX_HOST.__SIZE);
	_chatterbox[@ __CHATTERBOX_HOST.FILENAME       ] = _filename;
	_chatterbox[@ __CHATTERBOX_HOST.TITLE          ] = undefined;
	_chatterbox[@ __CHATTERBOX_HOST.SINGLETON_TEXT ] = _singleton_text;
	_chatterbox[@ __CHATTERBOX_HOST.CHILDREN       ] = [];
	return _chatterbox;


}
