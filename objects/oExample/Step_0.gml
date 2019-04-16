chatterbox_step(chatterbox);

//If we press F5 then restart the demo
if (keyboard_check_released(vk_f5))
{
    chatterbox_variables_clear(chatterbox);
    chatterbox_goto(chatterbox, "Start");
}