#macro CHATTERBOX_VARIABLES_MAP                 global.chatterboxVariablesMap
#macro CHATTERBOX_VARIABLES_LIST                global.chatterboxVariablesList
#macro CHATTERBOX_DEFAULT_SINGLETON             true
#macro CHATTERBOX_ALLOW_SCRIPTS                 true
#macro CHATTERBOX_FUNCTION_ARRAY_ARGUMENTS      true
#macro CHATTERBOX_SINGLETON_WAIT_BEFORE_OPTION  false
#macro CHATTERBOX_WAIT_BEFORE_STOP              true
#macro CHATTERBOX_SHOW_REJECTED_OPTIONS         true
#macro CHATTERBOX_DECLARE_ON_COMPILE            true //Whether to declare variables when Chatterbox script is compiled. Set to <false> for legacy (2.1 and earlier) behaviour

#macro CHATTERBOX_DIRECTION_MODE                  1 //0 = Pass direction to function (see below), 1 = treat directions as expressions, 2 = treat directions as Python-esque function calls
#macro CHATTERBOX_DIRECTION_FUNCTION              undefined //The function to receive <<direction>> contents. This will only be called if CHATTERBOX_DIRECTION_MODE is 0

#macro CHATTERBOX_ESCAPE_FILE_TAGS                true
#macro CHATTERBOX_ESCAPE_NODE_TAGS                true
#macro CHATTERBOX_ESCAPE_CONTENT                  true
#macro CHATTERBOX_ESCAPE_EXPRESSION_STRINGS       false

#macro CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY     ""

#region Advanced

#macro CHATTERBOX_INDENT_TAB_SIZE     4    //Space size of a tab character
#macro CHATTERBOX_FILENAME_SEPARATOR  ":"  //The character used to separate filenames from node titles in redirects and options

#macro CHATTERBOX_ERROR_NONSTANDARD_SYNTAX   true  //Throws an error when using a reasonable, though technically illegal, syntax e.g. <<end if>> or <<elseif>>
#macro CHATTERBOX_ERROR_UNDECLARED_VARIABLE  true  //Throws an error when trying to set an undeclared variable
#macro CHATTERBOX_ERROR_UNSET_VARIABLE       true  //Throws an error when trying to *get* a variable that doesn't exist
#macro CHATTERBOX_ERROR_REDECLARED_VARIABLE  true  //Throws an error when trying to redeclare a variable
#macro CHATTERBOX_ERROR_NO_LOCAL_SCOPE       true  //Throws an error when trying to execute a function without a local scope being available

// Value to return from a variable that doesn't exist
// This is only relevant if CHATTERBOX_ERROR_UNSET_VARIABLE is <false> and the "default" argument for ChatterboxVariableGet() has not been specified
#macro CHATTERBOX_VARIABLE_MISSING_VALUE  0

#endregion