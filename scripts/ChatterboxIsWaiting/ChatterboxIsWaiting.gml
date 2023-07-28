// Feather disable all
/// Returns if the given chatterbox is in a "waiting" state, either due to a Yarn <<wait>> command or singleton behaviour
///
/// @param chatterbox

function ChatterboxIsWaiting(_chatterbox)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.IsWaiting();
}
