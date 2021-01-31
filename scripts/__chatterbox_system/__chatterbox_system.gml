#region Internal Macro Definitions

#macro __CHATTERBOX_VERSION  "2.x.x"
#macro __CHATTERBOX_DATE     "2021/01/29"
    
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

__chatterbox_trace("Welcome to Chatterbox by @jujuadams! This is version " + __CHATTERBOX_VERSION + ", " + __CHATTERBOX_DATE);
    
if (__CHATTERBOX_ON_MOBILE && (CHATTERBOX_SOURCE_DIRECTORY != ""))
{
    __chatterbox_trace("Included Files work a bit strangely on iOS and Android. Please use an empty string for the font directory and place Yarn .json files in the root of Included Files.");
    __chatterbox_error("GameMaker's Included Files work a bit strangely on iOS and Android.\nPlease use an empty string for the font directory and place Yarn .json files in the root of Included Files.\n ", true);
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
function __chatterbox_generate_indent(_size)
{
    var _string = "";
    repeat(_size) _string += " ";
    return _string;
}

/// @param array
/// @param index
/// @param count
function __chatterbox_array_delete(_array, _index, _count)
{
    var _copy_size = array_length(_array) - (_index + _count);
    if ((_index < 0) || (_copy_size < 0)) throw "Index " + string(_index) + " is greater than maximum array index (" + string(array_length(_array)-1) + ")";
    
    var _new_array = array_create(_copy_size);
    array_copy(_new_array, 0, _array, _index + _count, _copy_size);
    array_copy(_array, _index, _new_array, 0, _copy_size);
    array_resize(_array, array_length(_array) - _count);
}

/// @param array
/// @param index
/// @param count
function __chatterbox_array_copy_part(_array, _index, _count)
{
    var _new_array = array_create(_count);
    array_copy(_new_array, 0, _array, _index, _count);
    return _new_array;
}

/// @param buffer
function __chatterbox_read_utf8_char(_buffer)
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

function __chatterbox_readable_value(_value)
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

#endregion