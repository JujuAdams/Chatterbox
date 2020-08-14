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