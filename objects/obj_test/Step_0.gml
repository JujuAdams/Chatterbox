//Check for any keyboard input
var _index = undefined;
if (keyboard_check_released(ord("1"))) _index = 0;
if (keyboard_check_released(ord("2"))) _index = 1;
if (keyboard_check_released(ord("3"))) _index = 2;

//If we've pressed a button, select that option
if (_index != undefined) box.select(_index);