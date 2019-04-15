//  Chatterbox v0.0.2
//  2019/04/14
//  @jujuadams
//  With thanks to Els White
//  
//  https://github.com/thesecretlab/YarnSpinner/blob/master/Documentation/YarnSpinner-Dialogue/Yarn-Syntax.md
//  
//  For use with Scribble v4.5.1 - https://github.com/GameMakerDiscord/scribble

#macro CHATTERBOX_DEFAULT_CONTINUE_TEXT  "CLICK TO CONTINUE"

#macro CHATTERBOX_DEFAULT_TEXT_XSCALE  1
#macro CHATTERBOX_DEFAULT_TEXT_YSCALE  1
#macro CHATTERBOX_DEFAULT_TEXT_ANGLE   0
#macro CHATTERBOX_DEFAULT_TEXT_COLOUR  c_white
#macro CHATTERBOX_DEFAULT_TEXT_ALPHA   1
#macro CHATTERBOX_DEFAULT_TEXT_PMA     false

#macro CHATTERBOX_DEFAULT_BUTTON_XSCALE  1
#macro CHATTERBOX_DEFAULT_BUTTON_YSCALE  1
#macro CHATTERBOX_DEFAULT_BUTTON_ANGLE   0
#macro CHATTERBOX_DEFAULT_BUTTON_COLOUR  c_white
#macro CHATTERBOX_DEFAULT_BUTTON_ALPHA   1
#macro CHATTERBOX_DEFAULT_BUTTON_PMA     false

#macro CHATTERBOX_AUTO_KEYBOARD         true
#macro CHATTERBOX_AUTO_KEYBOARD_UP      (keyboard_check_released(vk_up)    || (keyboard_check_released(vk_pageup))
#macro CHATTERBOX_AUTO_KEYBOARD_DOWN    (keyboard_check_released(vk_down)  || (keyboard_check_released(vk_pagedown))
#macro CHATTERBOX_AUTO_KEYBOARD_SELECT  (keyboard_check_released(vk_space) || (keyboard_check_released(vk_enter))
#macro CHATTERBOX_AUTO_MOUSE            true

#macro CHATTERBOX_DEBUG  true

#macro CHATTERBOX_TAB_INDENT_SIZE   4
#macro CHATTERBOX_ROUND_UP_INDENTS  true

#macro CHATTERBOX_DEFAULT_STEP_SIZE  SCRIBBLE_DEFAULT_STEP_SIZE  //The default step size. "(delta_time/16667)" assumes that the game is running at 60FPS and will delta time effects accordingly

//Supported variable prefixes for if-statements:
// 
// <<if $variable == 42>>          :  CHATTERBOX_DOLLAR_VARIABLE_SCOPE
// <<if variable == 42>>           :  CHATTERBOX_NAKED_VARIABLE_SCOPE
// <<if global.variable == 42>>    :  Global GML scope
// <<if g.variable == 42>>         :  Global GML scope
// <<if local.variable == 42>>     :  Local GML (instance) scope
// <<if l.variable == 42>>         :  Local GML (instance) scope
// <<if internal.variable == 42>>  :  Internal Chatterbox variable
// <<if i.variable == 42>>         :  Internal Chatterbox variable
// 
// Internal Chatterbox variables are, in reality, key:value pairs in a ds_map
// Use chatterbox_variable_export() and chatterbox_variable_import() to handle these variables
// 
// The $ prefix is what's specified in the Yarn documentation

#macro CHATTERBOX_ERROR_ON_MISSING_VARIABLE     false  //Throw an error if a variable (in any scope) is missing
#macro CHATTERBOX_ERROR_ON_INVALID_DATATYPE     true   //Throw an error when a variable returns a datatype that's unsupported (usually arrays)
#macro CHATTERBOX_ERROR_ON_MISMATCHED_DATATYPE  false  //Throw an error when two values of different datatypes are being compared

#macro CHATTERBOX_DOLLAR_VARIABLE_SCOPE     CHATTERBOX_SCOPE.INTERNAL   //If a variable starts if a $, what scope should it take?
#macro CHATTERBOX_NAKED_VARIABLE_SCOPE      CHATTERBOX_SCOPE.GML_LOCAL  //If a variable has no prefix, what scope should it take?
#macro CHATTERBOX_DEFAULT_VARIABLE_VALUE    0                           //Default value if a variable cannot be found

#macro CHATTERBOX_VISITED_NO_FILENAME  false //Set to <true> if you want all "visited()" flags to be stored without their filename

//These variables control which delimiters to use for [[options]] and <<actions>>
//For compatibility with Yarn editors you probably don't want to change these
#macro CHATTERBOX_OPTION_OPEN_DELIMITER   "["
#macro CHATTERBOX_OPTION_CLOSE_DELIMITER  "]"
#macro CHATTERBOX_ACTION_OPEN_DELIMITER   "<"
#macro CHATTERBOX_ACTION_CLOSE_DELIMITER  ">"

enum CHATTERBOX_PROPERTY
{
    X,                   // 0
    Y,                   // 1
    XY,                  // 2   //Changing this value also changes X and Y
    XSCALE,              // 3
    YSCALE,              // 4
    XY_SCALE,            // 5   //Changing this value also changes XSCALE and YSCALE
    ANGLE,               // 6
    COLOUR,              // 7
    ALPHA,               // 8
    PMA,                 // 9   //Premultiply alpha
    WIDTH,               //10
    HEIGHT,              //11   //Read-only
    SCRIBBLE,            //12   //Read-only
    HIGHLIGHTED,         //13   //Read-only
    
    CUSTOM_PROPERTY_1,   //14  You can add your own properties here!
    CUSTOM_PROPERTY_2,   //15  You can add your own properties here!
    
    __SIZE               //16
}

enum CHATTERBOX_SCOPE
{
    __INVALID,  //0
    INTERNAL,   //1
    GML_LOCAL,  //2
    GML_GLOBAL, //3
    __SIZE      //4
}