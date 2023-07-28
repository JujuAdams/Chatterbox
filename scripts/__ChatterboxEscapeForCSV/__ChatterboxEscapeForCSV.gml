// Feather disable all
function __ChatterboxEscapeForCSV(_string)
{
    return string_replace_all(_string, "\"", "\"\"");
}
