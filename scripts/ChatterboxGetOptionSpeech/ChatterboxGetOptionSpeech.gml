// Feather disable all

/// Returns the string after the first colon in a Chatterbox option.
///
/// @param chatterbox
/// @param optionIndex
/// @param [default=""]

function ChatterboxGetOptionSpeech(_chatterbox, _index, _default = "")
{
    return __ChatterboxContentExtractSpeech(ChatterboxGetOption(_chatterbox, _index), _default);
}