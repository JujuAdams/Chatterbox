/// @param chatterbox

function chatterbox_is_stopped(_chatterbox)
{
    if (!is_chatterbox(_chatterbox)) return undefined;
    return _chatterbox.stopped;
}