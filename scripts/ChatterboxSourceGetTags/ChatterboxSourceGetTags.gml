// Feather disable all
/// Returns the file tags for the given source
///
/// @param aliasName

function ChatterboxSourceGetTags(_aliasName)
{
    static _system = __ChatterboxSystem();
    
    _aliasName = __ChatterboxReplaceBackslashes(_aliasName);
    
    if (!ChatterboxIsLoaded(_aliasName))
    {
        __ChatterboxError("\"", _aliasName, "\" has not been loaded");
        return [];
    }
    
    return _system.__files[? _aliasName].GetTags();
}
