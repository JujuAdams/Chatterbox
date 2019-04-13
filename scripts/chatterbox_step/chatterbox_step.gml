/// @param json         The Chatterbox data structure to process
/// @param [stepSize]   The step size e.g. a delta time coefficient. Defaults to CHATTERBOX_DEFAULT_STEP_SIZE

var _chatterbox = argument[0];
var _step_size = ((argument_count > 1) && (argument_count[1] != undefined))? argument[1] : CHATTERBOX_DEFAULT_STEP_SIZE;



var _node_title  = _chatterbox[| __CHATTERBOX.TITLE    ];
var _filename    = _chatterbox[| __CHATTERBOX.FILENAME ];
var _text_list   = _chatterbox[| __CHATTERBOX.TEXTS    ];
var _button_list = _chatterbox[| __CHATTERBOX.BUTTONS  ];
var _if_stack    = _chatterbox[| __CHATTERBOX.IF_STACK ];   

if (_node_title == undefined)
{
    //If the node title is <undefined> then this chatterbox has been stopped
    exit;
}



//Perform a step for all nested Scribble data structures
for(var _i = ds_list_size(_text_list  )-1; _i >= 0; _i--) scribble_step(_text_list[|   _i], _step_size);
for(var _i = ds_list_size(_button_list)-1; _i >= 0; _i--) scribble_step(_button_list[| _i], _step_size);



var _title_map = global.__chatterbox_data[? _filename ];
var _instruction_list = _title_map[? _node_title ];

var _button_type   = __CHATTERBOX_VM_UNKNOWN;
var _button_indent = undefined;
var _indent        = 0;

var _evaluate = false;
if (!_chatterbox[| __CHATTERBOX.INITIALISED])
{
    _chatterbox[| __CHATTERBOX.INITIALISED] = true;
    
    //If this chatterbox hasn't been initialised skip straight to evaluation
    _evaluate = true;
    
    var _instruction       = _chatterbox[| __CHATTERBOX.INSTRUCTION ];
    var _instruction_array = _instruction_list[| _instruction];
        _indent            = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT ];
}
else
{
    #region Detect if the player has progressed the dialogue
    
    for(var _i = ds_list_size(_button_list)-1; _i >= 0; _i--)
    {
        if (keyboard_check_pressed(ord(string(_i+1))))
        { 
            var _button = _button_list[| _i ];
            var _instruction = _button[| __SCRIBBLE.__SIZE ]; //Read the instruction index from a borrowed slot in the Scribble data structure
            
            var _button_array  = _instruction_list[| _instruction];
                _button_type   = _button_array[ __CHATTERBOX_INSTRUCTION.TYPE   ];
                _button_indent = _button_array[ __CHATTERBOX_INSTRUCTION.INDENT ];
            
            show_debug_message("Chatterbox: Selected option " + string(_i));
            
            switch(_button_type)
            {
                case __CHATTERBOX_VM_TEXT:
                    //Advance to the next instruction
                    _instruction++;
                    //Use the ident value of the text itself
                    _indent = _button_indent;
                break;
                
                case __CHATTERBOX_VM_SHORTCUT:
                    //Advance to the next instruction
                    _instruction++;
                    //Use the ident value of the next instruction
                    var _instruction_array = _instruction_list[| _instruction ];
                        _indent            = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT ];
                break;
                
                case __CHATTERBOX_VM_OPTION:
                    //Jump out to another node
                    var _content = _button_array[ __CHATTERBOX_INSTRUCTION.CONTENT ];
                    chatterbox_start(_chatterbox, _content[1]);
                    exit;
                break;
            }
            
            _evaluate = true;
        }
    }
    
    #endregion
}

