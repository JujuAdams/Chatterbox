// Feather disable all

/// Returns the index of the option with the given metadata string. If there are multiple options
/// that contain the metadata string then the first option index is returned. If no option has the
/// metadata string then this function returns `undefined`.
///
/// @param chatterbox
/// @param metadata

function ChatterboxFindOptionWithMetadata(_chatterbox, _metadata)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.FindOptionWithMetadata(_metadata);
}