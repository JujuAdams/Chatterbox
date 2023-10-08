// Feather disable all
/// Returns how many times an option has been chosen.
///
/// @param chatterbox
/// @param index

function ChatterboxGetOptionVisited(_chatterbox, _index)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.GetOptionVisited(_index);
}
