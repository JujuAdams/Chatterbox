if (chatterbox_is_waiting(box))
{
    if (keyboard_check_released(vk_space)) chatterbox_continue(box);
}
else
{
    var _index = undefined;
    if (keyboard_check_released(ord("1"))) _index = 0;
    if (keyboard_check_released(ord("2"))) _index = 1;
    if (keyboard_check_released(ord("3"))) _index = 2;
    if (keyboard_check_released(ord("4"))) _index = 3;
    if (_index != undefined) chatterbox_select(box, _index);
}