/// Selects an option, either defined by a Yarn shortcut ( -> ) or a Yarn option ( [[text|node]] )
///
/// @param chatterbox
/// @param optionIndex

function chatterbox_select(_chatterbox, _index)
{
    with(_chatterbox)
    {
        if (!verify_is_loaded())
        {
            __chatterbox_error("Could not select option because \"", filename, "\" is not loaded");
            return undefined;
        }
        else
        {
            if ((_index < 0) || (_index >= array_length(option)))
            {
                __chatterbox_trace("Out of bounds option index (got ", _index, ", maximum index for options is ", array_length(option)-1, ")");
                return undefined;
            }
            
            current_instruction = option_instruction[_index];
            __chatterbox_vm();
        }
    }
}