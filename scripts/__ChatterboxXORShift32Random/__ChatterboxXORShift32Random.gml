// Feather disable all

function __ChatterboxXORShiftRandom()
{
    static _state = floor(1000000*date_current_datetime() + display_mouse_get_x() + display_get_width()*display_mouse_get_y());
    _state ^= _state << 13;
    _state ^= _state >> 17;
    _state ^= _state <<  5;
    return abs(_state);
}