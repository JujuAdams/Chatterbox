/// Returns an option string with the given index in the given chatterbox
///
/// @param chatterbox
/// @param index

function chatterbox_get_option(_chatterbox, _index)
{
    if (!is_chatterbox(_chatterbox)) return undefined;
    _chatterbox.verify_is_loaded();
    if ((_index < 0) || (_index >= array_length(_chatterbox.option))) return undefined;
    return _chatterbox.option[_index];
}