// Feather disable all

/// Returns the string behind the first colon in an option string, excluding the speaker data if there's any
///
/// @param chatterbox
/// @param optionIndex
/// @param [default=""]

function ChatterboxGetOptionSpeakerData(_chatterbox, _index, _default = "")
{
    return __ChatterboxContentExtractSpeakerData(ChatterboxGetOption(_chatterbox, _index), _default);
}
