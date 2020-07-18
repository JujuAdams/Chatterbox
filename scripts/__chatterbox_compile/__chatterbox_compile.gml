/// @param substringList
/// @param rootInstruction

function __chatterbox_compile(_substring_list, _root_instruction)
{
    if (ds_list_size(_substring_list) <= 0) exit;
    
    var _previous_instruction = _root_instruction;
    
    var _if_stack = [];
    var _if_depth = -1;
    
    var _shortcut_stack  = [];
    var _shortcut_indent = [];
    var _shortcut_depth  = -1;
    
    var _substring_count = ds_list_size(_substring_list);
    var _s = 0;
    while(_s < _substring_count)
	{
	    var _substring_array = _substring_list[| _s];
	    var _string          = _substring_array[0];
	    var _type            = _substring_array[1];
	    var _line            = _substring_array[2];
	    var _indent          = _substring_array[3];
        
        var _adding_option = false;
        var _instruction   = undefined;
        
        __chatterbox_trace(string_format(_indent, 4, 0), ": " + _string, "    ", _type, "    ", _line);
        
        if (string_copy(_string, 1, 2) == "->") //Shortcut //TODO - Make this part of the substring splitting step
    	{
            var _instruction = new __chatterbox_class_instruction("shortcut", _line);
            _instruction.text = __chatterbox_remove_whitespace(__chatterbox_remove_whitespace(string_delete(_string, 1, 2), true), false);
            _adding_option = true;
    	}
        else if (_type == "action")
        {
            #region <<action>>   (includes if/elseif/endif)
            
            var _content = __chatterbox_tokenize_action(_string);
            switch(_content[0])
            {
                case "if":
                    if ((_previous_instruction != undefined) && (_previous_instruction.line == _line))
                    {
                        _previous_instruction.condition = _content;
                    }
                    else
                    {
                        var _instruction = new __chatterbox_class_instruction("if", _line);
                        _instruction.condition = _content;
                        _if_depth++;
                        _if_stack[@ _if_depth] = _instruction;
                    }
        	    break;
                    
                case "else":
                    var _instruction = new __chatterbox_class_instruction("else", _line);
                    if (_if_depth < 0)
                    {
                        __chatterbox_error("<<else>> found without matching <<if>>");
                    }
                    else
                    {
                        _if_stack[_if_depth].branch_end = _instruction;
                    }
        	    break;
                    
                case "elseif":
                case "else if":
                    var _instruction = new __chatterbox_class_instruction("else if", _line);
                    _instruction.condition = _content;
                    if (_if_depth < 0)
                    {
                        __chatterbox_error("<<else if>> found without matching <<if>>");
                    }
                    else
                    {
                        _if_stack[_if_depth].branch_end = _instruction;
                        _if_stack[@ _if_depth] = _instruction;
                    }
        	    break;
                    
                case "endif":
                case "end if":
                    var _instruction = new __chatterbox_class_instruction("end if", _line);
                    if (_if_depth < 0)
                    {
                        __chatterbox_error("<<endif>> found without matching <<if>>");
                    }
                    else
                    {
                        _if_stack[_if_depth].branch_end = _instruction;
                        _if_depth--;
                    }
        	    break;
                    
        	    case "set":
                    var _instruction = new __chatterbox_class_instruction(_content[0], _line);
                    _instruction.expression = _content;
                break;
                
        	    case "stop":
        	    case "wait":
                    var _instruction = new __chatterbox_class_instruction(_content[0], _line);
        	    break;
                    
        	    default:
                    //TODO - Check against global.__chatterbox_actions
                    var _instruction = new __chatterbox_class_instruction("action", _line);
                    _instruction.expression = _content;
                break;
    	    }
            
            #endregion
        }
        else if (_type == "option")
        {
            #region [[option]]
            
    	    var _pos = string_pos("|", _string);
    	    if (_pos < 1)
    	    {
                var _instruction = new __chatterbox_class_instruction("goto", _line);
                _instruction.destination = __chatterbox_remove_whitespace(__chatterbox_remove_whitespace(_string, true), false);
    	    }
    	    else
    	    {
                var _instruction = new __chatterbox_class_instruction("option", _line);
                _instruction.text = __chatterbox_remove_whitespace(string_copy(_string, 1, _pos-1), false);
                _instruction.destination = __chatterbox_remove_whitespace(string_delete(_string, 1, _pos), true);
    	    }
            
            _adding_option = true;
            
            #endregion
        }
        else
        {
            var _instruction = new __chatterbox_class_instruction("content", _line);
            _instruction.text = _string;
        }
        
        if (_instruction != undefined)
        {
            if (_previous_instruction == undefined)
            {
                root_instruction = _instruction;
            }
            else
            {
                _previous_instruction.next = _instruction;
            }
            
            if (_adding_option)
            {
                while((_shortcut_depth >= 0) && (_indent < _shortcut_indent[_shortcut_depth]))
                {
                    var _insert_instruction = new __chatterbox_class_instruction("end options", _line);
                    
                    _shortcut_stack[_shortcut_depth].next_option = _insert_instruction;
                    _previous_instruction.next = _insert_instruction;
                    _previous_instruction = _insert_instruction;
                    
                    _shortcut_depth--;
                }
                
                if ((_shortcut_depth < 0) || (_indent > _shortcut_indent[_shortcut_depth]))
                {
                    _shortcut_depth++;
                    _shortcut_stack[@  _shortcut_depth] = _instruction;
                    _shortcut_indent[@ _shortcut_depth] = _indent;
                }
                else if (_indent == _shortcut_indent[_shortcut_depth])
                {
                    _instruction.previous_option = _shortcut_stack[_shortcut_depth];
                    _shortcut_stack[_shortcut_depth].next_option = _instruction;
                    if (_shortcut_stack[_shortcut_depth].next == _instruction) _shortcut_stack[_shortcut_depth].next = undefined;
                    _shortcut_stack[@ _shortcut_depth] = _instruction;
                }
            }
            else
            {
                while((_shortcut_depth >= 0) && (_indent <= _shortcut_indent[_shortcut_depth]))
                {
                    var _insert_instruction = new __chatterbox_class_instruction("end options", _line);
                    
                    _shortcut_stack[_shortcut_depth].next_option = _insert_instruction;
                    _previous_instruction.next = _insert_instruction;
                    _previous_instruction = _insert_instruction;
                    
                    _shortcut_depth--;
                }
            }
            
            _previous_instruction = _instruction;
        }
        
        ++_s;
    }
}