//  Chatterbox v0.0.7
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
#macro CHATTERBOX_SINGLETON_TEXT       true

#macro CHATTERBOX_TEXT    1
#macro CHATTERBOX_OPTION  2

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

//Debug assistance
#macro CHATTERBOX_DEBUG                         false
#macro CHATTERBOX_DEBUG_PARSER                  false  //Spits out debug info for the file parser
#macro CHATTERBOX_DEBUG_VM                      false  //Spits out debug info for the virtual machine
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