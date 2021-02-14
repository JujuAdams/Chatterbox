/// Returns a content string with the given index in the given chatterbox
///
/// @param chatterbox
/// @param contentIndex

function ChatterboxGetContent(_chatterbox, _index)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    _chatterbox.verify_is_loaded();
    if ((_index < 0) || (_index >= array_length(_chatterbox.content))) return undefined;
    return _chatterbox.content[_index];
}