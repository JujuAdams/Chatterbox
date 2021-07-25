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
    var _filename    = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : global.__chatterboxDefaultFile;
    var _singleton   = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : CHATTERBOX_DEFAULT_SINGLETON;
    var _local_scope = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : id;
    
    return new __ChatterboxClass(_filename, _singleton, _local_scope);
}

/// @param filename
/// @param singletonText
function __ChatterboxClass(_filename, _singleton, _local_scope) constructor
{
    if (!is_string(_filename))
    {
        __ChatterboxError("Source files must be strings (got \"" + string(_filename) + "\")");
        return undefined;
    }
    
    if (!ChatterboxIsLoaded(_filename))
    {
        __ChatterboxError("Could not create chatterbox because \"", _filename, "\" is not loaded");
        return undefined;
    }
    
    local_scope         = _local_scope;
    singleton_text      = _singleton;
    filename            = _filename;
    file                = global.chatterboxFiles[? filename];
    content             = [];
    contentMetadata     = [];
    option              = [];
    optionMetadata      = [];
    option_instruction  = [];
    current_node        = undefined;
    current_instruction = undefined;
    stopped             = true;
    waiting             = false;
    loaded              = true;
    wait_instruction    = undefined;
    
    
    
    #region Flow
    
    //Jumps to a given node in the given source
    static Jump = function()
    {
        var _title      = argument[0];
        var _filename   = (argument_count > 1)? argument[1] : undefined;
        
        if (_filename != undefined)
        {
            var _file = global.chatterboxFiles[? _filename];
            if (instanceof(_file) == "__ChatterboxClassSource")
            {
                file = _file;
                filename = file.filename;
            }
            else
            {
                __ChatterboxTrace("Error! File \"", _filename, "\" not found or not loaded");
            }
        }
        
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could not go to node \"", _title, "\" because \"", filename, "\" is not loaded");
            return undefined;
        }
        else
        {
            var _node = FindNode(_title);
            if (_node == undefined)
            {
                __ChatterboxError("Could not find node \"", _title, "\" in \"", filename, "\"");
                return undefined;
            }
            
            current_node = _node;
            current_instruction = current_node.root_instruction;
            current_node.MarkVisited();
            
            __ChatterboxVM();
        }
    }
    
    static Select = function(_index)
    {
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could not select option because \"", filename, "\" is not loaded");
            return undefined;
        }
        else
        {
            if ((_index < 0) || (_index >= array_length(option)))
            {
                __ChatterboxTrace("Out of bounds option index (got ", _index, ", maximum index for options is ", array_length(option)-1, ")");
                return undefined;
            }
            
            if (optionConditionBool[_index])
            {
                current_instruction = option_instruction[_index];
                __ChatterboxVM();
            }
            else
            {
                __ChatterboxTrace("Warning! Trying to select an option that failed its conditional check");
            }
        }
    }
    
    static Continue = function()
    {
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could not continue because \"", filename, "\" is not loaded");
            return undefined;
        }
        else
        {
            if (!waiting)
            {
                __ChatterboxError("Can't continue, provided chatterbox isn't waiting");
                return undefined;
            }
            
            current_instruction = wait_instruction;
            __ChatterboxVM();
        }
    }
    
    static IsWaiting = function()
    {
        VerifyIsLoaded();
        return waiting;
    }
    
    static IsStopped = function()
    {
        VerifyIsLoaded();
        return stopped;
    }
    
    static FastForward = function()
    {
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could not fast forward because \"", filename, "\" is not loaded");
            return undefined;
        }
        
        if (stopped)
        {
            __ChatterboxTrace("Error! Chatterbox has stopped, cannot fast forward");
            return undefined;
        }
        
        if (ChatterboxGetOptionCount(_chatterbox) > 0)
        {
            __ChatterboxTrace("Error! Player is being prompted to make a choice, cannot fast forward");
            return undefined;
        }
        
        while ((ChatterboxGetOptionCount(_chatterbox) <= 0) && ChatterboxIsWaiting(_chatterbox) && !ChatterboxIsStopped(_chatterbox))
        {
            ChatterboxContinue(_chatterbox);
        }
    }
    
    #endregion
    
    
    
    #region Content
    
    static GetContent = function(_index)
    {
        VerifyIsLoaded();
        if ((_index < 0) || (_index >= array_length(content))) return undefined;
        return content[_index];
    }
    
    static GetContentCount = function()
    {
        VerifyIsLoaded();
        return array_length(content);
    }
    
    static GetContentMetadata = function(_index)
    {
        VerifyIsLoaded();
        if ((_index < 0) || (_index >= array_length(contentMetadata))) return undefined;
        return contentMetadata[_index];
    }
    
    #endregion
    
    
    
    #region Option
    
    static GetOption = function(_index)
    {
        VerifyIsLoaded();
        if ((_index < 0) || (_index >= array_length(option))) return undefined;
        return option[_index];
    }
    
    static GetOptionCount = function()
    {
        VerifyIsLoaded();
        return array_length(option);
    }
    
    static GetOptionMetadata = function(_index)
    {
        VerifyIsLoaded();
        if ((_index < 0) || (_index >= array_length(optionMetadata))) return undefined;
        return optionMetadata[_index];
    }
    
    static GetOptionConditionBool = function(_index)
    {
        VerifyIsLoaded();
        if ((_index < 0) || (_index >= array_length(option))) return undefined;
        return optionConditionBool[_index];
    }
    
    #endregion
    
    
    
    /// @param nodeTitle
    static FindNode = function(_title)
    {
        return file.FindNode(_title);
    }
    
    static GetCurrentSource = function()
    {
        return filename;
    }
    
    static GetCurrentNodeTitle = function()
    {
        VerifyIsLoaded();
        return current_node.title;
    }
    
    static GetCurrentNodeMetadata = function()
    {
        VerifyIsLoaded();
        return current_node.metadata;
    }
    
    static VerifyIsLoaded = function()
    {
        if (!file.loaded)
        {
            if (loaded)
            {
                __ChatterboxTrace("Warning! \"", filename, "\" has been unloaded, an in-progress chatterbox has been invalidated");
                
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