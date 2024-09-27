// Feather disable all

/// Advances dialogue in a chatterbox that's "waiting", either due to a Yarn <<wait>> command or singleton behaviour
///
/// @param chatterbox
/// @param [name]

function ChatterboxContinue(_chatterbox, _name = "")
{
    return _chatterbox.Continue(_name);
}
