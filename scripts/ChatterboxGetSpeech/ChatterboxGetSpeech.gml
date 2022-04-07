/// Returns the string after the first colon in a Chatterbox's content.
///
/// @param chatterbox
/// @param contentIndex

function ChatterboxGetSpeech(_chatterbox, _index)
{
	var _str = ChatterboxGetContent(_chatterbox, _index);
	if (_str != undefined)
	{
		var _colon = string_pos(":", _str);
	    var _space;
	    if (string_pos(" ", _str) == _colon+1)
		{
	        _space = 2;
	    }
		else
		{
	        _space = 1;
	    }
	    var _speech = string_copy(_str, _colon+_space, string_length(_str)-_colon);
	    return _speech;
	} else return undefined;
}