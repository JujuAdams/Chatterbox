/// Returns if the given value is a chatterbox created by chatterbox_create()
///
/// @param value

function is_chatterbox(_value)
{
    return (instanceof(_value) == "__chatterbox_class");
}