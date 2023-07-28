// Feather disable all
/// Returns the total number of option strings in the given chatterbox
///
/// @param chatterbox

function ChatterboxGetOptionCount(_chatterbox)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.GetOptionCount();
}