if (_evaluate)
{
    //Wipe all the old text and buttons
    for(var _i = ds_list_size(_text_list  )-1; _i >= 0; _i--) scribble_destroy(_text_list[|   _i]);
    for(var _i = ds_list_size(_button_list)-1; _i >= 0; _i--) scribble_destroy(_button_list[| _i]);
    ds_list_clear(_text_list);
    ds_list_clear(_button_list);
    
    #region Evaluate Yarn virtual machine
    
    var _found_text = false;
    
    var _break = false;
    repeat(9999)
    {
        var _continue = false;
        
        var _instruction_array   = _instruction_list[| _instruction ];
        var _instruction_type    = _instruction_array[ __CHATTERBOX_INSTRUCTION.TYPE    ];
        var _instruction_indent  = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT  ];
        var _instruction_content = _instruction_array[ __CHATTERBOX_INSTRUCTION.CONTENT ];
        
        if (_instruction_indent < _indent)
        {
            if (!_found_text)
            {
                _indent = _instruction_indent;
                _continue = true;
            }
            else
            {
                _break = true;
            }
        }
        else if (_instruction_indent > _indent)
        {
            _continue = true;
        }
        
        if (!_break && !_continue)
        {
            #region Handle branches
            
            switch(_instruction_type)
            {
                case __CHATTERBOX_VM_IF:
                case __CHATTERBOX_VM_ELSEIF:
                    //Only evaluate the if-statement if we passed the previous check
                    if (_instruction_type == __CHATTERBOX_VM_ELSEIF)
                    {
                        if (!_if_stack[| 0])
                        {
                            ds_list_insert(_if_stack, 0, false);
                            _continue = true;
                            break;
                        }
                    }
                    
                    //Only evaluate the if-statement if we failed the previous check
                    if (_instruction_type == __CHATTERBOX_VM_ELSEIF)
                    {
                        if (_if_stack[| 0])
                        {
                            _if_stack[| 0] = false;
                            _continue = true;
                            break;
                        }
                        
                        //Pop the top result from the stack - we'll replace it shortly
                        ds_list_delete(_if_stack, 0);
                    }
                    
                    var _target_value = _instruction_content[3];
                    var _if_result = !_target_value;
                    
                    //Push the result to the top of the stack
                    ds_list_insert(_if_stack, 0, _if_result);
                break;
                
                case __CHATTERBOX_VM_ELSE:
                    //Invert the value on the top of the stack
                    _if_stack[| 0] = !_if_stack[| 0];
                break;
                
                case __CHATTERBOX_VM_IF_END:
                    //Pop the top result from the stack
                    ds_list_delete(_if_stack, 0);
                    _continue = true;
                break;
            }
            
            #endregion
        }
        
        if (!_break && !_continue)
        {
            //If we're inside a branch that has been evaluated as <false> then keep skipping until we close the branch
            if (!_if_stack[| 0]) _continue = true;
        }
        
        if (!_break && !_continue)
        {
            var _new_button      = false;
            var _new_button_text = "";
            switch(_instruction_type)
            {
                case __CHATTERBOX_VM_TEXT:
                    if (_found_text)
                    {
                        _break = true;
                        break;
                    }
                    
                    show_debug_message("Chatterbox: " + _node_title + ":" + string(_instruction) + " TEXT = \"" + string(_instruction_content[0]) + "\"");
                    _found_text = true;
                    
                    var _text = scribble_create(_instruction_content[0]);
                    ds_list_insert(_text_list, 0, _text);
                break;
                
                case __CHATTERBOX_VM_SHORTCUT:
                    if (!_found_text) break;
                    show_debug_message("Chatterbox: " + _node_title + ":" + string(_instruction) + ", indent=" + string(_indent) + ", SHORTCUT = \"" + string(_instruction_content[0]) + "\"");
                    _new_button = true;
                    _new_button_text = _instruction_content[0];
                break;
                
                case __CHATTERBOX_VM_OPTION:
                    if (!_found_text) break;
                    show_debug_message("Chatterbox: " + _node_title + ":" + string(_instruction) + " OPTION = \"" + string(_instruction_content[0]) + "\" -> \"" + string(_instruction_content[1]) + "\"");
                    _new_button = true;
                    _new_button_text = _instruction_content[0];
                break;
                
                case __CHATTERBOX_VM_STOP:
                    if (!_found_text)
                    {
                        show_debug_message("Chatterbox: " + _node_title + ":" + string(_instruction) + " STOP");
                        chatterbox_stop(_chatterbox);
                        exit;
                    }
                    else
                    {
                        _break = true;
                        break;
                    }
                break;
            }
        
            #region Create a new button from SHORTCUT and OPTION instructions
            if (_new_button)
            {
                _new_button = false;
                var _button = scribble_create(_new_button_text);
                
                if (ds_list_size(_button_list) <= 0)
                {
                    if (ds_list_size(_text_list) <= 0)
                    {
                        var _y_offset = 0;
                    }
                    else
                    {
                        var _primary_text = _text_list[| 0];
                        var _y_offset = _primary_text[| __SCRIBBLE.TOP ] + _primary_text[| __SCRIBBLE.HEIGHT ] + 15;
                    }
                
                    _button[| __SCRIBBLE.LEFT   ] += 10;
                    _button[| __SCRIBBLE.TOP    ] += _y_offset;
                    _button[| __SCRIBBLE.RIGHT  ] += 10;
                    _button[| __SCRIBBLE.BOTTOM ] += _y_offset;
                    _button[| __SCRIBBLE.__SIZE ]  = _instruction; //Borrow a slot in the Scribble data structure to store the instruction index
                }
                else
                {
                    var _prev_button = _button_list[| ds_list_size(_button_list)-1];
                    var _x_offset = _prev_button[| __SCRIBBLE.LEFT ] - _button[| __SCRIBBLE.LEFT ];
                    var _y_offset = _prev_button[| __SCRIBBLE.TOP ] + _prev_button[| __SCRIBBLE.HEIGHT ] + 5;
                    _button[| __SCRIBBLE.LEFT   ] += _x_offset;
                    _button[| __SCRIBBLE.TOP    ] += _y_offset;
                    _button[| __SCRIBBLE.RIGHT  ] += _x_offset;
                    _button[| __SCRIBBLE.BOTTOM ] += _y_offset;
                    _button[| __SCRIBBLE.__SIZE ]  = _instruction; //Borrow a slot in the Scribble data structure to store the instruction index
                }
                
                ds_list_add(_button_list, _button);
            }
            #endregion
        }
        
        if (_break) break;
        
        _instruction++;
    }
    
    #region Create a new button from a TEXT instruction if no option or shortcut was found
    
    if (ds_list_size(_button_list) <= 0)
    {
        if (ds_list_size(_text_list) <= 0)
        {
            var _y_offset = 0;
        }
        else
        {
            var _primary_text = _text_list[| 0];
            var _y_offset = _primary_text[| __SCRIBBLE.TOP ] + _primary_text[| __SCRIBBLE.HEIGHT ] + 15;
        }
        
        var _button = scribble_create(CHATTERBOX_CONTINUE_TEXT);
        _button[| __SCRIBBLE.LEFT   ] += 10;
        _button[| __SCRIBBLE.TOP    ] += _y_offset;
        _button[| __SCRIBBLE.RIGHT  ] += 10;
        _button[| __SCRIBBLE.BOTTOM ] += _y_offset;
        _button[| __SCRIBBLE.__SIZE ]  = _instruction-1; //Borrow a slot in the Scribble data structure to store the instruction index
        ds_list_add(_button_list, _button);
    }
    
    #endregion
    
    #endregion
}