// Feather disable all

/// Returns whether the condition attached to an option has passed (`true`) or failed (`false`).
/// If an option doesn't have a condition then this function will return `true`.
///
/// @param chatterbox
/// @param index

function ChatterboxGetOptionConditionBool(_chatterbox, _index)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.GetOptionConditionBool(_index);
}
