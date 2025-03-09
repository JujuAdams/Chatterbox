// Feather disable all

/// Returns the names of every node in a source file.
///
/// @param aliasName

function ChatterboxGetSourceNodeArray(_aliasName)
{
    static _system = __ChatterboxSystem();
    
    _aliasName = __ChatterboxReplaceBackslashes(_aliasName);
    
    if (!ChatterboxIsLoaded(_aliasName))
    {
        __ChatterboxError("Source file \"", _aliasName, "\" has not been loaded");
        return false;
    }
    
    return _system.__files[? _aliasName].GetNodeArray();
}
