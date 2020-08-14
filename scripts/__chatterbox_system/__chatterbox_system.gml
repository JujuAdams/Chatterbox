#region Internal Macro Definitions

#macro __CHATTERBOX_VERSION  "0.4.1"
#macro __CHATTERBOX_DATE     "2020/08/14"

#macro __CHATTERBOX_VARIABLE_INVALID  "__chatterbox_variable_error"
    
#macro __CHATTERBOX_ON_MOBILE  ((os_type == os_ios) || (os_type == os_android))

#macro __CHATTERBOX_DEBUG_LOADER    false
#macro __CHATTERBOX_DEBUG_COMPILER  false
#macro __CHATTERBOX_DEBUG_VM        false
    
#endregion

#region Boot Initialisation

__chatterbox_trace("Welcome to Chatterbox by @jujuadams! This is version " + __CHATTERBOX_VERSION + ", " + __CHATTERBOX_DATE);
    
if (__CHATTERBOX_ON_MOBILE && (CHATTERBOX_SOURCE_DIRECTORY != ""))
{
    __chatterbox_trace("Included Files work a bit strangely on iOS and Android. Please use an empty string for the font directory and place Yarn .json files in the root of Included Files.");
    __chatterbox_error("GameMaker's Included Files work a bit strangely on iOS and Android.\nPlease use an empty string for the font directory and place Yarn .json files in the root of Included Files.\n ", true);
}
    
//Declare global variables
global.chatterbox_variables_map            = ds_map_create();
global.chatterbox_files                    = {};
global.__chatterbox_default_file           = "";
global.__chatterbox_indent_size            = 0;
global.__chatterbox_scope                  = undefined;
global.__chatterbox_variable_name          = __CHATTERBOX_VARIABLE_INVALID;
global.__chatterbox_findreplace_old_string = ds_list_create();
global.__chatterbox_findreplace_new_string = ds_list_create();
if (!variable_global_exists("__chatterbox_functions")) global.__chatterbox_functions = ds_map_create();

//Big ol' list of operator dipthongs
global.__chatterbox_op_list       = ds_list_create();
global.__chatterbox_op_list[|  0] = "("; 
global.__chatterbox_op_list[|  1] = "!"; 
global.__chatterbox_op_list[|  2] = "/=";
global.__chatterbox_op_list[|  3] = "/"; 
global.__chatterbox_op_list[|  4] = "*=";
global.__chatterbox_op_list[|  5] = "*"; 
global.__chatterbox_op_list[|  6] = "+"; 
global.__chatterbox_op_list[|  7] = "+=";
global.__chatterbox_op_list[|  8] = "-"; 
global.__chatterbox_op_list[|  9] = "-";  global.__chatterbox_negative_op_index = 9;
global.__chatterbox_op_list[| 10] = "-=";
global.__chatterbox_op_list[| 11] = "||";
global.__chatterbox_op_list[| 12] = "&&";
global.__chatterbox_op_list[| 13] = ">=";
global.__chatterbox_op_list[| 14] = "<=";
global.__chatterbox_op_list[| 15] = ">"; 
global.__chatterbox_op_list[| 16] = "<"; 
global.__chatterbox_op_list[| 17] = "!=";
global.__chatterbox_op_list[| 18] = "==";
global.__chatterbox_op_list[| 19] = "=";
global.__chatterbox_op_count = ds_list_size(global.__chatterbox_op_list);

#endregion

#region Utility

/// @param array
/// @param value
function __chatterbox_array_add(_array, _value)
{
    _array[@ array_length(_array)] = _value;
}

/// @param [value...]
function __chatterbox_trace()
{
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += __chatterbox_string(argument[_i]);
        ++_i;
    }

    show_debug_message(string_format(current_time, 8, 0) + " Chatterbox: " + _string);

    return _string;
}

/// @param value
function __chatterbox_string(_value)
{
    if (is_array(_value)) return __chatterbox_array_to_string(_value);
    return string(_value);
}

/// @param array
function __chatterbox_array_to_string(_array)
{
    var _string = "[";

    var _i = 0;
    var _size = array_length(_array);
    repeat(_size)
    {
        _string += __chatterbox_string(_array[_i]);
        ++_i;
        if (_i < _size) _string += " , ";
    }
    
    _string += "]";
    
    return _string;
}

/// @param [value...]
function __chatterbox_error()
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
function __chatterbox_remove_whitespace(_string, _leading)
{
    global.__chatterbox_indent_size = 0;
    
    if (_leading)
    {
        var _i = 1;
        repeat(string_length(_string))
        {
            var _ord = ord(string_char_at(_string, _i));
            if (_ord  > 32) break;
            if (_ord == 32) global.__chatterbox_indent_size++;
            if (_ord ==  9) global.__chatterbox_indent_size += CHATTERBOX_INDENT_TAB_SIZE;
            _i++;
        }
        
        return string_delete(_string, 1, _i-1);
    }
    else
    {
        var _i = string_length(_string);
        repeat(string_length(_string))
        {
            var _ord = ord(string_char_at(_string, _i));
            if (_ord  > 32) break;
            if (_ord == 32) global.__chatterbox_indent_size++;
            if (_ord ==  9) global.__chatterbox_indent_size += CHATTERBOX_INDENT_TAB_SIZE;
            _i--;
        }
        
        return string_copy(_string, 1, _i);
    }
}

/// @param size
function __chatterbox_generate_indent(_size)
{
    var _string = "";
    repeat(_size) _string += " ";
    return _string;
}

#endregion