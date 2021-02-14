/// Skips text until the player is required to make a choice
///
/// @param chatterbox

function ChatterboxFastForward(_chatterbox)
{
    if (!_chatterbox.VerifyIsLoaded())
    {
        __ChatterboxError("Could not fast forward because \"", filename, "\" is not loaded");
        return undefined;
    }
    
    if (ChatterboxIsStopped(_chatterbox))
    {
        __ChatterboxTrace("Error! Chatterbox has stopped, cannot fast forward");
        return undefined;
    }
    
    if (ChatterboxGetOptionCount(_chatterbox) > 0)
    {
        __ChatterboxTrace("Error! Player is being prompted to make a choice, cannot fast forward");
        return undefined;
    }
    
    while ((ChatterboxGetOptionCount(_chatterbox) <= 0) && ChatterboxIsWaiting(_chatterbox) && !ChatterboxIsStopped(_chatterbox))
    {
        ChatterboxContinue(_chatterbox);
    }
}