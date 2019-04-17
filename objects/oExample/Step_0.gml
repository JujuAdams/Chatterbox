var _select = undefined;
if (keyboard_check_released(ord("1"))) _select = 0;
if (keyboard_check_released(ord("2"))) _select = 1;
if (keyboard_check_released(ord("3"))) _select = 2;

if (_select != undefined)
{
    suspend = false;
    chatterbox_select(chatterbox, _select);
}

//If we press F5 then restart the demo
if (keyboard_check_released(vk_f5))
{
    chatterbox_variables_clear();
    chatterbox_goto(chatterbox, "Start");
}