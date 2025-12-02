// Feather disable all

/// Returns if an option has a condition attached.
///
/// @param chatterbox
/// @param index

function ChatterboxGetOptionHasCondition(_chatterbox, _index)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.GetOptionHasCondition(_index);
}