// Feather disable all
/// Returns the name of the file that is currently being accessed for the given chatterbox
///
/// @param chatterbox

function ChatterboxGetCurrentSource(_chatterbox)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.GetCurrentSource();
}
