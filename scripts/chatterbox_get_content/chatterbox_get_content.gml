/// @param chatterbox
/// @param index

function chatterbox_get_content(_chatterbox, _index)
{
    if (!is_chatterbox(_chatterbox)) return undefined;
    if ((_index < 0) || (_index >= array_length(_chatterbox.content))) return undefined;
    
    return _chatterbox.content[_index];
}