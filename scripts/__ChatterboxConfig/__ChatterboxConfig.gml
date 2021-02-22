#macro CHATTERBOX_VARIABLES_MAP                 global.chatterboxVariablesMap
#macro CHATTERBOX_DEFAULT_SINGLETON             true
#macro CHATTERBOX_ALLOW_SCRIPTS                 true
#macro CHATTERBOX_FUNCTION_ARRAY_ARGUMENTS      true
#macro CHATTERBOX_SINGLETON_WAIT_BEFORE_OPTION  false
#macro CHATTERBOX_WAIT_BEFORE_STOP              true
#macro CHATTERBOX_SHOW_REJECTED_OPTIONS         true

#macro CHATTERBOX_DIRECTION_MODE                  0 //0 = Pass direction to function (see below), 1 = treat directions as expressions, 2 = treat directions as Python-esque function calls
#macro CHATTERBOX_DIRECTION_FUNCTION              TestCaseDirectionFunction

#macro CHATTERBOX_ESCAPE_FILE_TAGS                true
#macro CHATTERBOX_ESCAPE_NODE_TAGS                true
#macro CHATTERBOX_ESCAPE_CONTENT                  true
#macro CHATTERBOX_ESCAPE_EXPRESSION_STRINGS       false

#macro CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY     ""

#region Advanced

#macro CHATTERBOX_INDENT_TAB_SIZE     4    //Space size of a tab character
#macro CHATTERBOX_FILENAME_SEPARATOR  ":"  //The character used to separate filenames from node titles in redirects and options

#macro CHATTERBOX_ERROR_NONSTANDARD_SYNTAX  true  //Throws an error when using a reasonable, though technically illegal, syntax e.g. <<end if>> or <<elseif>>

#endregion