/// Creates a chatterbox
/// 
/// The "singletonText" parameter controls how dialogue is returned:
/// 
/// If singletonText is set to <true> then dialogue will be outputted one line at a time. This is typical behaviour for RPGs
/// like Pokémon or Final Fantasy where characters talk one at a time. Only one piece of dialogue will be shown at a time.
/// 
/// However, if singletonText is set to <false> then dialogue will be outputted multiple lines at a time. More modern narrative
/// games, especially those by Inkle or Failbetter, tend to show larger blocks of text. Dialogue will be stacked up until
/// Chatterbox reaches a command that requires user input: a shortcut, an option, or a <<stop>> or <<wait>> command.
/// 
/// @param [filename]
/// @param [singletonText]
/// @param [localScope]

function chatterbox_create()
{
    var _filename    = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : global.__chatterbox_default_file;
    var _singleton   = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : CHATTERBOX_DEFAULT_SINGLETON;
    var _local_scope = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : id;
    
    return new __chatterbox_class(_filename, _singleton, _local_scope);
}

/// @param filename
/// @param singletonText
function __chatterbox_class(_filename, _singleton, _local_scope) constructor
{
    if (!is_string(_filename))
    {
        __chatterbox_error("Source files must be strings (got \"" + string(_filename) + "\")");
        return undefined;
    }
    
    if (!chatterbox_is_loaded(_filename))
    {
        __chatterbox_error("Could not create chatterbox because \"", _filename, "\" is not loaded");
        return undefined;
    }
    
    local_scope         = _local_scope;
    singleton_text      = _singleton;
    filename            = _filename;
    file                = global.chatterbox_files[? filename];
    content             = [];
    option              = [];
    option_instruction  = [];
    current_node        = undefined;
    current_instruction = undefined;
    stopped             = true;
    waiting             = false;
    loaded              = true;
    wait_instruction    = undefined;
    
    /// @param nodeTitle
    find_node = function(_title)
    {
        return file.find_node(_title);
    }
    
    verify_is_loaded = function()
    {
        if (!file.loaded)
        {
            if (loaded)
            {
                __chatterbox_trace("Warning! \"", filename, "\" has been unloaded, an in-progress chatterbox has been invalidated");
                
                content             = [];
                option              = [];
                option_instruction  = [];
                current_node        = undefined;
                current_instruction = undefined;
                stopped             = true;
                waiting             = false;
            }
            
            loaded = false;
        }
        
        return loaded;
    }
}