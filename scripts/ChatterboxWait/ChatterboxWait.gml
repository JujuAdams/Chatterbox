// Feather disable all
/// Forces a chatterbox to wait at the current instruction
///
/// @param chatterbox
/// @param [name=""]

function ChatterboxWait(_chatterbox, _name = "")
{
    return _chatterbox.Wait(_name);
}
