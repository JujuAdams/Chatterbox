// Feather disable all
/// Returns the string after the first colon in a Chatterbox's content.
///
/// @param chatterbox
/// @param contentIndex
/// @param [default=""]

function ChatterboxGetContentSpeech(_chatterbox, _index, _default = "")
{
    return __ChatterboxContentExtractSpeech(ChatterboxGetContent(_chatterbox, _index), _default);
}

function __ChatterboxContentExtractSpeech(_string, _default = "")
{
    if (_string == undefined) return _default; //Catch invalid index 
    
    var _colon_pos = string_pos(CHATTERBOX_SPEAKER_DELIMITER, _string);
    if (_colon_pos <= 0) return _string;
    
    var _speech = string_delete(_string, 1, _colon_pos + string_length(CHATTERBOX_SPEAKER_DELIMITER) - 1);
    return __ChatterboxStripOuterWhitespace(_speech);
}
