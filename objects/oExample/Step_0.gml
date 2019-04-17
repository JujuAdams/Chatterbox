chatterbox_auto_keyboard_input(chatterbox,
                               keyboard_check_released(vk_up),
                               keyboard_check_released(vk_down));
var _mouse_over = chatterbox_auto_mouse_input(chatterbox, mouse_x, mouse_y, false);

var _select = false;
if (keyboard_check_released(vk_space) || keyboard_check_released(vk_enter)) _select = true;
if (_mouse_over && mouse_check_button_released(mb_left)) _select = true;

chatterbox_step(chatterbox, _select);

//If we press F5 then restart the demo
if (keyboard_check_released(vk_f5))
{
    chatterbox_variables_clear(chatterbox);
    chatterbox_goto(chatterbox, "Start");
}