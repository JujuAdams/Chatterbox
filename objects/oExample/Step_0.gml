if (keyboard_check_released(ord("1"))) {suspend = false; chatterbox_select(chatterbox, 0);}
if (keyboard_check_released(ord("2"))) {suspend = false; chatterbox_select(chatterbox, 1);}
if (keyboard_check_released(ord("3"))) {suspend = false; chatterbox_select(chatterbox, 2);}

//If we press F5 then restart the demo
if (keyboard_check_released(vk_f5))
{
    chatterbox_variables_clear(chatterbox);
    chatterbox_goto(chatterbox, "Start");
}