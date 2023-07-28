// Feather disable all
/// Returns the metadata struct for the current node of the given chatterbox
///
/// @param chatterbox

function ChatterboxGetCurrentMetadata(_chatterbox)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.GetCurrentNodeMetadata();
}
