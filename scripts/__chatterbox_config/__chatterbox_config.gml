//  Chatterbox v0.1.4
//  2019/09/27
//  @jujuadams
//  With thanks to Els White and Jukio Kallio
//  
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax().

#macro CHATTERBOX_OPTION_FALLBACK_ENABLE   true  //
#macro CHATTERBOX_OPTION_FALLBACK_TEXT     "..."  //The option text to display if no option text has been found
#macro CHATTERBOX_DEBUG                    false  //Whether or not to show addition debug information whilst running Chatterbox
#macro CHATTERBOX_VARIABLES_MAP            global.chatterbox_variables_map

//chatterbox_get_string() and chatterbox_get_string_count() constants
#macro CHATTERBOX_BODY    1
#macro CHATTERBOX_OPTION  2

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

#macro CHATTERBOX_INDENT_UNIT_SIZE    4    //The fundamental ident unit, usually 4. This is typically the width of a tab character. This is a critical property for correct execution!
#macro CHATTERBOX_FILENAME_SEPARATOR  ":"  //The character used to separate filenames from node titles in redirects and options

//These variables control which delimiters to use for [[options]] and <<actions>>
//For compatibility with Yarn editors you probably don't want to change these
#macro CHATTERBOX_OPTION_OPEN_DELIMITER   "["
#macro CHATTERBOX_OPTION_CLOSE_DELIMITER  "]"
#macro CHATTERBOX_ACTION_OPEN_DELIMITER   "<"
#macro CHATTERBOX_ACTION_CLOSE_DELIMITER  ">"

#macro CHATTERBOX_DEBUG_PARSER                  false  //Debug the file parser. This can be useful in tracking down formatting issues with source files
#macro CHATTERBOX_DEBUG_SELECT                  false  //chatterbox_select() is the heart of Chatterbox and executes all dialogue logic
#macro CHATTERBOX_ERROR_ON_MISSING_VARIABLE     false  //Throw an error if a variable (in any scope) is missing
#macro CHATTERBOX_ERROR_ON_INVALID_DATATYPE     true   //Throw an error when a variable returns a datatype that's unsupported (usually arrays)
#macro CHATTERBOX_ERROR_ON_MISMATCHED_DATATYPE  false  //Throw an error when two values of different datatypes are being compared
#macro CHATTERBOX_ERROR_ON_BAD_INDENTS          true   //Whether to check for misaligned indentation. Idents must be an integer multiple of CHATTERBOX_INDENT_UNIT_SIZE

#endregion