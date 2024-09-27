// Feather disable all

/// Advances dialogue in a chatterbox that's "waiting", either due to a Yarn <<wait>> command or singleton behaviour
///
/// @param chatterbox
/// @param [name=""]

function ChatterboxContinue(_chatterbox, _name = "")
{
    static _vmInstanceStack = __ChatterboxSystem().__vmInstanceStack;
    
    if (_chatterbox == "all")
    {
        var _i = 0;
        repeat(array_length(_vmInstanceStack))
        {
            ChatterboxContinue(_vmInstanceStack[_i], _name);
            ++_i;
        }
        
        return;
    }
    
    return _chatterbox.Continue(_name);
}
