chatterbox_auto_keyboard_input(chatterbox,
                               keyboard_check_released(vk_up),
                               keyboard_check_released(vk_down),
                               keyboard_check_released(vk_space) || keyboard_check_released(vk_enter));

chatterbox_auto_mouse_input(chatterbox,
                            mouse_x, mouse_y,
                            mouse_check_button_released(mb_left),
                            false);

chatterbox_auto_highlight(chatterbox, c_white, 0.3, c_yellow, 1.0);
chatterbox_auto_position(chatterbox, 10, 10, 20, 10);

chatterbox_step(chatterbox);
chatterbox_auto_option_fade(chatterbox, 1, 1, 1, 1);

//If we press F5 then restart the demo
if (keyboard_check_released(vk_f5))
{
    chatterbox_variables_clear(chatterbox);
    chatterbox_goto(chatterbox, "Start");
}