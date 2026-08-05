// Feather disable all

/// Returns the raw, unprocessed text from the currently loaded localization file. If no text is
/// found then this function will return `undefined`. The string will be returned as-is and inline
/// variables will not be evaluated. The line ID should be passed to this function without the
/// preceding hash # character.
/// 
/// @param fileAlias
/// @param nodeTitle
/// @param lineID

function ChatterboxLocalizationGetRaw(_fileAlias, _nodeTitle, _lineID)
{
    static _system = __ChatterboxSystem();
    return _system.__localisationMap[? _fileAlias + ":" + _nodeTitle + ":#" + _lineID];
}
