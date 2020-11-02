/// Jumps to a specific node in a source file
///
/// @param chatterbox
/// @param nodeTitle
/// @param [filename]

function chatterbox_goto()
{
    var _chatterbox = argument[0];
    var _title      = argument[1];
    var _filename   = (argument_count > 2)? argument[2] : undefined;
    
    with(_chatterbox)
    {
        if (_filename != undefined)
        {
            var _file = global.chatterbox_files[? _filename];
            if (instanceof(_file) == "__chatterbox_class_source")
            {
                file = _file;
                filename = file.filename;
            }
            else
            {
                __chatterbox_trace("Error! File \"", _filename, "\" not found or not loaded");
            }
        }
        
        if (!verify_is_loaded())
        {
            __chatterbox_error("Could not go to node \"", _title, "\" because \"", filename, "\" is not loaded");
            return undefined;
        }
        else
        {
            var _node = find_node(_title);
            if (_node == undefined)
            {
                __chatterbox_error("Could not find node \"", _title, "\" in \"", filename, "\"");
                return undefined;
            }
            
            current_node = _node;
            current_instruction = current_node.root_instruction;
            current_node.mark_visited();
            
            __chatterbox_vm();
        }
    }
}