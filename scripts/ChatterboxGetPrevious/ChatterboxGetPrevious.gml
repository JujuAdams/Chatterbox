// Feather disable all

/// Returns the title of the previous node visited by the given chatterbox
///
/// @param chatterbox

function ChatterboxGetPrevious(_chatterbox)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.GetPreviousNodeTitle();
}
