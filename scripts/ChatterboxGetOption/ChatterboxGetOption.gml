/// Returns an option string with the given index in the given chatterbox
///
/// @param chatterbox
/// @param index

function ChatterboxGetOption(_chatterbox, _index)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    _chatterbox.VerifyIsLoaded();
    if ((_index < 0) || (_index >= array_length(_chatterbox.option))) return undefined;
    return _chatterbox.option[_index];
}