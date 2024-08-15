// Feather disable all
/// Returns the string behind the first colon in a content string, excluding the speaker data if there's any
///
/// @param chatterbox
/// @param contentIndex
/// @param [default=""]

function ChatterboxGetContentSpeakerData(_chatterbox, _index, _default = "")
{
    return __ChatterboxContentExtractSpeakerData(ChatterboxGetContent(_chatterbox, _index), _default);
}
