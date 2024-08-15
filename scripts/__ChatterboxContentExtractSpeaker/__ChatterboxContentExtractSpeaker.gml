// Feather disable all

function __ChatterboxContentExtractSpeaker(_string, _default = "")
{
    if (_string == undefined) return _default; //Catch invalid index 
    
    var _colon_pos = string_pos(CHATTERBOX_SPEAKER_DELIMITER,  _string);
    if (_colon_pos <= 0) return _default; //No speaker
    var _split_pos = _colon_pos;
    
    var _start_pos = string_pos(CHATTERBOX_SPEAKER_DATA_START, _string);
    if ((_start_pos > 0) && (_start_pos < _split_pos)) _split_pos = _start_pos; //Choose whichever symbol comes first
    
    var _speaker = string_copy(_string, 1, _split_pos-1);
    return __ChatterboxStripOuterWhitespace(_speaker);
}