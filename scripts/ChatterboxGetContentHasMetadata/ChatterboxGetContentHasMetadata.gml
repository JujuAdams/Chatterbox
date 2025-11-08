// Feather disable all

/// Returns if a piece of content has metadata that precisely matches the given search string. If
/// an invalid index is given, this function will return `false`.
///
/// @param chatterbox
/// @param contentIndex
/// @param searchString

function ChatterboxGetContentHasMetadata(_chatterbox, _index, _searchString)
{
    if (!IsChatterbox(_chatterbox)) return false;
    return _chatterbox.GetContentHasMetadata(_index, _searchString);
}
