/// Skips text until the player is required to make a choice
///
/// @param chatterbox

function chatterbox_fast_forward(_chatterbox)
{
    if (!_chatterbox.verify_is_loaded())
    {
        __chatterbox_error("Could not fast forward because \"", filename, "\" is not loaded");
        return undefined;
    }
    
    if (chatterbox_is_stopped(_chatterbox))
    {
        __chatterbox_trace("Error! Chatterbox has stopped, cannot fast forward");
        return undefined;
    }
    
    if (chatterbox_get_option_count(_chatterbox) > 0)
    {
        __chatterbox_trace("Error! Player is being prompted to make a choice, cannot fast forward");
        return undefined;
    }
    
    while ((chatterbox_get_option_count(_chatterbox) <= 0) && chatterbox_is_waiting(_chatterbox) && !chatterbox_is_stopped(_chatterbox))
    {
        chatterbox_continue(_chatterbox);
    }
}