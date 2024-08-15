// Feather disable all

function __ChatterboxStripOuterWhitespace(_string)
{
    return __ChatterboxStripLeadingWhitespace(__ChatterboxStripTrailingWhitespace(_string));
}