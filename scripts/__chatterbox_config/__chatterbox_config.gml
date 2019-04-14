//  Chatterbox v0.0.1
//  2019/04/13
//  @jujuadams
//  With thanks to Els White
//  
//  https://github.com/thesecretlab/YarnSpinner/blob/master/Documentation/YarnSpinner-Dialogue/Yarn-Syntax.md
//  
//  For use with Scribble v4.5.1 - https://github.com/GameMakerDiscord/scribble

#macro CHATTERBOX_DEFAULT_LEFT   10
#macro CHATTERBOX_DEFAULT_TOP    10
#macro CHATTERBOX_DEFAULT_RIGHT  950
#macro CHATTERBOX_DEFAULT_BOTTOM 530
#macro CHATTERBOX_CONTINUE_TEXT  "CLICK TO CONTINUE"

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

#macro CHATTERBOX_VISITED_SEPARATOR    ":"   //Single character only. If you're using complex internal variable names and are getting errors when using "visited()", change this character to be one that you never use
#macro CHATTERBOX_VISITED_NO_FILENAME  false //Set to <true> if you want all "visited()" flags to be stored without their filename

//These variables control which delimiters to use for [[options]] and <<actions>>
//For compatibility with Yarn editors you probably don't want to change these
#macro CHATTERBOX_OPTION_OPEN_DELIMITER   "["
#macro CHATTERBOX_OPTION_CLOSE_DELIMITER  "]"
#macro CHATTERBOX_ACTION_OPEN_DELIMITER   "<"
#macro CHATTERBOX_ACTION_CLOSE_DELIMITER  ">"