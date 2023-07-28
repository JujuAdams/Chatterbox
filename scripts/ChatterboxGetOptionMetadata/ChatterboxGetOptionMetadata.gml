// Feather disable all
/// Returns an option string with the given index in the given chatterbox
///
/// @param chatterbox
/// @param index

function ChatterboxGetOptionMetadata(_chatterbox, _index)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.GetOptionMetadata(_index);
}
