// Feather disable all
/// Returns whether the given node exists in the given source
/// 
/// @param aliasName
/// @param nodeTitle

function ChatterboxSourceNodeExists(_aliasName, _nodeTitle)
{
    static _system = __ChatterboxSystem();
    
    _aliasName = __ChatterboxReplaceBackslashes(_aliasName);
    
    if (!ChatterboxIsLoaded(_aliasName))
    {
        __ChatterboxError("\"", _aliasName, "\" has not been loaded");
        return false;
    }
    
    return _system.__files[? _aliasName].NodeExists(_nodeTitle);
}
