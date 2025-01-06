if (ChatterboxIsStopped(box))
{
    //If we're stopped then don't respond to user input
}
else if (ChatterboxIsWaiting(box))
{
    //If we're in a "waiting" state then let the user press <space> to advance dialogue
    if (keyboard_check_released(vk_space))
    {
        ChatterboxContinue(box);
    }
    else if (keyboard_check_pressed(ord("F")))
    {
        //The user can also press F to fast forward through text until they hit a choice
        ChatterboxFastForward(box);
    }
}
else
{
    //If we're not waiting then we have some options!
    
    //Check for any keyboard input
    var _index = undefined;
    if (keyboard_check_released(ord("1"))) _index = 0;
    if (keyboard_check_released(ord("2"))) _index = 1;
    if (keyboard_check_released(ord("3"))) _index = 2;
    if (keyboard_check_released(ord("4"))) _index = 3;
    
    //If we've pressed a button, select that option
    if (_index != undefined) ChatterboxSelect(box, _index);
}

if (keyboard_check_pressed(ord("X")))
{
    ChatterboxLocalizationBuild("testcase_localization.chatter", "localization table.csv");
}