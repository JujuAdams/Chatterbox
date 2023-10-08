// Feather disable all
#region Internal Macro Definitions

#macro __CHATTERBOX_VERSION  "2.11.0.1"
#macro __CHATTERBOX_DATE     "2023-10-08"

#macro CHATTERBOX_VARIABLES_MAP   global.__chatterboxVariablesMap
#macro CHATTERBOX_VARIABLES_LIST  global.__chatterboxVariablesList
#macro CHATTERBOX_CURRENT         global.__chatterboxCurrent

#macro __CHATTERBOX_DEBUG_INIT      false
#macro __CHATTERBOX_DEBUG_LOADER    false
#macro __CHATTERBOX_DEBUG_SPLITTER  false
#macro __CHATTERBOX_DEBUG_COMPILER  false
#macro __CHATTERBOX_DEBUG_VM        false

//These macros control which delimiters to use for <<actions>>
//You probably don't want to change these
#macro __CHATTERBOX_ACTION_OPEN_DELIMITER   "<"
#macro __CHATTERBOX_ACTION_CLOSE_DELIMITER  ">"

#macro __CHATTERBOX_LINE_HASH_PREFIX         "line:"
#macro __CHATTERBOX_LINE_HASH_PREFIX_LENGTH  5
#macro __CHATTERBOX_TEXT_HASH_LENGTH         6

#macro __CHATTERBOX_OPTION_CHOSEN_PREFIX  "optionChosen:"

#macro __CHATTERBOX_ON_MOBILE  ((os_type == os_ios) || (os_type == os_android) || (os_type == os_tvos))
#macro __CHATTERBOX_ON_WEB     (os_browser != browser_not_a_browser)
    
#endregion

#region Boot Initialisation

__ChatterboxTrace("Welcome to Chatterbox by @jujuadams! This is version " + __CHATTERBOX_VERSION + ", " + __CHATTERBOX_DATE);

var _chatterbox_directory = CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY;

if (__CHATTERBOX_ON_MOBILE)
{
    if (_chatterbox_directory != "")
    {
        __ChatterboxError("GameMaker's Included Files work a bit strangely on iOS and Android.\nPlease use an empty string for SCRIBBLE_INCLUDED_FILES_SUBDIRECTORY and place fonts in the root of Included Files");
        exit;
    }
}

if (_chatterbox_directory != "")
{
    //Fix the font directory name if it's weird
    var _char = string_char_at(_chatterbox_directory, string_length(_chatterbox_directory));
    if (_char != "\\") && (_char != "/") _chatterbox_directory += "\\";
}
    
if (!__CHATTERBOX_ON_WEB)
{
    //Check if the directory exists
    if ((_chatterbox_directory != "") && !directory_exists(_chatterbox_directory))
    {
        __ChatterboxTrace("Warning! Font directory \"" + string(_chatterbox_directory) + "\" could not be found in \"" + game_save_id + "\"!");
    }
}

//Verify CHATTERBOX_ACTION_FUNCTION has been set to a valid global function
try
{
    if (script_exists(CHATTERBOX_ACTION_FUNCTION) || is_method(CHATTERBOX_ACTION_FUNCTION))
    {
        if (__CHATTERBOX_DEBUG_INIT) __ChatterboxTrace("CHATTERBOX_ACTION_FUNCTION is valid");
    }
}
catch(_error)
{
    if (CHATTERBOX_ACTION_MODE == 0)
    {
        __ChatterboxError("CHATTERBOX_ACTION_FUNCTION is not a valid global function\n\n(This is only a requirement if CHATTERBOX_ACTION_MODE == 0)");
    }
    else
    {
        if (__CHATTERBOX_DEBUG_INIT) __ChatterboxTrace("CHATTERBOX_ACTION_FUNCTION is invalid, but CHATTERBOX_ACTION_MODE = ", CHATTERBOX_ACTION_MODE);
    }
}

//Declare global variables
global.__chatterboxDirectory            = _chatterbox_directory;

global.__chatterboxVariablesMap         = ds_map_create();
global.__chatterboxVariablesList        = ds_list_create();
global.__chatterboxConstantsMap         = ds_map_create();
global.__chatterboxConstantsList        = ds_list_create();
global.__chatterboxDefaultVariablesMap  = ds_map_create();
global.__chatterboxDeclaredVariablesMap = ds_map_create();

