/// Advances dialogue in a chatterbox that's "waiting", either due to a Yarn <<wait>> command or singleton behaviour
///
/// @param chatterbox

function chatterbox_continue(_chatterbox)
{
    with(_chatterbox)
    {
        if (!verify_is_loaded())
        {
            __chatterbox_error("Could not continue because \"", filename, "\" is not loaded");
            return undefined;
        }
        else
        {
            if (!waiting)
            {
                __chatterbox_error("Can't continue, provided chatterbox isn't waiting");
                return undefined;
            }
            
            current_instruction = wait_instruction;
            __chatterbox_vm();
        }
    }
}