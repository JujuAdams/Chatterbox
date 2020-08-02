/// @param chatterbox

function chatterbox_continue(_chatterbox)
{
    with(_chatterbox)
    {
        if (!waiting)
        {
            __chatterbox_error("Can't continue, provided chatterbox isn't waiting");
            return undefined;
        }
        
        local_scope = other;
        
        current_instruction = wait_instruction;
        __chatterbox_vm();
    }
}