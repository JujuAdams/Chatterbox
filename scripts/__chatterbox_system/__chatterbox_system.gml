/// Starts initialisation for Chatterbox
/// This script should be called before chatterbox_init_add() and chatterbox_init_end().
///
/// Initialisation is only fully complete once chatterbox_init_end() is called.
///
/// @param fileDirectory  Directory to look in (relative to game_save_id) for Yarn source files

#region Internal Macro Definitions

#macro __CHATTERBOX_VERSION  "0.3.0"
#macro __CHATTERBOX_DATE     "2020/07/18"

#macro __CHATTERBOX_VARIABLE_INVALID  "__chatterbox_variable_error"
    
#macro __CHATTERBOX_ON_MOBILE  ((os_type == os_ios) || (os_type == os_android))

#macro __CHATTERBOX_DEBUG_LOADER    false
#macro __CHATTERBOX_DEBUG_VM        true
#macro __CHATTERBOX_DEBUG_COMPILER  true
    
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

/// @param [filename]
function __chatterbox_class(_filename) constructor
{
	if (!is_string(_filename))
	{
	    __chatterbox_error("Source files must be strings (got \"" + string(_filename) + "\")");
	    return undefined;
	}
    
	if (!chatterbox_is_loaded(_filename))
	{
	    __chatterbox_error("\"" + _filename + "\" has not been loaded");
	    return undefined;
	}
    
    filename            = _filename;
    file                = variable_struct_get(global.chatterbox_files, filename);
    content             = [];
    option              = [];
    option_instruction  = [];
    current_node        = undefined;
    current_instruction = undefined;
    
    /// @param nodeTitle
    find_node = function(_title)
    {
        return file.find_node(_title);
    }
}

/// @param filename
function __chatterbox_class_file(_filename) constructor
{
    filename = _filename;
    name     = _filename;
    format   = undefined;
    nodes    = [];
    
	//Fix the font directory name if it's weird
    var _font_directory = CHATTERBOX_FONT_DIRECTORY;
	var _char = string_char_at(_font_directory , string_length(_font_directory ));
	if (_char != "\\") && (_char != "/") _font_directory += "\\";
    
    //Read this file in as a big string
	var _buffer = buffer_load(_font_directory + filename);
	var _string = buffer_read(_buffer, buffer_string);
	buffer_delete(_buffer);
    
    //Try to decode the string as a JSON
    var _json = json_decode(_string);
    if (_json >= 0)
    {
        var _node_list = __chatterbox_parse_json(_json);
        format = "json";
    }
    else
    {
        var _node_list = __chatterbox_parse_yarn(_string);
        format = "yarn";
    }
	
	//If both of these fail, it's some wacky JSON that we don't recognise
	if (_node_list == undefined)
	{
	    __chatterbox_error("File format for \"" + filename + "\" is unrecognised.\nThis source file will be ignored");
	    return undefined;
	}
    
    __chatterbox_trace("Processing \"", filename, "\" as a source file named \"", name, "\" (format=\"", format, "\")");
    
	//Iterate over all the nodes we found in this source file
    var _n = 0;
    repeat(ds_list_size(_node_list))
	{
	    var _node_map = _node_list[| _n];
        var _node = new __chatterbox_class_node(filename, _node_map[? "title"], _node_map[? "body"]);
        __chatterbox_array_add(nodes, _node);
        _n++;
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
    
    function toString()
    {
        return "File " + string(filename) + " " + string(nodes);
    }
}

/// @param filename
/// @param nodeTitle
/// @param bodyString
function __chatterbox_class_node(_filename, _title, _body_string) constructor
{
    if (__CHATTERBOX_DEBUG_COMPILER) __chatterbox_trace("[", _title, "]");
    
    filename         = _filename;
    title            = _title;
    root_instruction = new __chatterbox_class_instruction(undefined, 0, 0);
    
	//Prepare body string for parsing
    var _work_string = _body_string;
	_work_string = string_replace_all(_work_string, "\n\r", "\n");
	_work_string = string_replace_all(_work_string, "\r\n", "\n");
	_work_string = string_replace_all(_work_string, "\r"  , "\n");
    
	//Perform find-replace
    var _i = 0;
    repeat(ds_list_size(global.__chatterbox_findreplace_old_string))
    {
	    _work_string = string_replace_all(_work_string,
	                                      global.__chatterbox_findreplace_old_string[| _i],
	                                      global.__chatterbox_findreplace_new_string[| _i]);
        ++_i;
    }
    
    //Add a trailing newline to make sure we parse correctly
    _work_string += "\n";
    
    var _substring_list = __chatterbox_split_body(_body_string);
    __chatterbox_compile(_substring_list, root_instruction);
    
	ds_list_destroy(_substring_list);
    
    function mark_visited()
    {
        var _long_name = "visited(" + string(filename) + CHATTERBOX_FILENAME_SEPARATOR + string(title) + ")";
        
        var _value = CHATTERBOX_VARIABLES_MAP[? _long_name];
        if (_value == undefined)
        {
            CHATTERBOX_VARIABLES_MAP[? _long_name] = 1;
        }
        else
        {
            CHATTERBOX_VARIABLES_MAP[? _long_name]++;
        }
    }
    
    function toString()
    {
        return "Node " + string(filename) + CHATTERBOX_FILENAME_SEPARATOR + string(title);
    }
}

/// @param type
/// @param line
/// @param indent
function __chatterbox_class_instruction(_type, _line, _indent) constructor
{
	type   = _type;
    line   = _line;
    indent = _indent;
    
    function toString()
    {
        return "Instr " + string(type);
    }
}

/// @param parentInstruction
/// @param child
function __chatterbox_instruction_add(_parent, _child)
{
    if ((_child.indent > _parent.indent) && (_parent.type == "shortcut"))
    {
        _parent.shortcut_branch = _child;
        _child.shortcut_branch_parent = _parent;
    }
    else
    {
        if ((_parent.type == "shortcut")
        &&  (_child.indent <= _parent.indent)
        &&  !variable_struct_exists(_parent, "shortcut_branch"))
        {
            //Add a marker to the end of a branch. This helps the VM understand what's going on!
            var _branch_end = new __chatterbox_class_instruction("shortcut end", _parent.line, _parent.indent);
            _parent.shortcut_branch = _branch_end;
            _branch_end.shortcut_branch_parent = _parent;
            _branch_end.next = _child;
        }
        
        if (variable_struct_exists(_parent, "shortcut_branch_parent"))
        {
            if (_child.indent <= _parent.shortcut_branch_parent.indent)
            {
                __chatterbox_instruction_add(_parent.shortcut_branch_parent, _child);
                
                //Add a marker to the end of a branch. This helps the VM understand what's going on!
                var _branch_end = new __chatterbox_class_instruction("shortcut end", _parent.line, _parent.indent);
                __chatterbox_instruction_add(_parent, _branch_end);
                
                _branch_end.next = _child;
            }
            else
            {
                _parent.next = _child;
                _child.shortcut_branch_parent = _parent.shortcut_branch_parent;
            }
        }
        else
        {
            _parent.next = _child;
        }
    }
    
    return _child;
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