/// @param chatterbox
/// @param inTextThreshold
/// @param inOptionThreshold
/// @param outTextThreshold
/// @param outOptionThreshold

var _chatterbox           = argument0;
var _in_threshold_text    = argument1;
var _in_threshold_option  = argument2;
var _out_threshold_text   = argument3;
var _out_threshold_option = argument4;

#macro CHATTERBOX_AUTO_FADE_IN_OPTIONS_AFTER_TEXT    1     //Values 0 -> 1 (inclusive) valid
#macro CHATTERBOX_AUTO_FADE_IN_OPTION_AFTER_OPTION   1     //Values 0 -> 1 (inclusive) valid
#macro CHATTERBOX_AUTO_FADE_OUT_OPTIONS_AFTER_TEXT   1     //Values 1 -> 2 (inclusive) valid
#macro CHATTERBOX_AUTO_FADE_OUT_OPTION_AFTER_OPTION  1     //Values 1 -> 2 (inclusive) valid
#macro CHATTERBOX_AUTO_DESTROY_FADED_OUT_TEXT        true
#macro CHATTERBOX_AUTO_DESTROY_FADED_OUT_OPTIONS     true
#macro CHATTERBOX_AUTO_FORCE_FADE_OUT_ON_SUSPEND     true
#macro CHATTERBOX_AUTO_FORCE_FADE_OUT_ON_SUSPEND     true

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