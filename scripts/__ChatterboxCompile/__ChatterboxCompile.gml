// Feather disable all
/// @param substringList
/// @param rootInstruction
/// @param hashPrefix

function __ChatterboxCompile(_in_substring_array, _root_instruction, _hash_prefix)
{
    //Make sure we always terminate with a <<stop>> or <<hopback>>
    array_push(_in_substring_array, new __ChatterboxClassBodySubstring(CHATTERBOX_END_OF_NODE_HOPBACK? "hopback" : "stop", "command", infinity, 0, undefined, undefined));
    
    var _previous_instruction = _root_instruction;
    
    var _previous_line = 0;
    var _line_instructions = [];
    
    var _if_stack = [];
    var _if_depth = -1;
    
    var _substring_count = array_length(_in_substring_array);
    var _s = 0;
    while(_s < _substring_count)
    {
        var _substring_struct = _in_substring_array[_s];
        var _string = _substring_struct.text;
        var _type   = _substring_struct.type;
        var _line   = _substring_struct.line;
        var _indent = _substring_struct.indent;
        
        if (_line != _previous_line)
        {
            _line_instructions = [];
            _previous_line = _line;
        }
        
        var _instruction = undefined;
        
        if (__CHATTERBOX_DEBUG_COMPILER) __ChatterboxTrace("ln ", string_format(_line, 4, 0), " ", __ChatterboxGenerateIndent(_indent), _string);
        
        if (_type == "option")
        {
            // -> option
            var _instruction = new __ChatterboxClassInstruction("option", _line, _indent);
            _instruction.text = new __ChatterboxClassText(_string);
            _instruction.optionUUID = string(__ChatterboxXORShiftRandom());
        }
        else if (_type == "command")
        {
            #region <<command>>
            
            _string = __ChatterboxCompilerRemoveWhitespace(_string, true);
            
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
                        __ChatterboxEvaluate(undefined, undefined, _instruction.expression, "declare", undefined);
                        _instruction = undefined; //Don't add this instruction to the node
                    }
                break;
                
                case "constant":
                    var _instruction = new __ChatterboxClassInstruction(_first_word, _line, _indent);
                    _instruction.expression = __ChatterboxParseExpression(_remainder, false);
                    
                    if (CHATTERBOX_DECLARE_ON_COMPILE)
                    {
                        if (__CHATTERBOX_DEBUG_COMPILER) __ChatterboxTrace("Declaring \"", _remainder, "\" on compile via <<constant>>");
                        __ChatterboxEvaluate(undefined, undefined, _instruction.expression, "constant", undefined);
                        _instruction = undefined; //Don't add this instruction to the node
                    }
                break;
                
                case "set":
                    var _instruction = new __ChatterboxClassInstruction(_first_word, _line, _indent);
                    _instruction.expression = __ChatterboxParseExpression(_remainder, false);
                    
                    if (CHATTERBOX_DECLARE_ON_COMPILE)
                    {
                        if (__CHATTERBOX_DEBUG_COMPILER) __ChatterboxTrace("Declaring \"", _remainder, "\" on compile via <<set>>");
                        __ChatterboxEvaluate(undefined, undefined, _instruction.expression, "declare valueless", undefined);
                    }
                break;
                
                case "jump":
                    var _instruction = new __ChatterboxClassInstruction("jump", _line, _indent);
                    _instruction.destination = __ChatterboxCompilerRemoveWhitespace(_remainder, all);
                break;
                
                case "hop":
                    var _instruction = new __ChatterboxClassInstruction("hop", _line, _indent);
                    _instruction.destination = __ChatterboxCompilerRemoveWhitespace(_remainder, all);
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
                case "forcewait":
                case "hopback":
                case "fastforward":
                case "fastmark":
                case "stop":
                    _remainder = __ChatterboxCompilerRemoveWhitespace(_remainder, true);
                    if (_remainder != "")
                    {
                        __ChatterboxError("Cannot use arguments with <<wait>>, <<forcewait>>, <<hopback>>, <<fastforward>>, or <<stop>>\n\Action was \"<<", _string, ">>\"");
                    }
                    else
                    {
                        var _instruction = new __ChatterboxClassInstruction(_first_word, _line, _indent);
                    }
                break;
                
                default:
                    var _instruction = new __ChatterboxClassInstruction("action", _line, _indent);
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
                    var _is_line_hash = __ChatterboxMetadataStringIsLineHash(_string);
                    if (_is_line_hash)
                    {
                        var _instruction_text = _previous_instruction.text;
                        
                        if (_instruction_text == undefined)
                        {
                            __ChatterboxTrace("Warning! Cannot apply a line hash to a non-textual instruction");
                        }
                        else if (_instruction_text.loc_hash != undefined)
                        {
                            __ChatterboxError("Cannot apply more than one line hash to an instruction");
                        }
                        else
                        {
                            _instruction_text.loc_hash = _hash_prefix + string_delete(_string, 1, __CHATTERBOX_LINE_HASH_PREFIX_LENGTH);
                        }
                    }
                    
                    if (!CHATTERBOX_HIDE_LINE_HASH_METADATA || !_is_line_hash)
                    {
                        array_push(_previous_instruction.metadata, _string);
                    }
                    
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
        else
        {
            __ChatterboxError("Unrecognised substring type \"", _type, "\"");
        }
        
        if (_instruction != undefined)
        {
            __ChatterboxInstructionAdd(_previous_instruction, _instruction);
            _previous_instruction = _instruction;
            array_push(_line_instructions, _instruction);
        }
        
        ++_s;
    }
    
    //Don't pollute the input array!
    array_pop(_in_substring_array);
}
