// Feather disable all

function __ChatterboxVerifyDatatypes(_a, _b)
{
    if ((_a == undefined) || (_b == undefined)) return true;
    if (is_numeric(_a) && is_numeric(_b)) return true;
    if (is_string( _a) && is_string( _b)) return true;
    if (is_bool(   _a) && is_bool(   _b)) return true;
    return false;
}