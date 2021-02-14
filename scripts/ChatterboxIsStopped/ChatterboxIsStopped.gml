/// Return if a chatterbox has stopped, either due to a <<stop>> command or because it has run out of content (text) to display
///
/// @param chatterbox

function ChatterboxIsStopped(_chatterbox)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    _chatterbox.VerifyIsLoaded();
    return _chatterbox.stopped;
}