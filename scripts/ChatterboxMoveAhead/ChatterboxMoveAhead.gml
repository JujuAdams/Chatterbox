// Feather disable all

/// @param chatterbox

function ChatterboxMoveAhead(_chatterbox)
{
    static _vmInstanceStack = __ChatterboxSystem().__vmInstanceStack;
    
    if (_chatterbox == "all")
    {
        var _i = 0;
        repeat(array_length(_vmInstanceStack))
        {
            ChatterboxMoveAhead(_vmInstanceStack[_i]);
            ++_i;
        }
        
        return;
    }
    
    return _chatterbox.MoveAhead();
}