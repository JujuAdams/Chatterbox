/// Jumps to a specific node in a source file
///
/// @param chatterbox
/// @param nodeTitle
/// @param [filename]

function ChatterboxJump()
{
    var _chatterbox = argument[0];
    var _title      = argument[1];
    var _filename   = (argument_count > 2)? argument[2] : undefined;
    
    with(_chatterbox)
    {
        if (_filename != undefined)
        {
            var _file = global.chatterboxFiles[? _filename];
            if (instanceof(_file) == "__ChatterboxClassSource")
            {
                file = _file;
                filename = file.filename;
            }
            else
            {
                __ChatterboxTrace("Error! File \"", _filename, "\" not found or not loaded");
            }
        }
        
        if (!VerifyIsLoaded())
        {
            __ChatterboxError("Could not go to node \"", _title, "\" because \"", filename, "\" is not loaded");
            return undefined;
        }
        else
        {
            var _node = FindNode(_title);
            if (_node == undefined)
            {
                __ChatterboxError("Could not find node \"", _title, "\" in \"", filename, "\"");
                return undefined;
            }
            
            current_node = _node;
            current_instruction = current_node.root_instruction;
            current_node.MarkVisited();
            
            __ChatterboxVM();
        }
    }
}