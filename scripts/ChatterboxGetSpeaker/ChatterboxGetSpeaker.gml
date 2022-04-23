/// Returns the string behind the first colon in a line of dialogue, excluding the speaker data if there's any.
///
/// @param chatterbox
/// @param contentIndex

function ChatterboxGetSpeaker(_chatterbox, _index)
{
    var _str = ChatterboxGetContent(_chatterbox, _index);
    if (_str != undefined)
    {
        var _colon_pos = string_pos(":", _str);
        if (_colon_pos == 0)
        {
            show_debug_message("Chatterbox: No speaker found.") return "";
        }
        var _name = string_copy(_str, 1, _colon_pos-1);
        var _c1 = CHATTERBOX_SPEAKERDATA_TAG_OPEN;
        var _c2 = CHATTERBOX_SPEAKERDATA_TAG_CLOSE;
        var _tag_l = string_pos(_c1, _str);
        var _tag_r = string_pos(_c2, _str);
        if (_tag_l > 0 and _tag_r < _colon_pos) //If there are tags before the colon
        {
            _name = string_delete(_name, _tag_l, _colon_pos-_tag_l+1); //Remove everything between the first tag and the colon
        }
        return _name;
    } else return undefined;
}