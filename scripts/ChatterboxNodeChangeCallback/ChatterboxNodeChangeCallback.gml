// Feather disable all

/// Sets a callback function that is executed whenever a chatterbox changes node. The callback
/// will be executed in the following situations:
/// 
/// - Jumping to a node
/// - Hopping to a node
/// - Hopping back to a node
/// 
/// Three arguments are passed to the callback function: the name of the old node, the name of
/// the new node, and the type of instruction that caused the node to change (in that order). The
/// instruction type will be one of either `"jump"`, `"hop"`, or `"hopback"`.

function ChatterboxNodeChangeCallback(_function)
{
    static _system = __ChatterboxSystem();
    
    _system.__nodeChangeCallback = _function;
}
