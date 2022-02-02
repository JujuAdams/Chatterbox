/// @param filename
/// @param nodeTags
/// @param bodyString

function __ChatterboxClassNode(_filename, _node_metadata, _body_string) constructor
{
    filename         = _filename;
    title            = _node_metadata.title;
    metadata         = _node_metadata;
    root_instruction = new __ChatterboxClassInstruction(undefined, -1, 0);
    
    if (__CHATTERBOX_DEBUG_COMPILER) __ChatterboxTrace("[", title, "]");
    
    //Prepare body string for parsing
    var _work_string = _body_string;
    _work_string = string_replace_all(_work_string, "\n\r", "\n");
    _work_string = string_replace_all(_work_string, "\r\n", "\n");
    _work_string = string_replace_all(_work_string, "\r"  , "\n");
    
    //Perform find-replace
    var _i = 0;
    repeat(ds_list_size(global.__chatterboxFindReplaceOldString))
    {
        _work_string = string_replace_all(_work_string,
                                          global.__chatterboxFindReplaceOldString[| _i],
                                          global.__chatterboxFindReplaceNewString[| _i]);
        ++_i;
    }
    
    //Add a trailing newline to make sure we parse correctly
    _work_string += "\n";
    
    var _substring_array = __ChatterboxSplitBody(_work_string);
    __ChatterboxCompile(_substring_array, root_instruction);
    
    static MarkVisited = function()
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
    
    static toString = function()
    {
        return "Node " + string(filename) + CHATTERBOX_FILENAME_SEPARATOR + string(title);
    }
}

/// @param bodyString
function __ChatterboxSplitBody(_body)
{
    var _in_substring_array = [];
    
    var _body_byte_length = string_byte_length(_body);
    var _body_buffer = buffer_create(_body_byte_length+1, buffer_fixed, 1);
    buffer_write(_body_buffer, buffer_string, _body);
    buffer_seek(_body_buffer, buffer_seek_start, 0);
    
    var _line          = 0;
    var _first_on_line = true;
    var _indent        = undefined;
    var _newline       = false;
    var _cache         = "";
    var _cache_type    = "text";
    var _prev_value    = 0;
    var _value         = 0;
    var _next_value    = __ChatterboxReadUTF8Char(_body_buffer);
    var _in_comment    = false;
    var _in_metadata   = false;
    var _in_action     = false;
    
    repeat(_body_byte_length)
    {
        if (_next_value == 0) break;
        
        _prev_value = _value;
        _value      = _next_value;
        _next_value = __ChatterboxReadUTF8Char(_body_buffer);
        
        var _write_cache = true;
        var _pop_cache   = false;
        
        if ((_value == ord("\n")) || (_value == ord("\r")))
        {
            _newline     = true;
            _pop_cache   = true;
            _write_cache = false;
            _in_comment  = false;
            _in_metadata = false;
        }
        else if (_in_comment)
        {
            _write_cache = false;
        }
        else if (_in_metadata)
        {
            if ((_value == ord("/")) && (_next_value == ord("/")))
            {
                _in_comment  = true;
                _pop_cache   = true;
                _write_cache = false;
            }
            else if (_value == ord("#"))
            {
                _pop_cache   = true;
                _write_cache = false;
            }
        }
        else
        {
            if ((_prev_value != ord("\\")) && (_value == ord("#")) && !_in_action)
            {
                _in_metadata = true;
                _pop_cache   = true;
                _write_cache = false;
            }
            else if ((_value == ord("/")) && (_next_value == ord("/")) && !_in_action)
            {
                _in_comment  = true;
                _pop_cache   = true;
                _write_cache = false;
            }
            else if (_value == ord(__CHATTERBOX_ACTION_OPEN_DELIMITER))
            {
                if (_next_value == ord(__CHATTERBOX_ACTION_OPEN_DELIMITER))
                {
                    _write_cache = false;
                    _pop_cache   = true;
                }
                else if (_prev_value == ord(__CHATTERBOX_ACTION_OPEN_DELIMITER))
                {
                    _write_cache = false;
                    _cache_type  = "command";
                    _in_action   = true;
                }
            }
            else if (_value == ord(__CHATTERBOX_ACTION_CLOSE_DELIMITER))
            {
                if (_next_value == ord(__CHATTERBOX_ACTION_CLOSE_DELIMITER))
                {
                    _write_cache = false;
                    _pop_cache   = true;
                }
                else if (_prev_value == ord(__CHATTERBOX_ACTION_CLOSE_DELIMITER))
                {
                    _write_cache = false;
                    _in_action   = false;
                }
            }
        }
        
        if (_write_cache) _cache += chr(_value);
        
        if (_pop_cache)
        {
            if (_first_on_line)
            {
                _cache = __ChatterboxRemoveWhitespace(_cache, true);
                _indent = global.__chatterboxIndentSize;
            }
            else if (_in_metadata)
            {
                _cache = __ChatterboxRemoveWhitespace(_cache, true);
                _indent = 0;
            }
            
            _cache = __ChatterboxRemoveWhitespace(_cache, false);
            
            if (_cache != "") array_push(_in_substring_array, [_cache, _cache_type, _line, _indent]);
            _cache = "";
            _cache_type = _in_metadata? "metadata" : "text";
            
            if (_newline)
            {
                _newline = false;
                ++_line;
                _first_on_line = true;
                _indent = undefined;
            }
            else
            {
                _first_on_line = false;
            }
        }
    }
    
    buffer_delete(_body_buffer);
    
    array_push(_in_substring_array, ["stop", "command", _line, 0]);
    return _in_substring_array;
}

