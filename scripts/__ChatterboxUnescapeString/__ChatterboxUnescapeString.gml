// Feather disable all

function __ChatterboxUnescapeString(_in_string)
{
    var _out_string = _in_string;
    _out_string = string_replace_all(_out_string, "\\'", "'");
    _out_string = string_replace_all(_out_string, "\\\"", "\"");
    _out_string = string_replace_all(_out_string, "\\n", "\n");
    _out_string = string_replace_all(_out_string, "\\r", "\r");
    _out_string = string_replace_all(_out_string, "\\t", "\t");
    _out_string = string_replace_all(_out_string, "\\<", "<");
    _out_string = string_replace_all(_out_string, "\\>", ">");
    _out_string = string_replace_all(_out_string, "\\{", "{");
    _out_string = string_replace_all(_out_string, "\\}", "}");
    _out_string = string_replace_all(_out_string, "\\#", "#");
    _out_string = string_replace_all(_out_string, "\\\\", "\\");
    return _out_string;
}