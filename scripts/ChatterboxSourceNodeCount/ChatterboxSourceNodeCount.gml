/// @param sourceName

function ChatterboxSourceNodeCount(_sourceName)
{
    if (!ChatterboxIsLoaded(_sourceName))
    {
        __ChatterboxError("Source file \"", _sourceName, "\" has not been loaded");
        return false;
    }
    
    return array_length(global.chatterboxFiles[? _sourceName].nodes);
}