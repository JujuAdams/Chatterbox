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
    var _filename    = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : global.__chatterboxDefaultFile;
    var _singleton   = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : CHATTERBOX_DEFAULT_SINGLETON;
    var _local_scope = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : id;
    
    //Check for people accidentally referencing objects
    if (is_numeric(_local_scope) && (_local_scope < 100000))
    {
        __ChatterboxError("Local scope set to an invalid instance ID (was ", _local_scope, ", must be >= 100000)");
    }
    
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
    
    content              = [];
    contentConditionBool = [];
    contentMetadata      = [];
    contentStructArray   = [];
    
    option              = [];
    optionConditionBool = [];
    optionMetadata      = [];
    optionInstruction   = [];
    __optionUUIDArray     = [];
    optionStructArray   = [];
    
    hopStack = [];
    
    current_node        = undefined;
    current_instruction = undefined;
    stopped             = true;
    waiting             = false;
    forced_waiting      = false;
    fastForward         = false;
    loaded              = true;
    wait_instruction    = undefined;
    
    __fastForwardContentCount = 0;
    
    
    
    #region Flow
    
    //Jumps to a given node in the given source
    static Jump = function()
    {
        var _title    = argument[0];
        var _filename = (argument_count > 1)? argument[1] : undefined;
        
        if (_filename != undefined)
        {
            var _file = global.chatterboxFiles[? _filename];
            if (instanceof(_file) != "__ChatterboxClassSource") __ChatterboxTrace("Error! File \"", _filename, "\" not found or not loaded");
            
            file = _file;
            filename = file.filename;
        }
        
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could not go to node \"", _title, "\" because \"", filename, "\" is not loaded");
            return undefined;
        }
        
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
    
    //Jumps to a given node in the given source
    static Hop = function()
    {
        var _title    = argument[0];
        var _filename = (argument_count > 1)? argument[1] : undefined;
        
        array_push(hopStack, {
            next:     current_instruction,
            node:     current_node,
            filename: filename,
        });
        
        if (_filename != undefined)
        {
            var _file = global.chatterboxFiles[? _filename];
            if (instanceof(_file) != "__ChatterboxClassSource") __ChatterboxTrace("Error! File \"", _filename, "\" not found or not loaded");
            
            file = _file;
            filename = file.filename;
        }
        
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could not go to node \"", _title, "\" because \"", filename, "\" is not loaded");
            return undefined;
        }
        
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
    
    //Jumps to a given node in the given source
    static HopBack = function()
    {
        if (array_length(hopStack) <= 0)
        {
            __ChatterboxError("Hop stack is empty");
        }
        
        //Otherwise pop a node off of our stack and go to it
        var _hop_data = hopStack[array_length(hopStack)-1];
        var _next     = _hop_data.next;
        var _node     = _hop_data.node;
        var _filename = _hop_data.filename;
        array_pop(hopStack);
        
        var _file = global.chatterboxFiles[? _filename];
        if (instanceof(_file) != "__ChatterboxClassSource") __ChatterboxTrace("Error! File \"", _filename, "\" not found or not loaded");
        
        file = _file;
        filename = file.filename;
        
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could hop back because \"", filename, "\" is not loaded");
            return undefined;
        }
        
        current_node = _node;
        current_instruction = _next;
        
        __ChatterboxVM();
    }
    
    static Select = function(_index)
    {
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could not select option because \"", filename, "\" is not loaded");
            return undefined;
        }
        
        if (stopped)
        {
            __ChatterboxTrace("Warning! Could not select option because this chatterbox has been stopped");
            return undefined;
        }
        
        if ((_index < 0) || (_index >= array_length(option)))
        {
            __ChatterboxTrace("Out of bounds option index (got ", _index, ", maximum index for options is ", array_length(option)-1, ")");
            return undefined;
        }
        
        if (optionConditionBool[_index])
        {
            var _lookup = __CHATTERBOX_OPTION_CHOSEN_PREFIX + string(__optionUUIDArray[_index]);
            if (ds_map_exists(global.__chatterboxVariablesMap, _lookup))
            {
                global.__chatterboxVariablesMap[? _lookup]++;
            }
            else
            {
                global.__chatterboxVariablesMap[? _lookup] = 1;
                ds_list_add(global.__chatterboxConstantsList, _lookup);
            }
            
            current_instruction = optionInstruction[_index];
            __ChatterboxVM();
        }
        else
        {
            __ChatterboxTrace("Warning! Trying to select an option that failed its conditional check");
        }
    }
    
    static Continue = function()
    {
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could not continue because \"", filename, "\" is not loaded");
            return undefined;
        }
        
        if (stopped)
        {
            __ChatterboxTrace("Warning! Could not continue because this chatterbox has been stopped");
            return undefined;
        }
        
        if (!waiting)
        {
            __ChatterboxError("Can't continue, provided chatterbox isn't waiting");
            return undefined;
        }
        
        current_instruction = wait_instruction;
        __ChatterboxVM();
    }
    
    static __CurrentlyProcessing = function()
    {
        //Figure out if we're currently processing this chatterbox in a VM
        var _i = 0;
        repeat(array_length(global.__chatterboxVMInstanceStack))
        {
            if (global.__chatterboxVMInstanceStack[_i] == self) return true;
            ++_i;
        }
        
        return false;
    }
    
    static Wait = function()
    {
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could not wait because \"", filename, "\" is not loaded");
            return undefined;
        }
        
        if (waiting)
        {
            __ChatterboxError("Can't wait, provided chatterbox is already waiting");
            return undefined;
        }
        
        //Figure out if we're currently processing this chatterbox in a VM
        if (__CurrentlyProcessing())
        {
            //If we are processing this chatterbox then set this particular global to <true>
            //We pick this global up at the bottom of the VM
            global.__chatterboxVMWait      = true;
            global.__chatterboxVMForceWait = true;
        }
        else
        {
            //Otherwise set up a waiting state
            waiting          = true;
            forced_waiting   = true;
            wait_instruction = current_instruction;
        }
    }
    
    static Stop = function()
    {
        if (stopped)
        {
            __ChatterboxTrace("Can't stop, provided chatterbox is already stopped");
            return undefined;
        }
        
        stopped = true;
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
        
        if (GetOptionCount() > 0)
        {
            __ChatterboxTrace("Error! Player is being prompted to make a choice, cannot fast forward");
            return undefined;
        }
        
        if (__CurrentlyProcessing())
        {
            global.__chatterboxVMFastForward = true;
        }
        else
        {
            fastForward = true;
            __fastForwardContentCount = 0;
            
            __ChatterboxVM();
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
    
    static GetContentArray = function()
    {
        VerifyIsLoaded();
        return contentStructArray;
    }
    
    #endregion
    
    
    
    #region Option
    
    static GetOption = function(_index)
    {
        VerifyIsLoaded();
        if ((_index < 0) || (_index >= array_length(option))) return undefined;
        return option[_index];
    }
    
    static GetOptionChosen = function(_index)
    {
        VerifyIsLoaded();
        if ((_index < 0) || (_index >= array_length(option))) return 0;
        return global.__chatterboxVariablesMap[? __CHATTERBOX_OPTION_CHOSEN_PREFIX + string(__optionUUIDArray[_index])] ?? 0;
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
    
    static GetOptionArray = function()
    {
        VerifyIsLoaded();
        return optionStructArray;
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
                
                __ClearContent();
                __ClearOptions();
                
                current_node        = undefined;
                current_instruction = undefined;
                stopped             = true;
                waiting             = false;
                forced_waiting      = false;
            }
            
            loaded = false;
        }
        
        return loaded;
    }
    
    static __ClearContent = function(_count = 0)
    {
        array_resize(content,              _count);
        array_resize(contentConditionBool, _count);
        array_resize(contentMetadata,      _count);
        array_resize(contentStructArray,   _count);
    }
    
    static __ClearOptions = function(_count = 0)
    {
        array_resize(option,              _count);
        array_resize(optionConditionBool, _count);
        array_resize(optionMetadata,      _count);
        array_resize(optionInstruction,   _count);
        array_resize(__optionUUIDArray,     _count);
        array_resize(optionStructArray,   _count);
    }
}
