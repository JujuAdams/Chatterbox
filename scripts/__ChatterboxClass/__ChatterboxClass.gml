// Feather disable all

/// @param filename
/// @param singletonText
/// @param localScope

function __ChatterboxClass(_filename, _singleton, _localScope) constructor
{
    static _system = __ChatterboxSystem();
    
    if (!is_string(_filename))
    {
        __ChatterboxError("Source files must be strings (got \"" + string(_filename) + "\")");
        return undefined;
    }
    
    _filename = __ChatterboxReplaceBackslashes(_filename);
    
    if (!ChatterboxIsLoaded(_filename))
    {
        __ChatterboxError("Could not create chatterbox because \"", _filename, "\" is not loaded");
        return undefined;
    }
    
    vmCurrent = new __ChatterboxClassVM(_filename, _singleton, _localScope);
    vmStack = [vmCurrent];
    
    
    
    #region Flow
    
    //Jumps to a given node in the given source
    static Jump = function(_title, _filename = undefined)
    {
        return vmCurrent.Jump(_title, _filename);
    }
    
    //Jumps to a given node in the given source
    static Hop = function(_title, _filename = undefined)
    {
        return vmCurrent.Hop(_title, _filename);
    }
    
    //Jumps to a given node in the given source
    static HopBack = function()
    {
        return vmCurrent.HopBack();
    }
    
    static Select = function(_index)
    {
        return vmCurrent.Select(_index);
    }
    
    static Continue = function(_name = "")
    {
        return vmCurrent.Continue();
    }
    
    static Wait = function(_name = "")
    {
        return vmCurrent.Wait(_name);
    }
    
    static Stop = function()
    {
        return vmCurrent.Stop();
    }
    
    static IsWaiting = function()
    {
        return vmCurrent.IsWaiting();
    }
    
    static IsStopped = function()
    {
        return vmCurrent.IsStopped();
    }
    
    static FastForward = function()
    {
        return vmCurrent.FastForward();
    }
    
    #endregion
    
    
    
    #region Content
    
    static GetContent = function(_index)
    {
        return vmCurrent.GetContent(_index);
    }
    
    static GetContentCount = function()
    {
        return vmCurrent.GetContentCount();
    }
    
    static GetContentMetadata = function(_index)
    {
        return vmCurrent.GetContentMetadata(_index);
    }
    
    static GetContentArray = function()
    {
        return vmCurrent.GetContentArray();
    }
    
    #endregion
    
    
    
    #region Option
    
    static GetOption = function(_index)
    {
        return vmCurrent.GetOption(_index);
    }
    
    static GetOptionChosen = function(_index)
    {
        return vmCurrent.GetOptionChosen(_index);
    }
    
    static GetOptionCount = function()
    {
        return vmCurrent.GetOptionCount();
    }
    
    static GetOptionMetadata = function(_index)
    {
        return vmCurrent.GetOptionMetadata(_index);
    }
    
    static GetOptionConditionBool = function(_index)
    {
        return vmCurrent.GetOptionConditionBool(_index);
    }
    
    static GetOptionArray = function()
    {
        return vmCurrent.GetOptionArray();
    }
    
    #endregion
    
    
    
    /// @param nodeTitle
    static FindNode = function(_title)
    {
        return vmCurrent.FindNode(_title);
    }
    
    static GetCurrentSource = function()
    {
        return vmCurrent.GetCurrentSource();
    }
    
    static GetCurrentNodeTitle = function()
    {
        return vmCurrent.GetCurrentNodeTitle();
    }
    
    static GetCurrentNodeMetadata = function()
    {
        return vmCurrent.GetCurrentNodeMetadata();
    }
    
    static VerifyIsLoaded = function()
    {
        return vmCurrent.VerifyIsLoaded();
    }
}