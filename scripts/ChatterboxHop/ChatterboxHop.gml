// Feather disable all

/// Jumps to a specific node in a source file. You can hop back with with <<hopback>>
///
/// @param chatterbox
/// @param nodeTitle
/// @param [filename]

function ChatterboxHop(_chatterbox, _title, _filename = undefined)
{
    return _chatterbox.Hop(_title, _filename);
}
