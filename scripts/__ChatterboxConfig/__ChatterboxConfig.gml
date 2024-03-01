// Feather disable all

// Whether chatterboxes should default to singleton mode. This is useful to most RPGs where lines
// of dialogue arrive one at a time. More modern narrative games tend to deliver larger chunks of
// text and, as such, singleton mode is less useful for those sorts of games.
#macro CHATTERBOX_DEFAULT_SINGLETON  true

// Root folder in Included Files to look in for Chatterbox files.
#macro CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY  ""

// Whether to allow scripts to be added as Chatterbox functions. This is potentially insecure but
// also very convenient.
#macro CHATTERBOX_ALLOW_SCRIPTS  true

// Whether Chatterbox functions should be executed using an array of parameters.
#macro CHATTERBOX_FUNCTION_ARRAY_ARGUMENTS  true

// Whether to enter into a "wait" state before options are presented when using singleton
// chatterboxes. This is helpful for games where you want to visually replace dialogue with a
// series of options for the player to choose from.
#macro CHATTERBOX_SINGLETON_WAIT_BEFORE_OPTION  false

// Whether a chatterbox should enter a "wait" state before marking the chatterbox as stopped. This
// makes implementing dialogue boxes that automatically destroy themselves a lot easier.
#macro CHATTERBOX_WAIT_BEFORE_STOP  true

// Whether to add rejected (failed) options to the list of chooseable options. The default setting
// is <true> which will show failed options in the list and therefore requires that you filter
// those options yourself. This is useful for games like Fallout 3 which show you options that you
// could have taken if you had e.g. higher charisma. Set this option to <false> if you deliberately
// want to hide every failed option (which is a lot simpler to implement!).
#macro CHATTERBOX_SHOW_REJECTED_OPTIONS  true

// Whether to show extra debug information. This is useful to narrow down problems that you might
// run into.
#macro CHATTERBOX_VERBOSE  false

// Replaces backslashes \ in Chatterbox aliases with front slashes /. This improves consistency
// when accessing Included Files in folder across different platforms.
#macro CHATTERBOX_REPLACE_ALIAS_BACKSLASHES  true

// Whether to allow use of keyword operators. Setting this macro to <true> will enable use of the
// following operators as keywords:
//    and = &&
//    le  = < 
//    lt  = < 
//    ge  = > 
//    gt  = > 
//    or  = ||
//    lte = <=
//    gte = >=
//    leq = <=
//    geq = >=
//    eq  = ==
//    is  = ==
//    neq = !=
//    to  = =
//    not = !
#macro CHATTERBOX_KEYWORD_OPERATORS  true

// Whether nodes without an explicit <<stop>> or <<hopback>> instruct at the end should default
// to <<hopback>>. Legacy behaviour (pre-2.7) is to set this to <false>
#macro CHATTERBOX_END_OF_NODE_HOPBACK  true

// Action mode controls how <<actions>> are processed by Chatterbox
// There are three possible values:
// 
// CHATTERBOX_ACTION_MODE = 0
// This is the officially recommended behaviour. The full contents of the action (everything
// between << and >>) are passed as a string to a function for parsing and execution by the
// developer (you). I think this behaviour is stupid but I've included it here because technically
// that is what the YarnScript specification says. You can set the function that receives the
// action string by setting CHATTERBOX_ACTION_FUNCTION. Exactly what syntax you use for
// actions is therefore completely up to you.
// 
// CHATTERBOX_ACTION_MODE = 1
// Chatterbox will treat actions as expressions to be executed in a similar manner to in-line
// expressions. This is covenient if you want to treat actions as little snippets of code
// that Chatterbox can run. Syntax for actions becomes the same as in-line expressions, which
// is broadly similar to "standard" GML syntax. Functions that you wish to execute must be added
// by calling ChatterboxAddFunction().
// 
// An example would be: <<giveItem("amulet", 1)>>
// 
// 
// CHATTERBOX_ACTION_MODE = 2
// Chatterbox will treat actions as expressions with a greatly simplified syntax. This is
// useful for writers and narrative designers who are less familiar with the particulars of
// coding and instead want to use a simple syntax to communicate with the underlying GameMaker
// application. The action is sliced into arguments using spaces as delimiters. The first
// token in the action is the name of the function call, as added by ChatterboxAddFunction().
// Subsequent tokens are passed to the function call with each token being a function parameter.
// All parameters are passed as strings. If a parameter needs to contain a space then you may
// enclose the string in " double quote marks.
// 
// An example, analogous to the example above, would be: <<giveItem amulet 1>>

