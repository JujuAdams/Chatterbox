// Feather disable all

/// Returns the index of the option with the given metadata string. If there are multiple options
/// that contain the metadata string then the first option index is returned. If no option has the
/// metadata string then this function returns `undefined`.
/// 
/// If the optional `respectCondition` parameter is set to `true` (as it is by default) then this
/// function will always ignore options that have failed their condition check (if they have one).
///
/// @param chatterbox
/// @param metadata
/// @param [respectCondition=true]

function ChatterboxFindOptionWithMetadata(_chatterbox, _metadata, _respectCondition = true)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.FindOptionWithMetadata(_metadata, _respectCondition);
}