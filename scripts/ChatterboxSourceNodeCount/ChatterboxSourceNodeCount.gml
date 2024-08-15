// Feather disable all
/// Returns the number of nodes in the given source
///
/// @param aliasName

function ChatterboxSourceNodeCount(_aliasName)
{
    static _system = __ChatterboxSystem();
    
    _aliasName = __ChatterboxReplaceBackslashes(_aliasName);
    
    if (!ChatterboxIsLoaded(_aliasName))
    {
        __ChatterboxError("Source file \"", _aliasName, "\" has not been loaded");
        return false;
    }
    
    return _system.__files[? _aliasName].NodeCount();
}
