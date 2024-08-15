// Feather disable all

/// @param [value...]

function __ChatterboxError()
{
    var _string = "";
    
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    if (os_browser != browser_not_a_browser)
    {
        _string += "\n \n" + string(debug_get_callstack());
        throw ("Chatterbox " + CHATTERBOX_VERSION + ":\n" + _string);
    }
    else
    {
        show_error("Chatterbox " + CHATTERBOX_VERSION + ":\n" + _string + "\n ", false);
    }
    
    return _string;
}