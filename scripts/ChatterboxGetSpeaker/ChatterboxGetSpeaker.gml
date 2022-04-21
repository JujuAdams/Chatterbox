/// Returns the string behind the first colon in a line of dialogue, excluding the speaker data if there's any.
///
/// @param chatterbox
/// @param contentIndex

function ChatterboxGetSpeaker(_chatterbox, _index)
{
    var _str = ChatterboxGetContent(_chatterbox, _index);
    if (_str != undefined)
    {
        var _colon = string_pos(":", _str);
        if (_colon == 0)
        {
            show_debug_message("Chatterbox: No speaker found.") return "";
        }
        var _name = string_copy(_str, 1, _colon-1);
        var _c1 = CHATTERBOX_SPEAKERDATA_TAG_OPEN;
        var _c2 = CHATTERBOX_SPEAKERDATA_TAG_CLOSE;
        var _char_l = string_pos(_c1, _str);
        var _char_r = string_pos(_c2, _str);
        if (_char_l > 0 and _char_r < _colon) //If there are tags before the colon
        {
            _name = string_delete(_name, _char_l, _colon-_char_l+1); //Remove everything between the L bracket and the colon
        }
        return _name;
    } else return undefined;
}