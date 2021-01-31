#macro CHATTERBOX_VARIABLES_MAP                   global.chatterbox_variables_map
#macro CHATTERBOX_SOURCE_DIRECTORY                "Yarn"
#macro CHATTERBOX_DEFAULT_SINGLETON               true
#macro CHATTERBOX_ALLOW_SCRIPTS                   true
#macro CHATTERBOX_FUNCTION_ARRAY_ARGUMENTS        true
#macro CHATTERBOX_SINGLETON_WAIT_BEFORE_OPTION    false
#macro CHATTERBOX_SINGLETON_WAIT_BEFORE_SHORTCUT  false
#macro CHATTERBOX_WAIT_BEFORE_STOP                true
#macro CHATTERBOX_DIRECTION_FUNCTION              testcase_direction_function

#region Variables and Scoping

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

#macro CHATTERBOX_ERROR_NONSTANDARD_SYNTAX  true  //Throws an error when using a reasonable, though technically illegal, syntax e.g. <<end if>> or <<elseif>>

#endregion