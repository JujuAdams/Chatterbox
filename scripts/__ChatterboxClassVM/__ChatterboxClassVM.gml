// Feather disable all

/// @param filename
/// @param singletonText
/// @param localScope
/// @param chatter

function __ChatterboxClassVM(_filename, _singleton, _localScope, _chatterbox) constructor
{
    static _system = __ChatterboxSystem();
    
    __localScope    = _localScope;
    __singletonText = _singleton;
    filename        = _filename;
    __chatterbox    = _chatterbox;
    
    file = _system.__files[? filename];
    
    content              = [];
    contentConditionBool = [];
    contentMetadata      = [];
    contentStructArray   = [];
    
    option              = [];
    optionConditionBool = [];
    optionMetadata      = [];
    optionInstruction   = [];
    __optionUUIDArray   = [];
    optionStructArray   = [];
    optionWeightArray   = [];
    
    hopStack = [];
    
    current_node        = undefined;
    current_instruction = undefined;
    __exit              = true;
    __stopped           = false;
    __hopped            = false;
    waiting             = false;
    forced_waiting      = false;
    waitingName         = "";
    fastForward         = false;
    loaded              = true;
    wait_instruction    = undefined;
    
    __fastForwardContentCount = 0;
    
    
    
    #region Flow
    
    //Jumps to a given node in the given source
    static Jump = function(_title, _filename = undefined)
    {
        if (_filename != undefined)
        {
            _filename = __ChatterboxReplaceBackslashes(_filename);
            
            var _file = _system.__files[? _filename];
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
        
        __ChangeNode(_node, true);
        current_instruction = current_node.root_instruction;
        
        __ChatterboxVM();
    }
    
    //Jumps to a given node in the given source
    static Hop = function(_title, _filename = undefined)
    {
        __HopPush(current_instruction);
        
        if (_filename != undefined)
        {
            _filename = __ChatterboxReplaceBackslashes(_filename);
            
            var _file = _system.__files[? _filename];
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
        
        __ChangeNode(_node, true);
        current_instruction = current_node.root_instruction;
        
        __ChatterboxVM();
    }
    
    static __HopPush = function(_next)
    {
        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("Pushing to hop stack: node = <", current_node, ">, next instruction = <", _next, ">, filename = \"", filename, "\"");
        
        array_push(hopStack, {
            next:     _next,
            node:     current_node,
            filename: filename,
        });
    }
    
    static __HopPop = function()
    {
        if (__HopEmpty())
        {
            __ChatterboxError("Hop stack is empty");
        }
        
        var _data = array_pop(hopStack);
        
        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("Pushing to hop stack: node = <", _data.node, ">, next instruction = <", _data.next, ">, filename = \"", _data.filename, "\"");
        
        return _data;
    }
    
    static __HopEmpty = function()
    {
        return (array_length(hopStack) <= 0);
    }
    
    //Jumps to a given node in the given source
    static HopBack = function()
    {
        if (__HopEmpty())
        {
            __ChatterboxError("Hop stack is empty");
        }
        
        //Otherwise pop a node off of our stack and go to it
        var _hop_data = __HopPop();
        var _filename = __ChatterboxReplaceBackslashes(_hop_data.filename);
        
        var _file = _system.__files[? _filename];
        if (instanceof(_file) != "__ChatterboxClassSource") __ChatterboxTrace("Error! File \"", _filename, "\" not found or not loaded");
        
        file = _file;
        filename = file.filename;
        
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could hop back because \"", filename, "\" is not loaded");
            return undefined;
        }
        
        __ChangeNode(_hop_data.node, false);
        current_instruction = _hop_data.next;
        
        __ChatterboxVM();
    }
    
    static Select = function(_index)
    {
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could not select option because \"", filename, "\" is not loaded");
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
            if (ds_map_exists(_system.__variablesMap, _lookup))
            {
                __ChatterboxVariableSetInternal(_lookup, _system.__variablesMap[? _lookup] + 1);
            }
            else
            {
                __ChatterboxVariableSetInternal(_lookup, 1);
                ds_list_add(_system.__constantsList, _lookup);
            }
            
            current_instruction = optionInstruction[_index];
            __ChatterboxVM();
        }
        else
        {
            __ChatterboxTrace("Warning! Trying to select an option that failed its conditional check");
        }
    }
    
    static Continue = function(_name = "")
    {
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could not continue because \"", filename, "\" is not loaded");
            return undefined;
        }
        
        if (!waiting)
        {
            __ChatterboxError("Can't continue, provided chatterbox isn't waiting");
            return undefined;
        }
        
        if (waitingName != _name)
        {
            return;
        }
        
        current_instruction = wait_instruction;
        __ChatterboxVM();
    }
    
    static __CurrentlyProcessing = function()
    {
        return (__ChatterboxArrayGetIndex(_system.__globalVMStack, self) >= 0);
    }
    
    static Wait = function(_name = "")
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
            _system.__globalVMWait      = true;
            _system.__globalVMForceWait = true;
            _system.__globalVMWaitName  = _name;
        }
        else
        {
            //Otherwise set up a waiting state
            waiting          = true;
            forced_waiting   = true;
            waitingName      = _name;
            wait_instruction = current_instruction;
        }
    }
    
    static IsWaiting = function()
    {
        VerifyIsLoaded();
        return waiting;
    }
    
    static FastForward = function()
    {
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could not fast forward because \"", filename, "\" is not loaded");
            return undefined;
        }
        
        if (GetOptionCount() > 0)
        {
            __ChatterboxTrace("Error! Player is being prompted to make a choice, cannot fast forward");
            return undefined;
        }
        
        if (__CurrentlyProcessing())
        {
            _system.__globalVMFastForward = true;
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
        return _system.__variablesMap[? __CHATTERBOX_OPTION_CHOSEN_PREFIX + string(__optionUUIDArray[_index])] ?? 0;
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
                __exit              = true;
                __stopped           = false;
                __hopped            = false;
                waiting             = false;
                forced_waiting      = false;
                waitingName         = "";
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
        array_resize(__optionUUIDArray,   _count);
        array_resize(optionStructArray,   _count);
        array_resize(optionWeightArray,   _count);
    }
    
    static __ChangeNode = function(_newNode, _markAsVisited)
    {
        var _oldNode = current_node;
        
        current_node = _newNode;
        if (_markAsVisited) current_node.MarkVisited();
        
        if (is_undefined(_system.__nodeChangeCallback))
        {
            //Do nothing!
        }
        else if (is_method(_system.__nodeChangeCallback) || script_exists(_system.__nodeChangeCallback))
        {
            _system.__nodeChangeCallback((_oldNode != undefined)? _oldNode.title : undefined, 
                                         (_newNode != undefined)? _newNode.title : undefined);
        }
    }
}