#macro CHATTERBOX_ACTION_MODE      1           //See above
#macro CHATTERBOX_ACTION_FUNCTION  (undefined) //The function to receive <<action>> contents. This will only be called if CHATTERBOX_ACTION_MODE is 0

// Chatterbox offers three helper functions to assist with parsing content strings as dialogue:
//   ChatterboxGetContentSpeech()
//   ChatterboxGetContentSpeaker()
//   ChatterboxGetContentSpeakerData()
// 
// A content string must be formatted in a specific way for Chatterbox's helper functions to
// work correctly:
//   
//   Speaker Name: The words that the speaker is saying, called "speech" in Chatterbox.
// 
// Calling ChatterboxGetContentSpeaker() with the above string as the input will output "Speaker Name".
// Calling ChatterboxGetContentSpeech() will output everything after the colon, though without the
// leading whitespace between the colon and "The".
// 
// Chatterbox also offers "speaker data". This is an additional string that can be attached to
// a speaker for a content string. The formatting looks like this:
// 
//   Speaker Name[additional speaker data]: The words that the speaker is saying, called "speech" in Chatterbox.
// 
// Calling ChatterboxGetContentSpeakerData() will return "additional speaker data" in this case. For
// more complex situations you may want to perform additional parsing on the speaker data yourself.
// 
// The following macros control what substrings are used to split speaker and speech, and what
// substrings separate the speaker data from the speaker.

#macro CHATTERBOX_SPEAKER_DELIMITER   ":"  //Character that separates speaker (and speaker data) from speech. This can be any arbitrary string, potentially composed of multiple characters
#macro CHATTERBOX_SPEAKER_DATA_START  "["  //Character that indicates where the speaker data string starts. This can be any arbitrary string, potentially composed of multiple characters
#macro CHATTERBOX_SPEAKER_DATA_END    "]"  //Character that indicates where the speaker data string ends. This can be any arbitrary string, potentially composed of multiple characters

#macro CHATTERBOX_ESCAPE_FILE_TAGS           true
#macro CHATTERBOX_ESCAPE_NODE_TAGS           true
#macro CHATTERBOX_ESCAPE_CONTENT             true
#macro CHATTERBOX_ESCAPE_EXPRESSION_STRINGS  false

#macro CHATTERBOX_LOCALIZATION_ACKNOWLEDGE_WARNING  false



#region Advanced

// Whether to declare variables when Chatterbox script is compiled. Set to <false> for the highly
// inconvenient legacy (2.1 and earlier) behaviour.
#macro CHATTERBOX_DECLARE_ON_COMPILE  true

#macro CHATTERBOX_LEGACY_WEIRD_OPERATOR_PRECEDENCE  false  //Set to <true> if you're coming from pre-2.7.1

#macro CHATTERBOX_INDENT_TAB_SIZE     4    //Space size of a tab character
#macro CHATTERBOX_FILENAME_SEPARATOR  ":"  //The character used to separate filenames from node titles in redirects and options

#macro CHATTERBOX_LINE_HASH_SIZE           6
#macro CHATTERBOX_HIDE_LINE_HASH_METADATA  true

#macro CHATTERBOX_ERROR_NONSTANDARD_SYNTAX   true  //Throws an error when using a reasonable, though technically illegal, syntax e.g. <<end if>> or <<elseif>>
#macro CHATTERBOX_ERROR_UNDECLARED_VARIABLE  true  //Throws an error when trying to set an undeclared variable
#macro CHATTERBOX_ERROR_UNSET_VARIABLE       true  //Throws an error when trying to *get* a variable that doesn't exist
#macro CHATTERBOX_ERROR_REDECLARED_VARIABLE  true  //Throws an error when trying to redeclare a variable
#macro CHATTERBOX_ERROR_NO_LOCAL_SCOPE       true  //Throws an error when trying to execute a function without a local scope being available

// Value to return from a variable that doesn't exist
// This is only relevant if CHATTERBOX_ERROR_UNSET_VARIABLE is <false> and the "default" argument for ChatterboxVariableGet() has not been specified
#macro CHATTERBOX_VARIABLE_MISSING_VALUE  0

#endregion
