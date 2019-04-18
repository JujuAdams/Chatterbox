//Check for any keyboard input
var _select = undefined;
if (keyboard_check_released(ord("1"))) _select = 0;
if (keyboard_check_released(ord("2"))) _select = 1;
if (keyboard_check_released(ord("3"))) _select = 2;

//If we've pressed a button, select that option
if (_select != undefined) chatterbox_select(chatterbox, _select);