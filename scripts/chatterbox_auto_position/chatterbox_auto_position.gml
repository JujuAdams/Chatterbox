/// @param chatterbox
/// @param Text->TextY
/// @param Text->OptionX
/// @param Text->OptionY
/// @param Option->OptionY

var _chatterbox      = argument0;
var _text_text_y     = argument1;
var _text_option_x   = argument2;
var _text_option_y   = argument3;
var _option_option_y = argument4;

//Control position of text
var _y_offset = 0;
    
var _count = chatterbox_text_get_number(_chatterbox, false);
for(var _i = 0; _i < _count; _i++)
{
    chatterbox_text_set(_chatterbox, false, _i, CHATTERBOX_PROPERTY.XY, 0, _y_offset );
    
    _y_offset = chatterbox_text_get(_chatterbox, false, _i, CHATTERBOX_PROPERTY.Y)
              + chatterbox_text_get(_chatterbox, false, _i, CHATTERBOX_PROPERTY.HEIGHT)
              + _text_text_y;
}

if (_count > 0) _y_offset -= _option_option_y;

//Control position and colour of options
var _x_offset  = chatterbox_text_get(_chatterbox, false, 0, CHATTERBOX_PROPERTY.X)
               + _text_option_x;     
    _y_offset += _text_option_y;

var _count = chatterbox_text_get_number(_chatterbox, true);
for(var _i = 0; _i < _count; _i++)
{
    chatterbox_text_set(_chatterbox, true, _i, CHATTERBOX_PROPERTY.XY, _x_offset, _y_offset );
    
    _y_offset = chatterbox_text_get(_chatterbox, true, _i, CHATTERBOX_PROPERTY.Y)
              + chatterbox_text_get(_chatterbox, true, _i, CHATTERBOX_PROPERTY.HEIGHT)
              + _option_option_y;
}