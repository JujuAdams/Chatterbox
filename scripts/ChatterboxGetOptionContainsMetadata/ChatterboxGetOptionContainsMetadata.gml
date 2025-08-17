// Feather disable all

/// Returns whether the given option contains a particular metadata string. If the index provided
/// is out of bounds then this function will return `false`.
/// 
/// If the optional `respectCondition` parameter is set to `true` (as it is by default) then this
/// function will always return `false` if the option failed its condition check.
/// 
/// @param chatterbox
/// @param optionIndex
/// @param metadata
/// @param [respectCondition=true]

function ChatterboxGetOptionContainsMetadata(_chatterbox, _index, _metadata, _respectCondition = true)
{
    if (!IsChatterbox(_chatterbox)) return false;
    return _chatterbox.GetOptionContainsMetadata(_index, _metadata, _respectCondition);
}