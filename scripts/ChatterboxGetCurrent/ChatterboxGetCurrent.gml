/// Returns the title of the current node of the given chatterbox
///
/// @param chatterbox

function ChatterboxGetCurrent(_chatterbox)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    _chatterbox.VerifyIsLoaded();
    return _chatterbox.current_node.title;
}