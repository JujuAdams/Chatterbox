// Feather disable all
/// Returns the string after the first colon in a Chatterbox's content.
///
/// @param chatterbox
/// @param contentIndex
/// @param [default=""]

function ChatterboxGetContentSpeech(_chatterbox, _index, _default = "")
{
    return __ChatterboxContentExtractSpeech(ChatterboxGetContent(_chatterbox, _index), _default);
}