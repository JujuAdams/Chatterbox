// Feather disable all
/// @param type
/// @param line
/// @param indent
function __ChatterboxClassInstruction(_type, _line, _indent) constructor
{
    type     = _type;
    line     = _line;
    indent   = _indent;
    metadata = [];
    text     = undefined;
    
    static toString = function()
    {
        return "Instr " + string(type);
    }
}

/// @param parentInstruction
/// @param child
function __ChatterboxInstructionAdd(_parent, _child)
{
    if ((_child.indent > _parent.indent) && (_parent.type == "option"))
    {
        _parent.option_branch = _child;
        _child.option_branch_parent = _parent;
    }
    else
    {
        if ((_parent.type == "option")
        &&  (_child.indent <= _parent.indent)
        &&  !variable_struct_exists(_parent, "option_branch"))
        {
            //Add a marker to the end of a branch. This helps the VM understand what's going on!
            var _branch_end = new __ChatterboxClassInstruction("option end", _parent.line, _parent.indent);
            _parent.option_branch = _branch_end;
            _branch_end.option_branch_parent = _parent;
            _branch_end.next = _child;
        }
        
        if (variable_struct_exists(_parent, "option_branch_parent"))
        {
            if (_child.indent <= _parent.option_branch_parent.indent)
            {
                __ChatterboxInstructionAdd(_parent.option_branch_parent, _child);
                
                //Add a marker to the end of a branch. This helps the VM understand what's going on!
                var _branch_end = new __ChatterboxClassInstruction("option end", _parent.line, _parent.indent);
                __ChatterboxInstructionAdd(_parent, _branch_end);
                
                _branch_end.next = _child;
            }
            else
            {
                _parent.next = _child;
                _child.option_branch_parent = _parent.option_branch_parent;
            }
        }
        else
        {
            _parent.next = _child;
        }
    }
    
    return _child;
}
