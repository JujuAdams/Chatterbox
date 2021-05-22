/// Returns the metadata struct for the current node of the given chatterbox
///
/// @param chatterbox

function ChatterboxGetCurrentMetadata(_chatterbox)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    _chatterbox.VerifyIsLoaded();
    return _chatterbox.current_node.metadata;
}