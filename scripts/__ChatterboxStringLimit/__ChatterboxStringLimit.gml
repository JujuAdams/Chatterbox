// Feather disable all

function __ChatterboxStringLimit(_string, _max_length)
{
    _max_length = max(4, _max_length);
    
    _string = string_replace_all(_string, "\n", "\\n");
    _string = string_replace_all(_string, "\r", "");
    
    if (string_length(_string) <= 20) return _string;
    
    return string_copy(_string, 1, _max_length-3) + "...";
}