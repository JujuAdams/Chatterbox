// Feather disable all
/// Returns if the given value is a chatterbox created by ChatterboxCreate()
///
/// @param value

function IsChatterbox(_value)
{
    return (instanceof(_value) == "__ChatterboxClass");
}
