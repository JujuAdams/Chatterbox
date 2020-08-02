/// Returns if the given chatterbox is in a "waiting" state, either due to a Yarn <<wait>> command or singleton behaviour
///
/// @param chatterbox

function chatterbox_is_waiting(_chatterbox)
{
    if (!is_chatterbox(_chatterbox)) return undefined;
    return _chatterbox.waiting;
}