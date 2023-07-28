// Feather disable all
/// Returns an array of node titles for the given source
///
/// @param sourceName

function ChatterboxSourceGetNodeTitles(_sourceName)
{
    if (!ChatterboxIsLoaded(_sourceName))
    {
        __ChatterboxError("Source file \"", _sourceName, "\" has not been loaded");
        return [];
    }
    
    var _i = 0;
    var _array = [];
    
    repeat (array_length(global.chatterboxFiles[? _sourceName].nodes))
    {
        array_push(_array,global.chatterboxFiles[? _sourceName].nodes[_i].title);
        ++_i;
    }
    
    return _array;
}
