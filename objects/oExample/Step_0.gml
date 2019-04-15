//Keyboard control
if (keyboard_check_pressed(vk_up  )) chatterbox_set_highlighted(chatterbox, -1, true);
if (keyboard_check_pressed(vk_down)) chatterbox_set_highlighted(chatterbox,  1, true);
var _selected = keyboard_check_pressed(vk_space);

//Mouse control
var _highlighted = chatterbox_text_mouse_over(chatterbox, mouse_x, mouse_y);
chatterbox_set_highlighted(chatterbox, _highlighted);
if (_highlighted != undefined) _selected = mouse_check_button_released(mb_left);

chatterbox_step(chatterbox, _selected);

//Control position and colour of options
var _x_offset = chatterbox_text_get(chatterbox, false, 0, CHATTERBOX_PROPERTY.X)
              + 10;
              
var _y_offset = chatterbox_text_get(chatterbox, false, 0, CHATTERBOX_PROPERTY.Y)
              + chatterbox_text_get(chatterbox, false, 0, CHATTERBOX_PROPERTY.HEIGHT)
              + 10;

var _count = chatterbox_text_get_number(chatterbox, true);
for(var _i = 0; _i < _count; _i++)
{
    var _colour = chatterbox_text_get(chatterbox, true, _i, CHATTERBOX_PROPERTY.HIGHLIGHTED)? c_yellow : c_white;
    chatterbox_text_set(chatterbox, true, _i, CHATTERBOX_PROPERTY.COLOUR, _colour );
    chatterbox_text_set(chatterbox, true, _i, CHATTERBOX_PROPERTY.XY, _x_offset, _y_offset );
    
    _y_offset = chatterbox_text_get(chatterbox, true, _i, CHATTERBOX_PROPERTY.Y)
              + chatterbox_text_get(chatterbox, true, _i, CHATTERBOX_PROPERTY.HEIGHT);
}