global.chatterboxFiles                  = ds_map_create();
global.__chatterboxDefaultFile          = "";
global.__chatterboxIndentSize           = 0;
global.__chatterboxFindReplaceOldString = ds_list_create();
global.__chatterboxFindReplaceNewString = ds_list_create();
global.__chatterboxVMInstanceStack      = [];
global.__chatterboxVMWait               = false;
global.__chatterboxVMForceWait          = false;
global.__chatterboxVMFastForward        = false;
global.__chatterboxCurrent              = undefined;
global.__chatterboxLocalisationMap      = ds_map_create();
if (!variable_global_exists("__chatterbox_functions")) global.__chatterboxFunctions = ds_map_create();

//Big ol' list of operators. Operators at the top at processed first
//Not included here are negative signs, negation (! / NOT), and parentheses - these are handled separately
global.__chatterboxOpList = ds_list_create();
if (CHATTERBOX_LEGACY_WEIRD_OPERATOR_PRECEDENCE)
{
    ds_list_add(global.__chatterboxOpList, "+" );
    ds_list_add(global.__chatterboxOpList, "-" );
    ds_list_add(global.__chatterboxOpList, "*" );
    ds_list_add(global.__chatterboxOpList, "/" );
    ds_list_add(global.__chatterboxOpList, "==");
    ds_list_add(global.__chatterboxOpList, "!=");
    ds_list_add(global.__chatterboxOpList, ">" );
    ds_list_add(global.__chatterboxOpList, "<" );
    ds_list_add(global.__chatterboxOpList, ">=");
    ds_list_add(global.__chatterboxOpList, "<=");
    ds_list_add(global.__chatterboxOpList, "||");
    ds_list_add(global.__chatterboxOpList, "&&");
    ds_list_add(global.__chatterboxOpList, "+=");
    ds_list_add(global.__chatterboxOpList, "-=");
    ds_list_add(global.__chatterboxOpList, "*=");
    ds_list_add(global.__chatterboxOpList, "/=");
    ds_list_add(global.__chatterboxOpList, "=" );
}
else
{
    ds_list_add(global.__chatterboxOpList, "*" );
    ds_list_add(global.__chatterboxOpList, "/" );
    ds_list_add(global.__chatterboxOpList, "-" );
    ds_list_add(global.__chatterboxOpList, "+" );
    ds_list_add(global.__chatterboxOpList, ">" );
    ds_list_add(global.__chatterboxOpList, "<" );
    ds_list_add(global.__chatterboxOpList, ">=");
    ds_list_add(global.__chatterboxOpList, "<=");
    ds_list_add(global.__chatterboxOpList, "==");
    ds_list_add(global.__chatterboxOpList, "!=");
    ds_list_add(global.__chatterboxOpList, "&&");
    ds_list_add(global.__chatterboxOpList, "||");
    ds_list_add(global.__chatterboxOpList, "+=");
    ds_list_add(global.__chatterboxOpList, "-=");
    ds_list_add(global.__chatterboxOpList, "*=");
    ds_list_add(global.__chatterboxOpList, "/=");
    ds_list_add(global.__chatterboxOpList, "=" );
}

#endregion

#region Utility

/// @param [value...]
function __ChatterboxTrace()
{
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += __ChatterboxString(argument[_i]);
        ++_i;
    }

    show_debug_message(string_format(current_time, 8, 0) + " Chatterbox: " + _string);

    return _string;
}

/// @param value
function __ChatterboxString(_value)
{
    if (is_array(_value)) return __ChatterboxArrayToString(_value);
    return string(_value);
}

/// @param array
function __ChatterboxArrayToString(_array)
{
    var _string = "[";

    var _i = 0;
    var _size = array_length(_array);
    repeat(_size)
    {
        _string += __ChatterboxString(_array[_i]);
        ++_i;
        if (_i < _size) _string += ",";
    }
    
    _string += "]";
    
    return _string;
}

/// @param [value...]
function __ChatterboxError()
{
    var _string = "";
    
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    if (os_browser != browser_not_a_browser)
    {
        _string += "\n \n" + string(debug_get_callstack());
        throw ("Chatterbox " + __CHATTERBOX_VERSION + ":\n" + _string);
    }
    else
    {
        show_error("Chatterbox " + __CHATTERBOX_VERSION + ":\n" + _string + "\n ", false);
    }
    
    return _string;
}

/// @param string
/// @param leading
function __ChatterboxCompilerRemoveWhitespace(_string, _leading)
{
    global.__chatterboxIndentSize = 0;
    
    var _result = _string;
    
    if ((_leading == true) || (_leading == all))
    {
        var _i = 1;
        repeat(string_length(_result))
        {
            var _ord = ord(string_char_at(_result, _i));
            if (_ord  > 32) break;
            if (_ord == 32) global.__chatterboxIndentSize++;
            if (_ord ==  9) global.__chatterboxIndentSize += CHATTERBOX_INDENT_TAB_SIZE;
            _i++;
        }
        
        _result = string_delete(_result, 1, _i-1);
    }
    
    if ((_leading == false) || (_leading == all))
    {
        var _i = string_length(_result);
        repeat(string_length(_result))
        {
            var _ord = ord(string_char_at(_result, _i));
            if (_ord  > 32) break;
            if (_ord == 32) global.__chatterboxIndentSize++;
            if (_ord ==  9) global.__chatterboxIndentSize += CHATTERBOX_INDENT_TAB_SIZE;
            _i--;
        }
        
        _result = string_copy(_result, 1, _i);
    }
    
    return _result;
}

