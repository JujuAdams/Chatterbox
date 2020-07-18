/// Jumps to a node and processes dialogue
/// 
/// The building block of dialogue in Yarn is the "node". See __chatterbox_syntax() for more information.
/// This script jumps to the specified node and processes the dialogue. Any text that's outputted can
/// be picked up by chatterbox_get_string() and chatterbox_get_string_count().
/// 
/// @param chatterboxHost
/// @param nodeTitle
/// @param [filename]
function chatterbox_goto() {

	var _chatterbox = argument[0];
	var _node_title = argument[1];

	if (!is_string(_node_title))
	{
	    __chatterbox_trace("Stopping");
	    _chatterbox[@ __CHATTERBOX_HOST.TITLE ] = undefined;
	    exit;
	}

	if (argument_count > 2) && (argument[2] != undefined)
	{
	    var _filename = argument[2];
    
	    if (!is_string(_filename))
	    {
	        __chatterbox_error("Yarn .json filenames must be strings (Got \"" + string(_filename) + "\")");
	        return undefined;
	    }
    
	    if (!ds_map_exists(global.__chatterbox_file_data, _filename))
	    {
	        __chatterbox_error("Cannot find Yarn .json \"" + _filename + "\"");
	        return undefined;
	    }
    
	    _chatterbox[@ __CHATTERBOX_HOST.FILENAME ] = _filename;
	}
	else
	{
	    _filename = _chatterbox[ __CHATTERBOX_HOST.FILENAME ];
	}

	var _key = _filename + CHATTERBOX_FILENAME_SEPARATOR + _node_title;
	var _instruction = global.__chatterbox_goto[? _key ];
	if (_instruction == undefined)
	{
	    __chatterbox_error("Couldn't find title \"" + string(_node_title) + "\" from Yarn .json file \"" + string(_filename) + "\"");
	    return false;
	}

	_chatterbox[@ __CHATTERBOX_HOST.TITLE    ] = _node_title;
	_chatterbox[@ __CHATTERBOX_HOST.FILENAME ] = _filename;

	__chatterbox_trace("Starting node \"" + _node_title + "\" from \"" + _filename + "\"");

	CHATTERBOX_VARIABLES_MAP[? "visited(" + _key + ")" ] = true;
	if (CHATTERBOX_DEBUG) __chatterbox_trace("  Set \"visited(" + _key + ")\" to <true>");

	//Create a fake option
	var _new_array = array_create(__CHATTERBOX_CHILD.__SIZE);
	_new_array[@ __CHATTERBOX_CHILD.STRING           ] = "";
	_new_array[@ __CHATTERBOX_CHILD.TYPE             ] = __CHATTERBOX_CHILD_TYPE.OPTION;
	_new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_START] = _instruction;
	_new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_END  ] = _instruction;

	var _child_array = []; //Wipe all children
	_chatterbox[@ __CHATTERBOX_HOST.CHILDREN] = _child_array;
	_child_array[@ array_length_1d(_child_array)] = _new_array;

	return chatterbox_select(_chatterbox, 0); //Now select the fake option!


}
