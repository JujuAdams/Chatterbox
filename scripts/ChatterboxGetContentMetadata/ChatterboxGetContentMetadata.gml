// Feather disable all
/// Returns metadata associated with the content string with the given index in the given chatterbox
///
/// @param chatterbox
/// @param contentIndex

function ChatterboxGetContentMetadata(_chatterbox, _index)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.GetContentMetadata(_index);
}
