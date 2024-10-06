// Feather disable all
/// Creates a chatterbox
/// 
/// The "singletonText" parameter controls how dialogue is returned:
/// 
/// If singletonText is set to <true> then dialogue will be outputted one line at a time. This is typical behaviour for RPGs
/// like Pokémon or Final Fantasy where characters talk one at a time. Only one piece of dialogue will be shown at a time.
/// 
/// However, if singletonText is set to <false> then dialogue will be outputted multiple lines at a time. More modern narrative
/// games, especially those by Inkle or Failbetter, tend to show larger blocks of text. Dialogue will be stacked up until
/// Chatterbox reaches a command that requires user input: a option, an option, or a <<stop>> or <<wait>> command.
/// 
/// @param [filename]
/// @param [singletonText]
/// @param [localScope]

function ChatterboxCreate()
{
    static _system = __ChatterboxSystem();
    
    var _filename    = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : _system.__defaultFile;
    var _singleton   = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : CHATTERBOX_DEFAULT_SINGLETON;
    var _localScope = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : id;
    
    //Check for people accidentally referencing objects
    if (is_numeric(_localScope) && (_localScope < 100000))
    {
        __ChatterboxError("Local scope set to an invalid instance ID (was ", _localScope, ", must be >= 100000)");
    }
    
    return new __ChatterboxClass(_filename, _singleton, _localScope);
}