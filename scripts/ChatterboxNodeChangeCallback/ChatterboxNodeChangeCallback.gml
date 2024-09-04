// Feather disable all

/// Sets a callback functiojn that is executed whenever a chatterbox changes node. The callback
/// will be executed in the following situations:
/// 
/// - Jumping to a node
/// - Hopping to a node
/// - Hopping back to a node
/// 
/// Three arguments are passed to the callback function: the name of the old node and the name of
/// the new node (in that order).

function ChatterboxNodeChangeCallback(_function)
{
    static _system = __ChatterboxSystem();
    
    _system.__nodeChangeCallback = _function;
}