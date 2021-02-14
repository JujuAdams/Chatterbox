/// Returns the total number of option strings in the given chatterbox
///
/// @param chatterbox

function ChatterboxGetOptionCount(_chatterbox)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    _chatterbox.VerifyIsLoaded();
    return array_length(_chatterbox.option);
}