// Feather disable all
/// Returns the total number of content strings in the given chatterbox
///
/// @param chatterbox

function ChatterboxGetContentCount(_chatterbox)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.GetContentCount();
}
