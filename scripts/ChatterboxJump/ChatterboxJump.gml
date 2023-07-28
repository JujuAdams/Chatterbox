// Feather disable all
/// Hops to a specific node in a source file. You can hop back with with <<hopback>>
///
/// @param chatterbox
/// @param nodeTitle
/// @param [filename]

function ChatterboxJump()
{
    var _chatterbox = argument[0];
    var _title      = argument[1];
    var _filename   = (argument_count > 2)? argument[2] : undefined;
    
    return _chatterbox.Jump(_title, _filename);
}
