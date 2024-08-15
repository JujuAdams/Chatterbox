// Feather disable all

/// @param value

function __ChatterboxString(_value)
{
    if (is_array(_value)) return __ChatterboxArrayToString(_value);
    return string(_value);
}