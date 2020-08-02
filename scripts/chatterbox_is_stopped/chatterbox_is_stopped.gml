/// Return if a chatterbox has stopped, either due to a <<stop>> command or because it has run out of content (text) to display
///
/// @param chatterbox

function chatterbox_is_stopped(_chatterbox)
{
    if (!is_chatterbox(_chatterbox)) return undefined;
    return _chatterbox.stopped;
}