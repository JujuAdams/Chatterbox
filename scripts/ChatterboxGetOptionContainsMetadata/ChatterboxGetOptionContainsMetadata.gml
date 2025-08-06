// Feather disable all

/// Returns whether the given option contains a particular metadata string. If the index provided
/// is out of bounds then this function will return `false`.
/// 
/// @param chatterbox
/// @param index
/// @param metadata

function ChatterboxGetOptionContainsMetadata(_chatterbox, _index, _metadata)
{
    if (!IsChatterbox(_chatterbox)) return false;
    return _chatterbox.GetOptionContainsMetadata(_index, _metadata);
}