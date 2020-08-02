/// Jumps to a specific node in a source file
///
/// @param chatterbox
/// @param nodeTitle

function chatterbox_goto(_chatterbox, _title)
{
    with(_chatterbox)
    {
        var _node = find_node(_title);
        if (_node == undefined)
        {
            __chatterbox_error("Could not find node \"", _title, "\" in host (file=\"", filename, "\")");
            return undefined;
        }
        
        current_node = _node;
        current_instruction = current_node.root_instruction;
        current_node.mark_visited();
        
        __chatterbox_vm();
    }
}