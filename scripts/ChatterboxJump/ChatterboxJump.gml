// Feather disable all

/// Jumps to a specific node in a source file
///
/// @param chatterbox
/// @param nodeTitle
/// @param [filename]

function ChatterboxJump(_chatterbox, _title, _filename = undefined)
{
    return _chatterbox.Jump(_title, _filename);
}
