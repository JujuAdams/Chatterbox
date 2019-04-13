//  Chatterbox v0.0.0
//  2019/04/12
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

#macro CHATTERBOX_TAB_INDENT_SIZE   4
#macro CHATTERBOX_ROUND_UP_INDENTS  true

#macro CHATTERBOX_DEFAULT_STEP_SIZE  SCRIBBLE_DEFAULT_STEP_SIZE

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
// Use chatterbox_variables_export() and chatterbox_variables_import() to handle these variables
// 
// The $ prefix is what's specified in the Yarn documentation

#macro CHATTERBOX_ERROR_ON_MISSING_VARIABLE     true
#macro CHATTERBOX_ERROR_ON_INVALID_DATATYPE     true
#macro CHATTERBOX_ERROR_ON_MISMATCHED_DATATYPE  true

#macro CHATTERBOX_DOLLAR_VARIABLE_SCOPE     CHATTERBOX_SCOPE.INTERNAL   //If a variable starts if a $, what scope should it take?
#macro CHATTERBOX_NAKED_VARIABLE_SCOPE      CHATTERBOX_SCOPE.GML_LOCAL  //If a variable has no prefix, what scope should it take?
#macro CHATTERBOX_DEFAULT_VARIABLE_VALUE    0                           //Default value if a variable cannot be found

#macro CHATTERBOX_VISITED_SEPARATOR  ":"   //Single character only