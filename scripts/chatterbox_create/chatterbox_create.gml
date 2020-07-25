/// Creates a chatterbox
/// 
/// The "singletonText" parameter controls how dialogue is returned:
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

function chatterbox_create()
{
	var _filename  = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : global.__chatterbox_default_file;
	var _singleton = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : CHATTERBOX_DEFAULT_SINGLETON;
    return new __chatterbox_class(_filename, _singleton);
}