/// @param size
function __ChatterboxGenerateIndent(_size)
{
    var _string = "";
    repeat(_size) _string += " ";
    return _string;
}

/// @param array
/// @param index
/// @param count
function __ChatterboxArrayCopyPart(_array, _index, _count)
{
    var _new_array = array_create(_count);
    array_copy(_new_array, 0, _array, _index, _count);
    return _new_array;
}

/// @param buffer
function __ChatterboxReadUTF8Char(_buffer)
{
    var _value = buffer_read(_buffer, buffer_u8);
    if ((_value & $E0) == $C0) //two-byte
    {
        _value  = (                         _value & $1F) <<  6;
        _value += (buffer_read(_buffer, buffer_u8) & $3F);
    }
    else if ((_value & $F0) == $E0) //three-byte
    {
        _value  = (                         _value & $0F) << 12;
        _value += (buffer_read(_buffer, buffer_u8) & $3F) <<  6;
        _value +=  buffer_read(_buffer, buffer_u8) & $3F;
    }
    else if ((_value & $F8) == $F0) //four-byte
    {
        _value  = (                         _value & $07) << 18;
        _value += (buffer_read(_buffer, buffer_u8) & $3F) << 12;
        _value += (buffer_read(_buffer, buffer_u8) & $3F) <<  6;
        _value +=  buffer_read(_buffer, buffer_u8) & $3F;
    }
    
    return _value;
}

function __ChatterboxReadableValue(_value)
{
    if (is_string(_value))
    {
        return "\"" + _value + "\"";
    }
    else if (is_undefined(_value))
    {
        return "<undefined>";
    }
    else if (is_bool(_value))
    {
        return _value? "<true>" : "<false>";
    }
    else
    {
        return string(_value);
    }
}

function __ChatterboxVerifyDatatypes(_a, _b)
{
    if ((_a == undefined) || (_b == undefined)) return true;
    if (is_numeric(_a) && is_numeric(_b)) return true;
    if (is_string( _a) && is_string( _b)) return true;
    if (is_bool(   _a) && is_bool(   _b)) return true;
    return false;
}

function __ChatterboxUnescapeString(_in_string)
{
    var _out_string = _in_string;
    _out_string = string_replace_all(_out_string, "\\'", "'");
    _out_string = string_replace_all(_out_string, "\\\"", "\"");
    _out_string = string_replace_all(_out_string, "\\n", "\n");
    _out_string = string_replace_all(_out_string, "\\r", "\r");
    _out_string = string_replace_all(_out_string, "\\t", "\t");
    _out_string = string_replace_all(_out_string, "\\<", "<");
    _out_string = string_replace_all(_out_string, "\\>", ">");
    _out_string = string_replace_all(_out_string, "\\{", "{");
    _out_string = string_replace_all(_out_string, "\\}", "}");
    _out_string = string_replace_all(_out_string, "\\#", "#");
    _out_string = string_replace_all(_out_string, "\\\\", "\\");
    return _out_string;
}

function __ChatterboxStringLimit(_string, _max_length)
{
    _max_length = max(4, _max_length);
    
    _string = string_replace_all(_string, "\n", "\\n");
    _string = string_replace_all(_string, "\r", "");
    
    if (string_length(_string) <= 20) return _string;
    
    return string_copy(_string, 1, _max_length-3) + "...";
}

function __ChatterboxStripOuterWhitespace(_string)
{
    return __ChatterboxStripLeadingWhitespace(__ChatterboxStripTrailingWhitespace(_string));
}

function __ChatterboxStripLeadingWhitespace(_string)
{
    var _i = 0;
    repeat(string_length(_string))
    {
        if (ord(string_char_at(_string, _i+1)) > 32) break;
        ++_i;
    }
    
    return string_delete(_string, 1, _i);
}

function __ChatterboxStripTrailingWhitespace(_string)
{
    var _i = string_length(_string);
    repeat(_i)
    {
        if (ord(string_char_at(_string, _i)) > 32) break;
        --_i;
    }
    
    return string_copy(_string, 1, _i);
}

#endregion
