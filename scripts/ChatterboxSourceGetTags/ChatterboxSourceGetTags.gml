// Feather disable all
/// Returns the file tags for the given source
///
/// @param sourceName

function ChatterboxSourceGetTags(_sourceName)
{
    if (!ChatterboxIsLoaded(_sourceName))
    {
        __ChatterboxError("Source file \"", _sourceName, "\" has not been loaded");
        return [];
    }
    
    return global.chatterboxFiles[? _sourceName].GetTags();
}
