/// Advances dialogue in a chatterbox that's "waiting", either due to a Yarn <<wait>> command or singleton behaviour
///
/// @param chatterbox

function ChatterboxContinue(_chatterbox)
{
    with(_chatterbox)
    {
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could not continue because \"", filename, "\" is not loaded");
            return undefined;
        }
        else
        {
            if (!waiting)
            {
                __ChatterboxError("Can't continue, provided chatterbox isn't waiting");
                return undefined;
            }
            
            current_instruction = wait_instruction;
            __ChatterboxVM();
        }
    }
}