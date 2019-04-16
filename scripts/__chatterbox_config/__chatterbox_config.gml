//  Chatterbox v0.0.4
//  2019/04/15
//  @jujuadams
//  With thanks to Els White
//  
//  https://github.com/thesecretlab/YarnSpinner/blob/master/Documentation/YarnSpinner-Dialogue/Yarn-Syntax.md
//  
//  For use with Scribble v4.5.1 - https://github.com/GameMakerDiscord/scribble

#macro CHATTERBOX_OPTION_DEFAULT_TEXT  "..."
#macro CHATTERBOX_TAB_INDENT_SIZE      4
#macro CHATTERBOX_ROUND_UP_INDENTS     true
#macro CHATTERBOX_DEFAULT_STEP_SIZE    SCRIBBLE_DEFAULT_STEP_SIZE  //The default step size. "(delta_time/16667)" assumes that the game is running at 60FPS and will delta time effects accordingly

#region Automatic helper behaviours

#macro CHATTERBOX_AUTO_KEYBOARD         true
#macro CHATTERBOX_AUTO_KEYBOARD_UP      (keyboard_check_released(vk_up)    || keyboard_check_released(vk_pageup))
#macro CHATTERBOX_AUTO_KEYBOARD_DOWN    (keyboard_check_released(vk_down)  || keyboard_check_released(vk_pagedown))
#macro CHATTERBOX_AUTO_KEYBOARD_SELECT  (keyboard_check_released(vk_space) || keyboard_check_released(vk_enter))

#macro CHATTERBOX_AUTO_MOUSE         true
#macro CHATTERBOX_AUTO_MOUSE_X       mouse_x
#macro CHATTERBOX_AUTO_MOUSE_Y       mouse_y
#macro CHATTERBOX_AUTO_MOUSE_SELECT  mouse_check_button_released(mb_left)

#macro CHATTERBOX_AUTO_HIGHLIGHT             true
#macro CHATTERBOX_AUTO_HIGHLIGHT_OFF_COLOUR  c_white
#macro CHATTERBOX_AUTO_HIGHLIGHT_OFF_ALPHA   0.5
#macro CHATTERBOX_AUTO_HIGHLIGHT_ON_COLOUR   c_yellow
#macro CHATTERBOX_AUTO_HIGHLIGHT_ON_ALPHA    1

#macro CHATTERBOX_AUTO_POSITION                    true
#macro CHATTERBOX_AUTO_POSITION_OPTION_INDENT      10
#macro CHATTERBOX_AUTO_POSITION_TEXT_SEPARATION    20
#macro CHATTERBOX_AUTO_POSITION_OPTION_SEPARATION  10

#endregion

#region Parameters for scribble_create() calls made by Chatterbox

//See scribble_create() for an explanation of these variables
//Use <undefined> to use default values
//Values are read when creating text or options, and *not* every frame
#macro CHATTERBOX_TEXT_CREATE_LINE_MIN_HEIGHT  undefined
#macro CHATTERBOX_TEXT_CREATE_MAX_WIDTH        400
#macro CHATTERBOX_TEXT_CREATE_DEFAULT_COLOUR   undefined
#macro CHATTERBOX_TEXT_CREATE_DEFAULT_FONT     undefined
#macro CHATTERBOX_TEXT_CREATE_DEFAULT_HALIGN   undefined
#macro CHATTERBOX_TEXT_CREATE_DATA_FIELDS      undefined

#macro CHATTERBOX_OPTION_CREATE_LINE_MIN_HEIGHT  undefined
#macro CHATTERBOX_OPTION_CREATE_MAX_WIDTH        400
#macro CHATTERBOX_OPTION_CREATE_DEFAULT_COLOUR   undefined
#macro CHATTERBOX_OPTION_CREATE_DEFAULT_FONT     undefined
#macro CHATTERBOX_OPTION_CREATE_DEFAULT_HALIGN   undefined
#macro CHATTERBOX_OPTION_CREATE_DATA_FIELDS      undefined

#endregion

#region Default parameters for scribble_draw() calls made by Chatterbox

