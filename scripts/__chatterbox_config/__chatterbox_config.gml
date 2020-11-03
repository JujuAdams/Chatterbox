#macro CHATTERBOX_VARIABLES_MAP      global.chatterbox_variables_map
#macro CHATTERBOX_SOURCE_DIRECTORY   "Yarn"
#macro CHATTERBOX_DEFAULT_SINGLETON  true
#macro CHATTERBOX_ALLOW_SCRIPTS      true

#region Variables and Scoping

#macro CHATTERBOX_DEFAULT_VARIABLE_VALUE  0  //Default value if a variable cannot be found

//Legal values are strings, one of the following:
//"yarn"
//"local"
//"global"
//"string"
//For more information, please read "Variables & Conditionals" in __chatterbox_syntax()
#macro CHATTERBOX_DOLLAR_VARIABLE_SCOPE  "yarn"  //If a variable starts if a $, what scope should it take?
#macro CHATTERBOX_NAKED_VARIABLE_SCOPE   "yarn"  //If a variable has no prefix, what scope should it take?

#endregion

#region Advanced

#macro CHATTERBOX_INDENT_TAB_SIZE     4    //Space size of a tab character
#macro CHATTERBOX_FILENAME_SEPARATOR  ":"  //The character used to separate filenames from node titles in redirects and options

//These variables control which delimiters to use for [[options]] and <<actions>>
//For compatibility with Yarn editors you probably don't want to change these
#macro CHATTERBOX_OPTION_OPEN_DELIMITER   "["
#macro CHATTERBOX_OPTION_CLOSE_DELIMITER  "]"
#macro CHATTERBOX_ACTION_OPEN_DELIMITER   "<"
#macro CHATTERBOX_ACTION_CLOSE_DELIMITER  ">"

#macro CHATTERBOX_ERROR_MISSING_VARIABLE_GET  false  //Throw an error if a variable (in any scope) is missing when getting a value
#macro CHATTERBOX_ERROR_INVALID_DATATYPE      true   //Throw an error when a variable returns a datatype that's unsupported (usually arrays)
#macro CHATTERBOX_ERROR_MISMATCHED_DATATYPE   false  //Throw an error when two values of different datatypes are being compared
#macro CHATTERBOX_ERROR_NONSTANDARD_SYNTAX    true   //Throws an error when using a reasonable, though technically illegal, syntax e.g. <<end if>> or <<elseif>>
#macro CHATTERBOX_ERROR_MISSING_FUNCTION      true   //Throw an error if a function name is unrecognised

#endregion