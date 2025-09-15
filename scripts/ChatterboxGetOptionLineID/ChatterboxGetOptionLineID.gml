// Feather disable all

/// Returns the lined ID for the option with the given index in the given chatterbox. This line ID
/// is usually added via the Localisation system. Please refer to documentation for more details.
/// If an option has been given no line ID, this function will return `undefined`. Generally
/// speaking, this means you should run `ChatterboxLocalizationBuild()` again to attach line IDs to
/// text fragments that have been added.
///
/// @param chatterbox
/// @param index

function ChatterboxGetOptionLineID(_chatterbox, _index)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.GetOptionLineID(_index);
}
