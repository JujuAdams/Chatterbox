// Feather disable all
/// Returns an array of node titles for the given source
///
/// @param aliasName

function ChatterboxSourceGetNodeTitles(_aliasName)
{
    _aliasName = __ChatterboxReplaceBackslashes(_aliasName);
    
    if (!ChatterboxIsLoaded(_aliasName))
    {
        __ChatterboxError("\"", _aliasName, "\" has not been loaded");
        return [];
    }
    
    var _i = 0;
    var _array = [];
    
    repeat (array_length(global.chatterboxFiles[? _aliasName].nodes))
    {
        array_push(_array,global.chatterboxFiles[? _aliasName].nodes[_i].title);
        ++_i;
    }
    
    return _array;
}
