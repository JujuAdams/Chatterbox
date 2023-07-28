// Feather disable all
/// Returns a string that combines all individual content strings currently available in a chatterbox concatenated together
/// In singleton mode, this function (should!) return the same value as ChatterboxGetContent(chatterbox, 0)
///
/// @param chatterbox           Chatterbox to target
/// @param [separator=newline]  String to use to separate individual content strings. Defaults to a single newline character (\n)

function ChatterboxGetAllContentString(_chatterbox, _separator = "\n")
{
    if (!IsChatterbox(_chatterbox)) return "";
    
    var _string = "";
    
    var _count = _chatterbox.GetContentCount();
    var _i = 0;
    repeat(_count)
    {
        _string += _chatterbox.GetContent(_i);
        if (_i < _count-1) _string += _separator;
        ++_i;
    }
    
    return _string;
}
