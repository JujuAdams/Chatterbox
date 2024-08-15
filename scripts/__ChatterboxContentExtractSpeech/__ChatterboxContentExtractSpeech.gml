// Feather disable all

function __ChatterboxContentExtractSpeech(_string, _default)
{
    if (_string == undefined) return _default; //Catch invalid index 
    
    var _colon_pos = string_pos(CHATTERBOX_SPEAKER_DELIMITER, _string);
    if (_colon_pos <= 0) return _string;
    
    //Detect if colon is inside speaker data
    var _bracket_end_pos = string_pos(CHATTERBOX_SPEAKER_DATA_END, _string);
    if ((_bracket_end_pos > 0) && (_bracket_end_pos > _colon_pos))
    {
        var _bracket_start_pos = string_pos(CHATTERBOX_SPEAKER_DATA_START, _string);
        if ((_bracket_start_pos > 0) && (_bracket_start_pos < _colon_pos))
        {
            _string = string_delete(_string, 1, _bracket_end_pos + string_length(CHATTERBOX_SPEAKER_DATA_END) - 1);
            
            _colon_pos = string_pos(CHATTERBOX_SPEAKER_DELIMITER, _string);
            if (_colon_pos <= 0) return _string;
        }
    }
    
    var _speech = string_delete(_string, 1, _colon_pos + string_length(CHATTERBOX_SPEAKER_DELIMITER) - 1);
    return __ChatterboxStripOuterWhitespace(_speech);
}