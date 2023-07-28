// Feather disable all
/// Returns the string behind the first colon in a content string, excluding the speaker data if there's any
///
/// @param chatterbox
/// @param contentIndex
/// @param [default=""]

function ChatterboxGetContentSpeakerData(_chatterbox, _index, _default = "")
{
    return __ChatterboxContentExtractSpeakerData(ChatterboxGetContent(_chatterbox, _index), _default);
}

function __ChatterboxContentExtractSpeakerData(_string, _default = "")
{
    if (_string == undefined) return _default; //Catch invalid index 
    
    var _colon_pos = string_pos(CHATTERBOX_SPEAKER_DELIMITER, _string);
    if (_colon_pos <= 0) return _default; //No speaker
    
    var _start_pos = string_pos(CHATTERBOX_SPEAKER_DATA_START, _string);
    var _end_pos   = string_pos(CHATTERBOX_SPEAKER_DATA_END,   _string);
    
    if (_start_pos <= 0) //No start symbol
    {
        if (_end_pos <= 0) //No end symbol
        {
            return _default;
        }
        else if (_end_pos < _colon_pos)
        {
            __ChatterboxError("Speaker data end symbol found (", CHATTERBOX_SPEAKER_DATA_END, ") but there was no matching start symbol (", CHATTERBOX_SPEAKER_DATA_START, ")\n\"", _string, "\"");
        }
        else //No open separator and the close separator is somewhere in the speech string
        {
            return _default;
        }
    }
    else if (_start_pos < _colon_pos) //Start symbol is before the colon (where it should be)
    {
        if (_end_pos < _start_pos)
        {
            __ChatterboxError("Speaker data start symbol found (", CHATTERBOX_SPEAKER_DATA_START, ") but there was no matching end symbol (", CHATTERBOX_SPEAKER_DATA_END, ")\n\"", _string, "\"");
        }
        else
        {
            //Found the end symbol! We may proceed
            var _speaker_data = string_copy(_string, _start_pos + string_length(CHATTERBOX_SPEAKER_DATA_START), _end_pos - _start_pos - string_length(CHATTERBOX_SPEAKER_DATA_START));
            return __ChatterboxStripOuterWhitespace(_speaker_data);
        }
    }
    else if (_end_pos < _colon_pos) //End symbol is before the colon, but the start symbol (if one exists) is not
    {
        __ChatterboxError("Speaker data end symbol found (", CHATTERBOX_SPEAKER_DATA_END, ") but there was no matching start symbol (", CHATTERBOX_SPEAKER_DATA_START, ")\n\"", _string, "\"");
    }
    
    return _default;
}
