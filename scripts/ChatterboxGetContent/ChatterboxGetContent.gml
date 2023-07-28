// Feather disable all
/// Returns the content string with the given index in the given chatterbox
///
/// @param chatterbox
/// @param contentIndex

function ChatterboxGetContent(_chatterbox, _index)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.GetContent(_index);
}
