/// Creates a Chatterbox host
/// 
/// Chatterbox uses a "host" to keep track of various bits of data.
/// Hosts are structs and, as a result, are automatically cleaned up by GameMaker without needing to be explicitly destroyed
/// 
/// @param [filename]

function chatterbox() constructor
{
	var _filename = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : global.__chatterbox_default_file;
    
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
    strings             = [];
    options             = [];
    current_node        = undefined;
    current_instruction = undefined;
    
    /// @param nodeTitle
    find_node = function(_title)
    {
        return file.find_node(_title);
    }
    
    /// @param nodeTitle
    function goto(_title)
    {
        var _node = find_node(_title);
        if (_node == undefined)
        {
            __chatterbox_error("Could not find node \"", _title, "\" in host (file=\"", filename, "\")");
            return undefined;
        }
        
        current_node = _node;
        current_instruction = undefined;
        execute();
        
        return _node;
    }
    
    /// @param optionIndex
    function select(_index)
    {
        if ((_index < 0) || (_index >= array_length(options)))
        {
            __chatterbox_trace("Out of bounds option index (got ", _index, ", maximum index for options is ", array_length(options)-1, ")");
            return undefined;
        }
    }
    
    execute = function()
    {
        
    }
}