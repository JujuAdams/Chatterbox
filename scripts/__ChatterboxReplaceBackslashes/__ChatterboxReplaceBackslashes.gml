// Feather disable all

function __ChatterboxReplaceBackslashes(_aliasName)
{
    return CHATTERBOX_REPLACE_ALIAS_BACKSLASHES? string_replace_all(_aliasName, "\\", "/") : _aliasName;
}