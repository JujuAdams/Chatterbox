/// Starts initialisation for Chatterbox
/// This script should be called before chatterbox_init_add() and chatterbox_init_end()
///
/// @param fontDirectory     Directory to look in (relative to game_save_id) for Yarn .json files
///
/// Initialisation is only fully complete once chatterbox_init_end() is called

#region Internal Macro Definitions

#macro __CHATTERBOX_VERSION       "0.0.1"
#macro __CHATTERBOX_DATE          "2019/04/13"
#macro __CHATTERBOX_DEBUG_PARSER  false
#macro __CHATTERBOX_DEBUG_VM      false

#macro __CHATTERBOX_ON_DIRECTX ((os_type == os_windows) || (os_type == os_xboxone) || (os_type == os_uwp) || (os_type == os_win8native) || (os_type == os_winphone))
#macro __CHATTERBOX_ON_OPENGL  !__CHATTERBOX_ON_DIRECTX
#macro __CHATTERBOX_ON_MOBILE  ((os_type == os_ios) || (os_type == os_android))

enum __CHATTERBOX_FILE
{
    FILENAME, // 0
    NAME,     // 1
    __SIZE    // 2
}

enum __CHATTERBOX_INSTRUCTION
{
    TYPE,    //0
    INDENT,  //1
    CONTENT, //2
    __SIZE   //3
}

enum __CHATTERBOX
{
    __SECTION0,   // 0
    LEFT,         // 1
    TOP,          // 2
    RIGHT,        // 3
    BOTTOM,       // 4
    FILENAME,     // 5
    TITLE,        // 6
    
    __SECTION1,   // 7
    INITIALISED,  // 8
    INSTRUCTION,  // 9
    VARIABLES,    //10
    EXECUTED_MAP, //11
    
    __SECTION2,   //11
    TEXTS,        //12
    BUTTONS,      //13
    
    __SIZE        //14
}

enum CHATTERBOX_SCOPE
{
    INTERNAL,   //0
    GML_LOCAL,  //1
    GML_GLOBAL, //2
    __SIZE      //3
}

//enum __CHATTERBOX_VM
//{
//    UNKNOWN,  // 0
//    TEXT,     // 1
//    SHORTCUT, // 2
//    OPTION,   // 3
//    REDIRECT, // 4
//    ACTION,   // 5
//    IF,       // 6
//    ELSE,     // 7
//    ELSEIF,   // 8
//    IF_END,   // 9
//    SET,      //10
//    STOP,     //11
//    __SIZE    //12
//}

#macro __CHATTERBOX_VM_UNKNOWN  "unknown"
#macro __CHATTERBOX_VM_TEXT     "text"
#macro __CHATTERBOX_VM_SHORTCUT "shortcut"
#macro __CHATTERBOX_VM_OPTION   "option"
#macro __CHATTERBOX_VM_REDIRECT "redirect"
#macro __CHATTERBOX_VM_ACTION   "action"
#macro __CHATTERBOX_VM_IF       "if begin"
#macro __CHATTERBOX_VM_ELSE     "else"
#macro __CHATTERBOX_VM_ELSEIF   "elseif"
#macro __CHATTERBOX_VM_IF_END   "end"
#macro __CHATTERBOX_VM_SET      "set"
#macro __CHATTERBOX_VM_STOP     "stop"

#endregion

if ( variable_global_exists("__chatterbox_init_complete") )
{
    show_error("Chatterbox:\nchatterbox_init_start() should not be called twice!\n ", false);
    exit;
}

show_debug_message("Chatterbox: Welcome to Chatterbox by @jujuadams! This is version " + __CHATTERBOX_VERSION + ", " + __CHATTERBOX_DATE);

var _font_directory = argument0;

if (__CHATTERBOX_ON_MOBILE)
{
    if (_font_directory != "")
    {
        show_debug_message("Chatterbox: Included Files work a bit strangely on iOS and Android. Please use an empty string for the font directory and place Yarn .json files in the root of Included Files.");
        show_error("Chatterbox:\nGameMaker's Included Files work a bit strangely on iOS and Android.\nPlease use an empty string for the font directory and place Yarn .json files in the root of Included Files.\n ", true);
        exit;
    }
}
else
{
    //Fix the font directory name if it's weird
    var _char = string_char_at(_font_directory, string_length(_font_directory));
    if (_char != "\\") && (_char != "/") _font_directory += "\\";
}

//Check if the directory exists
if ( !directory_exists(_font_directory) )
{
    show_debug_message("Chatterbox: WARNING! Font directory \"" + string(_font_directory) + "\" could not be found in \"" + game_save_id + "\"!");
}

//Declare global variables
global.__chatterbox_font_directory = _font_directory;
global.__chatterbox_file_data      = ds_map_create();
global.__chatterbox_data           = ds_map_create();
global.__chatterbox_init_complete  = false;
global.__chatterbox_default_file   = "";
global.__chatterbox_indent_size    = 0;