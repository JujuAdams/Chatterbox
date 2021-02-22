/// Selects an option, either defined by a Yarn option ( -> ) or a Yarn option ( [[text|node]] )
///
/// @param chatterbox
/// @param optionIndex

function ChatterboxSelect(_chatterbox, _index)
{
    with(_chatterbox)
    {
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could not select option because \"", filename, "\" is not loaded");
            return undefined;
        }
        else
        {
            if ((_index < 0) || (_index >= array_length(option)))
            {
                __ChatterboxTrace("Out of bounds option index (got ", _index, ", maximum index for options is ", array_length(option)-1, ")");
                return undefined;
            }
            
            if (optionConditionBool[_index])
            {
                current_instruction = option_instruction[_index];
                __ChatterboxVM();
            }
            else
            {
                __ChatterboxTrace("Warning! Trying to select an option that failed its conditional check");
            }
        }
    }
}