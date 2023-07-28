// Feather disable all
/// Jumps to a specific node in a source file
///
/// @param chatterbox
/// @param nodeTitle
/// @param [filename]

function ChatterboxHop()
{
    var _chatterbox = argument[0];
    var _title      = argument[1];
    var _filename   = (argument_count > 2)? argument[2] : undefined;
    
    return _chatterbox.Hop(_title, _filename);
}
