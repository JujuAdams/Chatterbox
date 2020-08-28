/// Jumps to a specific node in a source file
///
/// @param chatterbox
/// @param nodeTitle

function chatterbox_goto(_chatterbox, _title)
{
    with(_chatterbox)
    {
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