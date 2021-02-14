#region Internal Macro Definitions

#macro __CHATTERBOX_VERSION  "2.x.x"
#macro __CHATTERBOX_DATE     "2021-02-14"
    
#macro __CHATTERBOX_ON_MOBILE  ((os_type == os_ios) || (os_type == os_android))

#macro __CHATTERBOX_DEBUG_LOADER    false
#macro __CHATTERBOX_DEBUG_COMPILER  false
#macro __CHATTERBOX_DEBUG_VM        false

//These macros control which delimiters to use for <<actions>>
//You probably don't want to change these
#macro __CHATTERBOX_ACTION_OPEN_DELIMITER   "<"
#macro __CHATTERBOX_ACTION_CLOSE_DELIMITER  ">"
    
#endregion

#region Boot Initialisation

__ChatterboxTrace("Welcome to Chatterbox by @jujuadams! This is version " + __CHATTERBOX_VERSION + ", " + __CHATTERBOX_DATE);
    
if (__CHATTERBOX_ON_MOBILE && (CHATTERBOX_SOURCE_DIRECTORY != ""))
{
    __ChatterboxTrace("Included Files work a bit strangely on iOS and Android. Please use an empty string for the font directory and place Yarn .json files in the root of Included Files.");
    __ChatterboxError("GameMaker's Included Files work a bit strangely on iOS and Android.\nPlease use an empty string for the font directory and place Yarn .json files in the root of Included Files.\n ", true);
}
    
//Declare global variables
global.chatterbox_variables_map            = ds_map_create();
global.chatterbox_files                    = ds_map_create();
global.__chatterbox_default_file           = "";
global.__chatterbox_indent_size            = 0;
global.__chatterbox_findreplace_old_string = ds_list_create();
global.__chatterbox_findreplace_new_string = ds_list_create();
if (!variable_global_exists("__chatterbox_functions")) global.__chatterbox_functions = ds_map_create();

//Big ol' list of operators. Operators at the top at processed first
//Not included here are negative signs, negation (! / NOT), and parentheses - these are handled separately
global.__chatterbox_op_list = ds_list_create();
ds_list_add(global.__chatterbox_op_list, "+" );
ds_list_add(global.__chatterbox_op_list, "-" );
ds_list_add(global.__chatterbox_op_list, "*" );
ds_list_add(global.__chatterbox_op_list, "/" );
ds_list_add(global.__chatterbox_op_list, "%" );
ds_list_add(global.__chatterbox_op_list, "==");
ds_list_add(global.__chatterbox_op_list, "!=");
ds_list_add(global.__chatterbox_op_list, ">" );
ds_list_add(global.__chatterbox_op_list, "<" );
ds_list_add(global.__chatterbox_op_list, ">=");
ds_list_add(global.__chatterbox_op_list, "<=");
ds_list_add(global.__chatterbox_op_list, "||");
ds_list_add(global.__chatterbox_op_list, "&&");
ds_list_add(global.__chatterbox_op_list, "^^");
ds_list_add(global.__chatterbox_op_list, "^" );
ds_list_add(global.__chatterbox_op_list, "+=");
ds_list_add(global.__chatterbox_op_list, "-=");
ds_list_add(global.__chatterbox_op_list, "*=");
ds_list_add(global.__chatterbox_op_list, "/=");
ds_list_add(global.__chatterbox_op_list, "=" );

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
        if (_i < _size) _string += " , ";
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
    
    show_error("Chatterbox:\n" + _string + "\n ", false);
    
    return _string;
}

/// @param string
/// @param leading
function __ChatterboxRemoveWhitespace(_string, _leading)
{
    global.__chatterbox_indent_size = 0;
    
    var _result = _string;
    
    if ((_leading == true) || (_leading == all))
    {
        var _i = 1;
        repeat(string_length(_result))
        {
            var _ord = ord(string_char_at(_result, _i));
            if (_ord  > 32) break;
            if (_ord == 32) global.__chatterbox_indent_size++;
            if (_ord ==  9) global.__chatterbox_indent_size += CHATTERBOX_INDENT_TAB_SIZE;
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
            if (_ord == 32) global.__chatterbox_indent_size++;
            if (_ord ==  9) global.__chatterbox_indent_size += CHATTERBOX_INDENT_TAB_SIZE;
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
    _out_string = string_replace_all(_out_string, "\\\\", "\\");
    _out_string = string_replace_all(_out_string, "\\<", "<");
    _out_string = string_replace_all(_out_string, "\\>", ">");
    _out_string = string_replace_all(_out_string, "\\{", "{");
    _out_string = string_replace_all(_out_string, "\\}", "}");
    return _out_string;
}

#endregion