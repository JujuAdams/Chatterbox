#macro CHATTERBOX_VARIABLES_MAP      global.chatterbox_variables_map
#macro CHATTERBOX_FONT_DIRECTORY     "Yarn"
#macro CHATTERBOX_DEFAULT_SINGLETON  false
#macro CHATTERBOX_WAIT_OPTION_TEXT   "<<wait>>"

#region Variables and Scoping

#macro CHATTERBOX_DEFAULT_VARIABLE_VALUE  0  //Default value if a variable cannot be found

//More for information, please read "Variables & Conditionals" in __chatterbox_syntax()
#macro CHATTERBOX_SCOPE_INVALID    -1
#macro CHATTERBOX_SCOPE_INTERNAL    0
#macro CHATTERBOX_SCOPE_GML_LOCAL   1
#macro CHATTERBOX_SCOPE_GML_GLOBAL  2

#macro CHATTERBOX_DOLLAR_VARIABLE_SCOPE  CHATTERBOX_SCOPE_INTERNAL  //If a variable starts if a $, what scope should it take?
#macro CHATTERBOX_NAKED_VARIABLE_SCOPE   CHATTERBOX_SCOPE_INTERNAL  //If a variable has no prefix, what scope should it take?

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

#macro CHATTERBOX_ERROR_ON_MISSING_VARIABLE     false  //Throw an error if a variable (in any scope) is missing
#macro CHATTERBOX_ERROR_ON_INVALID_DATATYPE     true   //Throw an error when a variable returns a datatype that's unsupported (usually arrays)
#macro CHATTERBOX_ERROR_ON_MISMATCHED_DATATYPE  false  //Throw an error when two values of different datatypes are being compared
#macro CHATTERBOX_ERROR_ON_NONSTANDARD_SYNTAX   true   //Throws an error when using a reasonable, though technically illegal, syntax e.g. <<end if>> or <<elseif>>

#endregion