//These values can be overwritten by chatterbox_set_property() whenever needed in realtime
//Values are read every frame and can be changed for dynamic effects
#macro CHATTERBOX_TEXT_DRAW_DEFAULT_XSCALE     1
#macro CHATTERBOX_TEXT_DRAW_DEFAULT_YSCALE     1
#macro CHATTERBOX_TEXT_DRAW_DEFAULT_ANGLE      0
#macro CHATTERBOX_TEXT_DRAW_DEFAULT_BLEND      c_white
#macro CHATTERBOX_TEXT_DRAW_DEFAULT_ALPHA      1
#macro CHATTERBOX_TEXT_DRAW_DEFAULT_PMA        false
#macro CHATTERBOX_TEXT_DRAW_DEFAULT_MAX_WIDTH  300

#macro CHATTERBOX_OPTION_DRAW_DEFAULT_XSCALE     1
#macro CHATTERBOX_OPTION_DRAW_DEFAULT_YSCALE     1
#macro CHATTERBOX_OPTION_DRAW_DEFAULT_ANGLE      0
#macro CHATTERBOX_OPTION_DRAW_DEFAULT_BLEND      c_white
#macro CHATTERBOX_OPTION_DRAW_DEFAULT_ALPHA      1
#macro CHATTERBOX_OPTION_DRAW_DEFAULT_PMA        false
#macro CHATTERBOX_OPTION_DRAW_DEFAULT_MAX_WIDTH  300

#endregion

#region Variables and scoping

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
#macro CHATTERBOX_SCOPE_INTERNAL    0
#macro CHATTERBOX_SCOPE_GML_LOCAL   1
#macro CHATTERBOX_SCOPE_GML_GLOBAL  2
//
// Internal Chatterbox variables are, in reality, key:value pairs in a ds_map
// Use chatterbox_variable_export() and chatterbox_variable_import() to handle these variables
// 
// The $ prefix is what's specified in the Yarn documentation

#macro CHATTERBOX_DOLLAR_VARIABLE_SCOPE        CHATTERBOX_SCOPE_INTERNAL    //If a variable starts if a $, what scope should it take?
#macro CHATTERBOX_NAKED_VARIABLE_SCOPE         CHATTERBOX_SCOPE_GML_LOCAL   //If a variable has no prefix, what scope should it take?
#macro CHATTERBOX_DEFAULT_VARIABLE_VALUE       0                            //Default value if a variable cannot be found
#macro CHATTERBOX_INTERNAL_VARIABLE_MAP_SCOPE  CHATTERBOX_SCOPE_GML_GLOBAL  //Are internal variables stored locally in each individual Chatterbox, or globally?

#endregion

#macro CHATTERBOX_STATE_SUSPENDED  -1
#macro CHATTERBOX_STATE_STOPPED     0
#macro CHATTERBOX_STATE_RUNNING     1

//Debug assistance
#macro CHATTERBOX_DEBUG                         true
#macro CHATTERBOX_DEBUG_PARSER                  true   //Spits out debug info for the file parser
#macro CHATTERBOX_DEBUG_VM                      true   //Spits out debug info for the virtual machine
#macro CHATTERBOX_ERROR_ON_MISSING_VARIABLE     false  //Throw an error if a variable (in any scope) is missing
#macro CHATTERBOX_ERROR_ON_INVALID_DATATYPE     true   //Throw an error when a variable returns a datatype that's unsupported (usually arrays)
#macro CHATTERBOX_ERROR_ON_MISMATCHED_DATATYPE  false  //Throw an error when two values of different datatypes are being compared

//These variables control which delimiters to use for [[options]] and <<actions>>
//For compatibility with Yarn editors you probably don't want to change these
#macro CHATTERBOX_OPTION_OPEN_DELIMITER   "["
#macro CHATTERBOX_OPTION_CLOSE_DELIMITER  "]"
#macro CHATTERBOX_ACTION_OPEN_DELIMITER   "<"
#macro CHATTERBOX_ACTION_CLOSE_DELIMITER  ">"
#macro CHATTERBOX_FILENAME_SEPARATOR      ":"

enum CHATTERBOX_PROPERTY
{
    X,            // 0
    Y,            // 1
    XY,           // 2  Changing this value also changes .X and .Y
    XSCALE,       // 3
    YSCALE,       // 4
    XY_SCALE,     // 5  Changing this value also changes .XSCALE and .YSCALE
    ANGLE,        // 6
    BLEND,        // 7
    ALPHA,        // 8
    PMA,          // 9  Premultiply alpha
    MAX_WIDTH,    //10  //Unusued!
                  
    __SECTION0,   //11  -- Read-Only Properties --
    WIDTH,        //12
    HEIGHT,       //13
    SCRIBBLE,     //14
    HIGHLIGHTED,  //15
                  
    __SIZE        //16
}