/// @param substringList
/// @param rootInstruction
function __ChatterboxCompile(_in_substring_array, _root_instruction)
{
    if (array_length(_in_substring_array) <= 0) exit;
    
    var _previous_instruction = _root_instruction;
    
    var _previous_line = 0;
    var _line_instructions = [];
    
    var _if_stack = [];
    var _if_depth = -1;
    
    var _substring_count = array_length(_in_substring_array);
    var _s = 0;
    while(_s < _substring_count)
    {
        var _substring_array = _in_substring_array[_s];
        var _string          = _substring_array[0];
        var _type            = _substring_array[1];
        var _line            = _substring_array[2];
        var _indent          = _substring_array[3];
        
        if (_line != _previous_line)
        {
            _line_instructions = [];
            _previous_line = _line;
        }
        
        var _instruction = undefined;
        
        if (__CHATTERBOX_DEBUG_COMPILER) __ChatterboxTrace("ln ", string_format(_line, 4, 0), " ", __ChatterboxGenerateIndent(_indent), _string);
        
        if (string_copy(_string, 1, 2) == "->") //Option //TODO - Make this part of the substring splitting step
        {
            var _instruction = new __ChatterboxClassInstruction("option", _line, _indent);
            _instruction.text = new __ChatterboxClassText(__ChatterboxRemoveWhitespace(string_delete(_string, 1, 2), all));
        }
        else if (_type == "command")
        {
            #region <<command>>
            
            _string = __ChatterboxRemoveWhitespace(_string, true);
            
            var _pos = string_pos(" ", _string);
            if (_pos > 0)
            {
                var _first_word = string_copy(_string, 1, _pos-1);
                var _remainder = string_delete(_string, 1, _pos);
            }
            else
            {
                var _first_word = _string;
                var _remainder = "";
            }
            
            switch(_first_word)
            {
                case "declare":
                    var _instruction = new __ChatterboxClassInstruction(_first_word, _line, _indent);
                    _instruction.expression = __ChatterboxParseExpression(_remainder, false);
                    
                    if (CHATTERBOX_DECLARE_ON_COMPILE)
                    {
                        if (__CHATTERBOX_DEBUG_COMPILER) __ChatterboxTrace("Declaring \"", _remainder, "\" on compile via <<declare>>");
                        __ChatterboxEvaluate(undefined, undefined, _instruction.expression, "declare");
                        _instruction = undefined; //Don't add this instruction to the node
                    }
                break;
                
                case "set":
                    var _instruction = new __ChatterboxClassInstruction(_first_word, _line, _indent);
                    _instruction.expression = __ChatterboxParseExpression(_remainder, false);
                    
                    if (CHATTERBOX_DECLARE_ON_COMPILE)
                    {
                        if (__CHATTERBOX_DEBUG_COMPILER) __ChatterboxTrace("Declaring \"", _remainder, "\" on compile via <<set>>");
                        __ChatterboxEvaluate(undefined, undefined, _instruction.expression, "declare valueless");
                    }
                break;
                
                case "jump":
                    var _instruction = new __ChatterboxClassInstruction("jump", _line, _indent);
                    _instruction.destination = __ChatterboxRemoveWhitespace(_remainder, all);
                break;
                
                case "if":
                    if (_previous_instruction.line == _line)
                    {
                        _previous_instruction.condition = __ChatterboxParseExpression(_remainder, false);
                        //We *don't* make a new instruction for the if-statement, just attach it to the previous instruction as a condition
                    }
                    else
                    {
                        var _instruction = new __ChatterboxClassInstruction("if", _line, _indent);
                        _instruction.condition = __ChatterboxParseExpression(_remainder, false);
                        _if_depth++;
                        _if_stack[@ _if_depth] = _instruction;
                    }
                break;
                    
                case "else":
                    var _instruction = new __ChatterboxClassInstruction("else", _line, _indent);
                    if (_if_depth < 0)
                    {
                        __ChatterboxError("<<else>> found without matching <<if>>");
                    }
                    else
                    {
                        _if_stack[_if_depth].branch_reject = _instruction;
                        _if_stack[@ _if_depth] = _instruction;
                    }
                break;
                
                case "elif":
                case "else if":
                    if (CHATTERBOX_ERROR_NONSTANDARD_SYNTAX) __ChatterboxError("<<", _first_word, ">> is non-standard Yarn syntax, please use <<elseif>>\n \n(Set CHATTERBOX_ERROR_NONSTANDARD_SYNTAX to <false> to hide this error)");
                case "elseif":
                    var _instruction = new __ChatterboxClassInstruction("else if", _line, _indent);
                    _instruction.condition = __ChatterboxParseExpression(_remainder, false);
                    if (_if_depth < 0)
                    {
                        __ChatterboxError("<<else if>> found without matching <<if>>");
                    }
                    else
                    {
                        _if_stack[_if_depth].branch_reject = _instruction;
                        _if_stack[@ _if_depth] = _instruction;
                    }
                break;
                
                case "end if":
                    if (CHATTERBOX_ERROR_NONSTANDARD_SYNTAX) __ChatterboxError("<<end if>> is non-standard Yarn syntax, please use <<endif>>\n \n(Set CHATTERBOX_ERROR_NONSTANDARD_SYNTAX to <false> to hide this error)");
                case "endif":
                    var _instruction = new __ChatterboxClassInstruction("end if", _line, _indent);
                    if (_if_depth < 0)
                    {
                        __ChatterboxError("<<endif>> found without matching <<if>>");
                    }
                    else
                    {
                        _if_stack[_if_depth].branch_reject = _instruction;
                        _if_depth--;
                    }
                break;
                
                case "wait":
                case "stop":
                    _remainder = __ChatterboxRemoveWhitespace(_remainder, true);
                    if (_remainder != "")
                    {
                        __ChatterboxError("Cannot use arguments with <<wait>> or <<stop>>\n\Action was \"<<", _string, ">>\"");
                    }
                    else
                    {
                        var _instruction = new __ChatterboxClassInstruction(_first_word, _line, _indent);
                    }
                break;
                
                default:
                    var _instruction = new __ChatterboxClassInstruction("direction", _line, _indent);
                    _instruction.text = new __ChatterboxClassText(_string);
                break;
            }
            
            #endregion
        }
        else if (_type == "metadata")
        {
            #region #metadata
            
            var _count = 0;
            var _i = 0;
            repeat(array_length(_line_instructions))
            {
                if ((_previous_instruction.type == "content") || (_previous_instruction.type == "option"))
                {
                    array_push(_previous_instruction.metadata, _string);
                    ++_count;
                }
                
                ++_i;
            }
            
            if (_count <= 0)
            {
                __ChatterboxTrace("Warning! Line contained no content or options, metadata \"\#", _string, "\" cannot be applied");
            }
            
            #endregion
        }
        else if (_type == "text")
        {
            var _instruction = new __ChatterboxClassInstruction("content", _line, _indent);
            _instruction.text = new __ChatterboxClassText(_string);
        }
        
        if (_instruction != undefined)
        {
            __ChatterboxInstructionAdd(_previous_instruction, _instruction);
            _previous_instruction = _instruction;
            array_push(_line_instructions, _instruction);
        }
        
        ++_s;
    }
}