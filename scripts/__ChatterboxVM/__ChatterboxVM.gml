// Feather disable all
function __ChatterboxVM()
{
    static _system = __ChatterboxSystem();
    
    do 
    {
        __ClearContent(0);
        __ClearOptions(0);
        
        stopped          = false;
        waiting          = false;
        forced_waiting   = false;
        waitingName      = "";
        wait_instruction = undefined;
        entered_option   = false;
        leaving_option   = false;
        randomize_option = false;
        rejected_if      = false;
        
        if (current_instruction.type == "stop")
        {
            stopped = true;
            if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("STOP (<<stop>>)");
            return undefined;
        }
        
        if ((current_instruction.type == "hopback") && __HopEmpty())
        {
            stopped = true;
            if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("STOP (<<hopback>>)");
            return undefined;
        }
        
        array_push(_system.__vmInstanceStack, self);
        _system.__current = self;
        
        __ChatterboxVMInner(current_instruction);
        
        array_pop(_system.__vmInstanceStack);
        _system.__current = (array_length(_system.__vmInstanceStack) <= 0)? undefined : _system.__vmInstanceStack[array_length(_system.__vmInstanceStack)-1];
        
        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("HALT");
    }
    until(!fastForward || stopped)
}

function __ChatterboxVMInner(_instruction)
{
    static _system = __ChatterboxSystem();
    
    var _do_next = true;
    var _next = variable_struct_get(_instruction, "next");
    
    if (is_string(_instruction.type))
    {
        var _condition_failed = false;
        
        if (!((_instruction.type == "if") || (_instruction.type == "else if")) && variable_struct_exists(_instruction, "condition"))
        {
            if (!__ChatterboxEvaluate(local_scope, filename, _instruction.condition, undefined, _instruction[$ "optionUUID"]))
            {
                _condition_failed = true;
            }
        }
        
        if (CHATTERBOX_SHOW_REJECTED_OPTIONS || !_condition_failed)
        {
            if ((_instruction.type == "option") && !leaving_option)
            {
                entered_option = true;
                
                if (_instruction.type == "option")
                {
                    var _branch = variable_struct_get(_instruction, "option_branch");
                    if (_branch == undefined) _branch = variable_struct_get(_instruction, "next");
                    
                    var _optionString = _instruction.text.Evaluate(local_scope, filename, false);
                    array_push(option, _optionString);
                    array_push(optionConditionBool, !_condition_failed);
                    array_push(optionMetadata, _instruction.metadata);
                    array_push(optionInstruction, _branch);
                    array_push(__optionUUIDArray, _instruction.optionUUID);
                    
                    array_push(optionStructArray, {
                        text: _optionString,
                        conditionBool: !_condition_failed,
                        metadata: _instruction.metadata,
                    });
                    
                    if (randomize_option)
                    {
                        //Parse metadata and search for weights
                        var _weight = undefined;
                        
                        var _metadataArray = _instruction.metadata;
                        var _i = 0;
                        repeat(array_length(_metadataArray))
                        {
                            var _metadata = _metadataArray[_i];
                            if (string_char_at(_metadata, string_length(_metadata)) == "%")
                            {
                                try
                                {
                                    _weight = real(string_copy(_metadata, 1, string_length(_metadata)-1)) / 100;
                                    break;
                                }
                                catch(_error)
                                {
                                    //Failed to parse metadata
                                }
                            }
                            
                            ++_i;
                        }
                        
                        array_push(optionWeightArray, _weight);
                    }
                    
                    if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), (_condition_failed? "<false> " : ""), "-> \"", _instruction.text.raw_string, "\"    ", instanceof(_branch));
                }
            }
            else
            {
                if ((_instruction.type != "option") && leaving_option) leaving_option = false;
            }
            
            if (entered_option)
            {
                if (_instruction.type != "option")
                {
                    if (randomize_option)
                    {
                        entered_option = false;
                        
                        //Calculate the total weight and unweighted count
                        var _totalWeight      = 0;
                        var _unweightedCount  = 0;
                        var _unweightedWeight = 0;
                        
                        var _i = 0;
                        repeat(array_length(optionWeightArray))
                        {
                            if (optionConditionBool[_i])
                            {
                                var _weight = optionWeightArray[_i];
                                if (_weight == undefined)
                                {
                                    _unweightedCount++;
                                }
                                else
                                {
                                    _totalWeight += real(_weight); 
                                }
                            }
                            
                            ++_i;
                        }
                        
                        //Figure out how much weight we should ascribe to unweighted options
                        if (_unweightedCount > 0)
                        {
                            if (_totalWeight < 1)
                            {
                                _unweightedWeight = (1 - _totalWeight) / _unweightedCount;
                                _totalWeight = 1;
                            }
                            else
                            {
                                _unweightedWeight = 0.1*_totalWeight;
                                _totalWeight += _unweightedWeight*_unweightedCount;
                                __ChatterboxTrace("Warning! Total weight for random option exceeds 1 but there are unweighted options");
                            }
                        }
                        
                        //Choose!
                        var _random = random(_totalWeight);
                        var _random_option = undefined;
                        
                        var _i = 0;
                        repeat(array_length(optionWeightArray))
                        {
                            if (optionConditionBool[_i])
                            {
                                var _weight = optionWeightArray[_i];
                                if (_weight == undefined)
                                {
                                    _random -= _unweightedWeight;
                                }
                                else
                                {
                                    _random -= real(_weight);
                                }
                                
                                if (_random <= 0)
                                {
                                    _random_option = _i;
                                    break;
                                }
                            }
                            
                            ++_i;
                        }
                        
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "Choosing random option index ", _random_option);
                        
                        _next = optionInstruction[_random_option];
                        
                        //Make sure we don't leak option data
                        __ClearOptions(0);
                    }
                    else
                    {
                        _do_next = false;
                    }
                }
            }
            else
            {
                switch(_instruction.type)
                {
                    case "content":
                        if (fastForward) __ClearContent(__fastForwardContentCount);
                        
                        var _contentString = _instruction.text.Evaluate(local_scope, filename, false);
                        array_push(content, _contentString);
                        array_push(contentConditionBool, !_condition_failed);
                        array_push(contentMetadata, _instruction.metadata);
                        array_push(contentStructArray, {
                            text: _contentString,
                            conditionBool: !_condition_failed,
                            metadata: _instruction.metadata,
                        });
                        
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), (_condition_failed? "<false> " : ""), _instruction.text.raw_string);
                        
                        if (singleton_text)
                        {
                            if (instanceof(_next) == "__ChatterboxClassInstruction")
                            {
                                if (((_next.type != "option") || CHATTERBOX_SINGLETON_WAIT_BEFORE_OPTION)
                                &&  (_next.type != "wait")
                                &&  (_next.type != "forcewait")
                                &&  (_next.type != "stop")
                                &&  !((_next.type == "hopback") && __HopEmpty()))
                                {
                                    waiting          = true;
                                    waitingName      = "";
                                    wait_instruction = _next;
                                }
                            }
                        }
                    break;
                    
                    case "wait":
                        _system.__vmWait     = true;
                        _system.__vmWaitName = _instruction.waitName;
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<wait \"" + string(_system.__vmWaitName) + "\">>");
                    break;
                    
                    case "forcewait":
                        _system.__vmWait      = true;
                        _system.__vmForceWait = true;
                        _system.__vmWaitName  = _instruction.waitName;
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<forcewait \"" + string(_system.__vmWaitName) + "\">>");
                    break;
                    
                    case "jump":
                    case "hop":
                        if (__CHATTERBOX_DEBUG_VM)
                        {
                            switch(_instruction.type)
                            {
                                case "jump": __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<jump ", _instruction.destination, ">>"); break;
                                case "hop":  __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<hop ",  _instruction.destination, ">>"); break;
                            }
                        }
                        
                        switch(_instruction.type)
                        {
                            case "jump":
                                if (not __HopEmpty())
                                {
                                    __ChatterboxTrace(__CHATTERBOX_DEBUG_VM? __ChatterboxGenerateIndent(_instruction.indent) : "", "Warning! Jumping to \"", _instruction.destination, "\" but hop stack has content. This may cause unexpected behaviour");
                                }
                            break;
                            
                            case "hop":
                                __HopPush(_next);
                            break;
                        }
                        
                        try
                        {
                            var _destination = __ChatterboxEvaluate(local_scope, filename, __ChatterboxParseExpression("(" + _instruction.destination + ")", false), undefined, undefined);
                        }
                        catch(_error)
                        {
                            //Catch e.g. <<jump A>> using a relaxed syntax
                            var _destination = _instruction.destination;
                        }
                        
                        var _split = __ChatterboxSplitGoto(_destination);
                        if (_split.filename == undefined)
                        {
                            var _next_node = FindNode(_split.node);
                            if (_next_node == undefined) __ChatterboxError("Node \"", _split.node, "\" could not be found in \"", filename, "\"");
                            
                            __ChangeNode(_next_node, true, _instruction.type);
                            _next = _next_node.root_instruction;
                        }
                        else
                        {
                            var _file = _system.__files[? __ChatterboxReplaceBackslashes(_split.filename)];
                            if (instanceof(_file) == "__ChatterboxClassSource")
                            {
                                file = _file;
                                filename = file.filename;
                                
                                _next_node = FindNode(_split.node);
                                if (_next_node == undefined) __ChatterboxError("Node \"", _split.node, "\" could not be found in \"", _split.filename, "\"");
                                
                                __ChangeNode(_next_node, true, _instruction.type);
                                _next = _next_node.root_instruction;
                            }
                            else
                            {
                                __ChatterboxTrace("Error! File \"", _split.filename, "\" not found or not loaded");
                            }
                        }
                    break;
                    
                    case "stop":
                    case "hopback":
                        if ((_instruction.type == "stop") || __HopEmpty())
                        {
                            //If there's nothing left in the hop stack, execute <<stop>> behaviour
                            
                            if (CHATTERBOX_WAIT_BEFORE_STOP && (array_length(content) > 0) && (array_length(option) <= 0))
                            {
                                waiting          = true;
                                waitingName      = "";
                                forced_waiting   = true;
                                wait_instruction = _instruction;
                            }
                            else
                            {
                                stopped = true;
                            }
                            
                            if (__CHATTERBOX_DEBUG_VM)
                            {
                                switch(_instruction.type)
                                {
                                    case "stop":    __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<stop>>"); break;
                                    case "hopback": __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<hopback>>  (hop stack empty)"); break;
                                }
                            }
                        }
                        else
                        {
                            //Otherwise pop a node off of our stack and go to it
                            var _hop_data = __HopPop();
                            var _next     = _hop_data.next;
                            var _node     = _hop_data.node;
                            var _filename = _hop_data.filename;
                            
                            if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<hopback>>  -->  ", _next);
                            
                            var _file = _system.__files[? __ChatterboxReplaceBackslashes(_filename)];
                            if (instanceof(_file) != "__ChatterboxClassSource")
                            {
                                __ChatterboxTrace("Error! File \"", _split.filename, "\" not found or not loaded");
                            }
                            
                            file     = _file;
                            filename = _file.filename;
                            
                            __ChangeNode(_node, false, "hopback");
                        }
                    break;
                    
                    case "jumpback":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<jumpback>>");
                        
                        __ChangeNode(previous_node, true, "jump");
                        _next = current_node.root_instruction;
                    break;
                    
                    case "fastforward":
                        fastForward = true;
                        __fastForwardContentCount = singleton_text? 0 : array_length(content);
                        
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<fastforward>>");
                    break;
                    
                    case "fastmark":
                        if (fastForward)
                        {
                            __ClearContent(__fastForwardContentCount);
                            fastForward = false;
                            _system.__vmFastForward = false;
                        }
                        
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<fastmark>>");
                    break;
                    
                    case "option end":
                        leaving_option = true;
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<option end>>");
                    break;
                    
                    case "declare":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(_instruction.expression);
                        __ChatterboxEvaluate(local_scope, filename, _instruction.expression, "declare", undefined);
                    break;
                    
                    case "constant":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(_instruction.expression);
                        __ChatterboxEvaluate(local_scope, filename, _instruction.expression, "constant", undefined);
                    break;
                    
                    case "set":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(_instruction.expression);
                        __ChatterboxEvaluate(local_scope, filename, _instruction.expression, "set", undefined);
                    break;
                    
                    case "action":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(_instruction.text.raw_string);
                        
                        var _direction_text = _instruction.text.Evaluate(local_scope, filename, true);
                        var _result = undefined;
                        
                        switch(CHATTERBOX_ACTION_MODE)
                        {
                            case 0:
                                if (is_method(CHATTERBOX_ACTION_FUNCTION))
                                {
                                    _result = CHATTERBOX_ACTION_FUNCTION(_direction_text);
                                }
                                else if (is_numeric(CHATTERBOX_ACTION_FUNCTION) && script_exists(CHATTERBOX_ACTION_FUNCTION))
                                {
                                    _result = script_execute(CHATTERBOX_ACTION_FUNCTION, _direction_text);
                                }
                            break;
                            
                            case 1:
                                _result = __ChatterboxEvaluate(local_scope, filename, __ChatterboxParseExpression(_direction_text, false), undefined, undefined);
                            break;
                            
                            case 2:
                                _result = __ChatterboxEvaluate(local_scope, filename, __ChatterboxParseExpression(_direction_text, true), undefined, undefined);
                            break;
                        }
                        
                        if (is_string(_result))
                        {
                            //TODO - Superceded by ChatterboxWait() / ChatterboxFastForward(). Remove in v3.0
                            
                            if (_result == "<<wait>>")
                            {
                                _system.__vmWait     = true;
                                _system.__vmWaitName = "";
                                if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<wait>> returned by function");
                            }
                            else if (_result == "<<forcewait>>")
                            {
                                _system.__vmWait      = true;
                                _system.__vmForceWait = true;
                                _system.__vmWaitName  = "";
                                if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<forcewait>> returned by function");
                            }
                            else if (_result == "<<fastforward>>")
                            {
                                _system.__vmFastForward = true;
                                if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<fastforward>> returned by function");
                            }
                        }
                    break;
                    
                    case "random option":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<random option>>");
                        randomize_option = true;
                    break;
                    
                    case "if":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("<<if>> ", _instruction.condition);
                        
                        if (__ChatterboxEvaluate(local_scope, filename, _instruction.condition, undefined, undefined))
                        {
                            rejected_if = false;
                        }
                        else
                        {
                            rejected_if = true;
                            _next = variable_struct_get(_instruction, "branch_reject");
                        }
                    break;
                    
                    case "else":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("<<else>>");
                        
                        if (!rejected_if)
                        {
                            _next = variable_struct_get(_instruction, "branch_reject");
                        }
                    break;
                    
                    case "else if":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("<<else if>> ", _instruction.condition);
                        
                        if (rejected_if && __ChatterboxEvaluate(local_scope, filename, _instruction.condition, undefined, undefined))
                        {
                            rejected_if = false;
                        }
                        else
                        {
                            _next = variable_struct_get(_instruction, "branch_reject");
                        }
                    break;
                    
                    case "end if":
                        rejected_if = false;
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("<<end if>>");
                    break;
                    
                    default:
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("\"", _instruction.type, "\" instruction ignored");
                    break;
                }
            }
        }
    }
    
    if (_system.__vmWait)
    {
        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "Something insisted the VM wait");
        
        waiting          = true;
        forced_waiting   = _system.__vmForceWait;
        waitingName      = _system.__vmWaitName;
        wait_instruction = _instruction.next;
        
        _system.__vmWait      = false;
        _system.__vmForceWait = false;
        _system.__vmWaitName  = "";
    }
    
    if (_system.__vmFastForward)
    {
        _system.__vmFastForward = false;
        fastForward = true;
        __fastForwardContentCount = singleton_text? 0 : array_length(content);
    }
    
    if (fastForward)
    {
        if (forced_waiting || entered_option)
        {
            fastForward = false
        }
        else if (waiting)
        {
            current_instruction = wait_instruction;
        }
    }
    
    if (_do_next && !waiting && !stopped)
    {
        if (instanceof(_next) == "__ChatterboxClassInstruction")
        {
            __ChatterboxVMInner(_next);
        }
        else
        {
            __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "Warning! Instruction found without next node (datatype=", instanceof(_next), ")");
            stopped = true;
        }
    }
}

/// @param string
function __ChatterboxSplitGoto(_string)
{
    var _pos = string_pos(CHATTERBOX_FILENAME_SEPARATOR, _string);
    if (_pos <= 0)
    {
        return {
            filename : undefined,
            node     : _string,
        };
    }
    else
    {
        return {
            filename : string_copy(_string, 1, _pos-1),
            node     : string_delete(_string, 1, _pos),
        };
    }
}
