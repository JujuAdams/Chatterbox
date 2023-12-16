// Feather disable all
/// Returns the file tags for the given source
///
/// @param aliasName

function ChatterboxSourceGetTags(_aliasName)
{
    _aliasName = __ChatterboxReplaceBackslashes(_aliasName);
    
    if (!ChatterboxIsLoaded(_aliasName))
    {
        __ChatterboxError("\"", _aliasName, "\" has not been loaded");
        return [];
    }
    
    return global.chatterboxFiles[? _aliasName].GetTags();
}
