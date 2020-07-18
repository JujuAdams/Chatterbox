/// Starts initialisation for Chatterbox
/// This script should be called before chatterbox_init_add() and chatterbox_init_end().
///
/// Initialisation is only fully complete once chatterbox_init_end() is called.
///
/// @param fileDirectory  Directory to look in (relative to game_save_id) for Yarn source files

#region Internal Macro Definitions

#macro __CHATTERBOX_VERSION  "0.3.0"
#macro __CHATTERBOX_DATE     "2020/07/18"

enum __CHATTERBOX_CHILD
{
    STRING,            //0
    TYPE,              //1
    INSTRUCTION_START, //2
    INSTRUCTION_END,   //3
    __SIZE             //4
}

#macro __CHATTERBOX_VARIABLE_INVALID  "__chatterbox_variable_error"
    
#macro __CHATTERBOX_VM_UNKNOWN         "UNKNOWN"
#macro __CHATTERBOX_VM_WAIT            "WAIT"
#macro __CHATTERBOX_VM_TEXT            "TEXT"
#macro __CHATTERBOX_VM_SHORTCUT        "SHORTCUT"
#macro __CHATTERBOX_VM_SHORTCUT_END    "SHORTCUTEND"
#macro __CHATTERBOX_VM_OPTION          "OPTION"
#macro __CHATTERBOX_VM_REDIRECT        "REDIRECT"
#macro __CHATTERBOX_VM_GENERIC_ACTION  "ACTION"
#macro __CHATTERBOX_VM_IF              "IF"
#macro __CHATTERBOX_VM_ELSE            "ELSE"
#macro __CHATTERBOX_VM_ELSEIF          "ELSEIF"
#macro __CHATTERBOX_VM_ENDIF           "ENDIF"
#macro __CHATTERBOX_VM_SET             "SET"
#macro __CHATTERBOX_VM_STOP            "STOP"
#macro __CHATTERBOX_VM_CUSTOM_ACTION   "CUSTOM"
    
#macro __CHATTERBOX_ON_MOBILE  ((os_type == os_ios) || (os_type == os_android))
    
#endregion

#region Boot Initialisation

__chatterbox_trace("Welcome to Chatterbox by @jujuadams! This is version " + __CHATTERBOX_VERSION + ", " + __CHATTERBOX_DATE);
    
if (__CHATTERBOX_ON_MOBILE && (CHATTERBOX_FONT_DIRECTORY != ""))
{
	__chatterbox_trace("Included Files work a bit strangely on iOS and Android. Please use an empty string for the font directory and place Yarn .json files in the root of Included Files.");
	__chatterbox_error("GameMaker's Included Files work a bit strangely on iOS and Android.\nPlease use an empty string for the font directory and place Yarn .json files in the root of Included Files.\n ", true);
}
    
//Declare global variables
global.chatterbox_variables_map            = ds_map_create();
global.chatterbox_files                    = {};
global.__chatterbox_default_file           = "";
global.__chatterbox_indent_size            = 0;
global.__chatterbox_scope                  = CHATTERBOX_SCOPE_INVALID;
global.__chatterbox_variable_name          = __CHATTERBOX_VARIABLE_INVALID;
global.__chatterbox_actions                = ds_map_create();
global.__chatterbox_permitted_functions    = ds_map_create();
global.__chatterbox_findreplace_old_string = ds_list_create();
global.__chatterbox_findreplace_new_string = ds_list_create();
    
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

#region Class Definitions

/// @param filename
/// @param name
/// @param format
function __chatterbox_class_file(_filename, _name, _format) constructor
{
    filename = _filename;
    name     = _name;
    format   = _format;
    nodes    = [];
    
    variable_struct_set(global.chatterbox_files, filename, self);
    __chatterbox_trace("Added \"", filename, "\" as a source file named \"", name, "\" (format=\"", format, "\")");
    
	//Fix the font directory name if it's weird
    var _font_directory = CHATTERBOX_FONT_DIRECTORY;
	var _char = string_char_at(_font_directory , string_length(_font_directory ));
	if (_char != "\\") && (_char != "/") _font_directory += "\\";
    
	var _buffer = buffer_load(_font_directory + filename);
	var _string = buffer_read(_buffer, buffer_string);
	buffer_delete(_buffer);
    
	switch(format)
	{
	    case "yarn": var _node_list = __chatterbox_parse_yarn(_string); break;
	    case "json": var _node_list = __chatterbox_parse_json(_string); break;
    }
	
	//If both of these fail, it's some wacky JSON that we don't recognise
	if (_node_list == undefined)
	{
	    __chatterbox_error("Format for \"" + _name + "\" is unrecognised.\nThis source file will be ignored.");
	    return undefined;
	}
    
	//Iterate over all the nodes we found in this source file
    var _node = 0;
    repeat(ds_list_size(_node_list))
	{
	    var _node_map = _node_list[| _node];
        __chatterbox_array_add(nodes, new __chatterbox_class_node(_node_map[? "title"], _node_map[? "body"]));
        _node++;
	}
    
	ds_list_destroy(_node_list);
    
    /// @param nodeTitle
    find_node = function(_title)
    {
        var _i = 0;
        repeat(array_length(nodes))
        {
            if (nodes[_i].title == _title) return nodes[_i];
            ++_i;
        }
        
        return undefined;
    }
}

/// @param title
/// @param bodyString
function __chatterbox_class_node(_title, _body_string) constructor
{
    title        = _title;
    body         = _body_string;
    instructions = [];
    
    body = __chatterbox_body_findreplace(body) + "\n";
    var _substring_list = __chatterbox_split_body(body);
    __chatterbox_compile(_substring_list);
	ds_list_destroy(_substring_list);
}

/// @param type
/// @param indent
/// @param [content]
/// @param [insertPosition]
function __chatterbox_class_instruction() constructor
{
	type      = argument[0];
	indent    = argument[1];
	content   = (argument_count > 2)? argument[2] : undefined;
	position  = (argument_count > 3)? argument[3] : undefined;
    block_end = undefined;
}

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

#endregion