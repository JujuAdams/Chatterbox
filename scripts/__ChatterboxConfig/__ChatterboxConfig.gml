#macro CHATTERBOX_VARIABLES_MAP                 global.chatterboxVariablesMap
#macro CHATTERBOX_VARIABLES_LIST                global.chatterboxVariablesList
#macro CHATTERBOX_DEFAULT_SINGLETON             true
#macro CHATTERBOX_ALLOW_SCRIPTS                 true
#macro CHATTERBOX_FUNCTION_ARRAY_ARGUMENTS      true
#macro CHATTERBOX_SINGLETON_WAIT_BEFORE_OPTION  false
#macro CHATTERBOX_WAIT_BEFORE_STOP              true
#macro CHATTERBOX_SHOW_REJECTED_OPTIONS         true
#macro CHATTERBOX_DECLARE_ON_COMPILE            true //Whether to declare variables when Chatterbox script is compiled. Set to <false> for legacy (2.1 and earlier) behaviour

// Direction mode controls how <<directions>> are processed by Chatterbox
// There are three possible values:
// 
// CHATTERBOX_DIRECTION_MODE = 0
// This is the officially recommended behaviour. The full contents of the direction (everything
// between << and >>) are passed as a string to a function for parsing and execution by the
// developer (you). I think this behaviour is stupid but I've included it here because technically
// that is what the YarnScript specification says. You can set the function that receives the
// direction string by setting CHATTERBOX_DIRECTION_FUNCTION. Exactly what syntax you use for
// directions is therefore completely up to you.
// 
// CHATTERBOX_DIRECTION_MODE = 1
// Chatterbox will treat directions as expressions to be executed in a similar manner to in-line
// expressions. This is covenient if you want to treat directions as little snippets of code
// that Chatterbox can run. Syntax for directions becomes the same as in-line expressions, which
// is broadly similar to "standard" GML syntax. Functions that you wish to execute must be added
// by calling ChatterboxAddFunction().
// 
// An example would be: <<giveItem("amulet", 1)>>
// 
// 
// CHATTERBOX_DIRECTION_MODE = 2
// Chatterbox will treat directions as expressions with a greatly simplified syntax. This is
// useful for writers and narrative designers who are less familiar with the particulars of
// coding and instead want to use a simple syntax to communicate with the underlying GameMaker
// application. The direction is sliced into arguments using spaces as delimiters. The first
// token in the direction is the name of the function call, as added by ChatterboxAddFunction().
// Subsequent tokens are passed to the function call with each token being a function parameter.
// All parameters are passed as strings. If a parameter needs to contain a space then you may
// enclose the string in " double quote marks.
// 
// An example, analogous to the example above, would be: <<giveItem amulet 1>>

#macro CHATTERBOX_DIRECTION_MODE      1         //See above
#macro CHATTERBOX_DIRECTION_FUNCTION  undefined //The function to receive <<direction>> contents. This will only be called if CHATTERBOX_DIRECTION_MODE is 0

#macro CHATTERBOX_ESCAPE_FILE_TAGS                true
#macro CHATTERBOX_ESCAPE_NODE_TAGS                true
#macro CHATTERBOX_ESCAPE_CONTENT                  true
#macro CHATTERBOX_ESCAPE_EXPRESSION_STRINGS       false

#macro CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY     ""

#macro CHATTERBOX_SPEAKERDATA_TAG_OPEN            "["     //↓
#macro CHATTERBOX_SPEAKERDATA_TAG_CLOSE            "]"    //The characters that hold speaker data between them. It can be, for example, an image index

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