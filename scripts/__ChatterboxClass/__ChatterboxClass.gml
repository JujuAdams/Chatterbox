// Feather disable all

/// @param filename
/// @param singletonText
/// @param localScope

function __ChatterboxClass(_filename, _singleton, _localScope) constructor
{
    static _system = __ChatterboxSystem();
    
    if (not is_string(_filename))
    {
        __ChatterboxError("Source files must be strings (got \"" + string(_filename) + "\")");
        return undefined;
    }
    
    _filename = __ChatterboxReplaceBackslashes(_filename);
    
    if (not ChatterboxIsLoaded(_filename))
    {
        __ChatterboxError("Could not create chatterbox because \"", _filename, "\" is not loaded");
        return undefined;
    }
    
    __lastFilename = _filename;
    __singleton    = _singleton;
    __localScope   = _localScope;
    
    __vmStack = [];
    __VMStackPush(_filename);
    
    
    
    #region Helper Funcions
    
    static __VMStackPush = function(_filename = __lastFilename)
    {
        __lastFilename = _filename;
        
        __vmCurrent = new __ChatterboxClassVM(__lastFilename, __singleton, __localScope, self);
        array_push(__vmStack, __vmCurrent);
        
        return __vmCurrent;
    }
    
    static __VMStackEnsure = function()
    {
        if (__VMStackEmpty()) __VMStackPush(undefined);
    }
    
    static __VMStackPop = function()
    {
        if (__VMStackEmpty()) return;
        
        array_pop(__vmStack);
        __vmCurrent = __ChatterboxArrayLast(__vmStack);
        
        return __vmCurrent;
    }
    
    static __VMStackEmpty = function()
    {
        return (array_length(__vmStack) <= 0);
    }
    
    static __VMStackRemove = function(_target)
    {
        if (__VMStackEmpty()) return;
        
        if (__vmStack[array_length(__vmStack)-1] == _target)
        {
            __VMStackPop();
        }
        else
        {
            var _index = __ChatterboxArrayGetIndex(__vmStack, _target);
            if (_index >= 0) array_delete(__vmStack, _index);
        }
    }
    
    #endregion
    
    
    
    #region Flow
    
    //Jumps to a given node in the given source
    static Jump = function(_title, _filename = undefined)
    {
        __VMStackEnsure(_filename);
        return __vmCurrent.Jump(_title, _filename);
    }
    
    //Jumps to a given node in the given source
    static Hop = function(_title, _filename = undefined)
    {
        __VMStackEnsure(_filename);
        return __vmCurrent.Hop(_title, _filename);
    }
    
    //Jumps to a given node in the given source
    static HopBack = function()
    {
        if (__VMStackEmpty()) return;
        return __vmCurrent.HopBack();
    }
    
    static Select = function(_index)
    {
        if (__VMStackEmpty()) return;
        return __vmCurrent.Select(_index);
    }
    
    static Continue = function(_name = "")
    {
        if (__VMStackEmpty()) return;
        return __vmCurrent.Continue(_name);
    }
    
    static Wait = function(_name = "")
    {
        if (__VMStackEmpty()) return;
        return __vmCurrent.Wait(_name);
    }
    
    static Stop = function()
    {
        array_resize(__vmStack, 0);
    }
    
    static FastForward = function()
    {
        if (__VMStackEmpty()) return;
        return __vmCurrent.FastForward();
    }
    
    static IsWaiting = function()
    {
        if (__VMStackEmpty()) return false;
        return __vmCurrent.IsWaiting();
    }
    
    static IsStopped = function()
    {
        if (array_length(__vmStack) <= 0) return true;
        return __vmCurrent.__stopped;
    }
    
    #endregion
    
    
    
    #region Content
    
    static GetContent = function(_index)
    {
        if (__VMStackEmpty()) return;
        return __vmCurrent.GetContent(_index);
    }
    
    static GetContentCount = function()
    {
        if (__VMStackEmpty()) return 0;
        return __vmCurrent.GetContentCount();
    }
    
    static GetContentMetadata = function(_index)
    {
        if (__VMStackEmpty()) return;
        return __vmCurrent.GetContentMetadata(_index);
    }
    
    static GetContentArray = function()
    {
        if (__VMStackEmpty()) return [];
        return __vmCurrent.GetContentArray();
    }
    
    #endregion
    
    
    
    #region Option
    
    static GetOption = function(_index)
    {
        if (__VMStackEmpty()) return;
        return __vmCurrent.GetOption(_index);
    }
    
    static GetOptionChosen = function(_index)
    {
        if (__VMStackEmpty()) return;
        return __vmCurrent.GetOptionChosen(_index);
    }
    
    static GetOptionCount = function()
    {
        if (__VMStackEmpty()) return 0;
        return __vmCurrent.GetOptionCount();
    }
    
    static GetOptionMetadata = function(_index)
    {
        if (__VMStackEmpty()) return;
        return __vmCurrent.GetOptionMetadata(_index);
    }
    
    static GetOptionConditionBool = function(_index)
    {
        if (__VMStackEmpty()) return;
        return __vmCurrent.GetOptionConditionBool(_index);
    }
    
    static GetOptionArray = function()
    {
        if (__VMStackEmpty()) return [];
        return __vmCurrent.GetOptionArray();
    }
    
    #endregion
    
    
    
    /// @param nodeTitle
    static FindNode = function(_title)
    {
        if (__VMStackEmpty()) return;
        return __vmCurrent.FindNode(_title);
    }
    
    static GetCurrentSource = function()
    {
        if (__VMStackEmpty()) return;
        return __vmCurrent.GetCurrentSource();
    }
    
    static GetCurrentNodeTitle = function()
    {
        if (__VMStackEmpty()) return;
        return __vmCurrent.GetCurrentNodeTitle();
    }
    
    static GetCurrentNodeMetadata = function()
    {
        if (__VMStackEmpty()) return;
        return __vmCurrent.GetCurrentNodeMetadata();
    }
    
    static VerifyIsLoaded = function()
    {
        if (__VMStackEmpty()) return false;
        return __vmCurrent.VerifyIsLoaded();
    }
}