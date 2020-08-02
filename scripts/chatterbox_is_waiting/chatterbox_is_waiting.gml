/// @param chatterbox

function chatterbox_is_waiting(_chatterbox)
{
    if (!is_chatterbox(_chatterbox)) return undefined;
    return _chatterbox.waiting;
}