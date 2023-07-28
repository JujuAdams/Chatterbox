// Feather disable all
/// Returns the number of nodes in the given source
///
/// @param sourceName

function ChatterboxSourceNodeCount(_sourceName)
{
    if (!ChatterboxIsLoaded(_sourceName))
    {
        __ChatterboxError("Source file \"", _sourceName, "\" has not been loaded");
        return false;
    }
    
    return global.chatterboxFiles[? _sourceName].NodeCount();
}
