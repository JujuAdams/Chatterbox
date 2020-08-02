/// Returns the total number of option strings in the given chatterbox
///
/// @param chatterbox

function chatterbox_get_option_count(_chatterbox)
{
    if (!is_chatterbox(_chatterbox)) return undefined;
    return array_length(_chatterbox.option);
}