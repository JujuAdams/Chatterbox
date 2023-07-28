// Feather disable all
/// Returns the metadata for the given node from the given source
///
/// @param sourceName
/// @param nodeTitle

function ChatterboxSourceGetNodeMetadata(_sourceName, _nodeTitle)
{
    if (!ChatterboxIsLoaded(_sourceName))
    {
        __ChatterboxError("Source file \"", _sourceName, "\" has not been loaded");
        return [];
    }
    
    var _node = global.chatterboxFiles[? _sourceName].FindNode(_nodeTitle);
    if (_node == undefined)
    {
        __ChatterboxError("Node \"", _nodeTitle, "\" does not exist in source \"", _sourceName, "\"");
    }
    
    return _node.metadata;
}
