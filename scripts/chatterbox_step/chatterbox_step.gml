/// @param json         The Chatterbox data structure to process
/// @param [stepSize]   The step size e.g. a delta time coefficient. Defaults to CHATTERBOX_DEFAULT_STEP_SIZE

var _chatterbox = argument[0];
var _step_size = ((argument_count > 1) && (argument_count[1] != undefined))? argument[1] : CHATTERBOX_DEFAULT_STEP_SIZE;



var _node_title    = _chatterbox[| __CHATTERBOX.TITLE     ];
var _filename      = _chatterbox[| __CHATTERBOX.FILENAME  ];
var _scribble_list = _chatterbox[| __CHATTERBOX.SCRIBBLES ];
var _button_list   = _chatterbox[| __CHATTERBOX.BUTTONS   ];

if (_node_title == undefined)
{
    //If the node title is <undefined> then this chatterbox has been stopped
    exit;
}



var _title_map = global.__chatterbox_data[? _filename ];
var _instruction_list = _title_map[? _node_title ];



//Perform a step for all nested Scribble data structures
for(var _i = ds_list_size(_scribble_list)-1; _i >= 0; _i--) scribble_step(_scribble_list[| _i], _step_size);
for(var _i = ds_list_size(_button_list  )-1; _i >= 0; _i--) scribble_step(  _button_list[| _i], _step_size);



var _evaluate = false;
if (!_chatterbox[| __CHATTERBOX.INITIALISED])
{
    //If this chatterbox hasn't been initialised skip straight to evaluation
    _evaluate = true;
    _chatterbox[| __CHATTERBOX.INITIALISED] = true;
    var _instruction = _chatterbox[| __CHATTERBOX.INSTRUCTION ];
}
else
{
    for(var _i = ds_list_size(_button_list)-1; _i >= 0; _i--)
    {
        if (keyboard_check_pressed(ord(string(_i+1))))
        { 
            var _button = _button_list[| _i ];
            var _instruction = _button[| __SCRIBBLE.__SIZE ]; //Read the instruction index from a borrowed slot in the Scribble data structure
            
            var _instruction_array = _instruction_list[| _instruction];
            var _instruction_type  = _instruction_array[ __CHATTERBOX_INSTRUCTION.TYPE ];
            
            if (_instruction_type == __CHATTERBOX_VM_TEXT)
            {
                //Advance to the next instruction
                _instruction++;
            }
            else if (_instruction_type == __CHATTERBOX_VM_OPTION)
            {
                var _instruction_content_2 = _instruction_array[ __CHATTERBOX_INSTRUCTION.CONTENT_2 ];
                
                //Wipe all the old text and buttons
                for(var _i = ds_list_size(_scribble_list)-1; _i >= 0; _i--) scribble_destroy(_scribble_list[| _i]);
                for(var _i = ds_list_size(_button_list  )-1; _i >= 0; _i--) scribble_destroy(  _button_list[| _i]);
                ds_list_clear(_scribble_list);
                ds_list_clear(_button_list);
                
                //Jump out to another node
                chatterbox_start(_chatterbox, _instruction_content_2);
                exit;
            }
            
            _evaluate = true;
        }
    }
    
    if (_evaluate)
    {
        for(var _i = ds_list_size(_scribble_list)-1; _i >= 0; _i--) scribble_destroy(_scribble_list[| _i]);
        for(var _i = ds_list_size(_button_list  )-1; _i >= 0; _i--) scribble_destroy(  _button_list[| _i]);
        ds_list_clear(_scribble_list);
        ds_list_clear(_button_list);
    }
}

if (_evaluate)
{
    var _first_iteration = true;
    var _indent = _chatterbox[| __CHATTERBOX.INDENT ];
    var _previous_instruction_type = __CHATTERBOX_VM_UNKNOWN;
    
    var _break = false;
    repeat(9999)
    {
        var _instruction_array     = _instruction_list[| _instruction];
        var _instruction_type      = _instruction_array[ __CHATTERBOX_INSTRUCTION.TYPE      ];
        var _instruction_indent    = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT    ];
        var _instruction_content   = _instruction_array[ __CHATTERBOX_INSTRUCTION.CONTENT   ];
        var _instruction_content_2 = _instruction_array[ __CHATTERBOX_INSTRUCTION.CONTENT_2 ];
        
        switch(_instruction_type)
        {
            case __CHATTERBOX_VM_TEXT:
                if (_previous_instruction_type != __CHATTERBOX_VM_UNKNOWN)
                {
                    _break = true;
                    break;
                }
                
                show_debug_message("Chatterbox: Displaying TEXT instruction (" + string(_instruction) + ") from node \"" + _node_title + "\"");
                
                var _text = scribble_create(_instruction_content);
                if (_first_iteration)
                {
                    _first_iteration = false;
                    ds_list_insert(_scribble_list, 0, _text);
                }
                else
                {
                    ds_list_add(_scribble_list, _text);
                }
            break;
            
            case __CHATTERBOX_VM_OPTION:
                show_debug_message("Chatterbox: Displaying OPTION instruction (" + string(_instruction) + ") from node \"" + _node_title + "\"");
                
                var _button = scribble_create(_instruction_content);
                
                if (ds_list_size(_button_list) <= 0)
                {
                    var _primary_text = _scribble_list[| 0];
                    var _y_offset = _primary_text[| __SCRIBBLE.TOP ] + _primary_text[| __SCRIBBLE.HEIGHT ] + 15;
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
            break;
            
            case __CHATTERBOX_VM_STOP:
                if (_previous_instruction_type == __CHATTERBOX_VM_UNKNOWN)
                {
                    show_debug_message("Chatterbox: Executing STOP instruction (" + string(_instruction) + ") from node \"" + _node_title + "\"");
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
        
        if (_break) break;
        
        _instruction++;
        _previous_instruction_type = _instruction_type;
    }
    
    if (_previous_instruction_type == __CHATTERBOX_VM_TEXT)
    {
        var _primary_text = _scribble_list[| 0];
        var _y_offset = _primary_text[| __SCRIBBLE.TOP ] + _primary_text[| __SCRIBBLE.HEIGHT ] + 15;
        var _button = scribble_create("CLICK TO CONTINUE");
        _button[| __SCRIBBLE.LEFT   ] += 10;
        _button[| __SCRIBBLE.TOP    ] += _y_offset;
        _button[| __SCRIBBLE.RIGHT  ] += 10;
        _button[| __SCRIBBLE.BOTTOM ] += _y_offset;
        _button[| __SCRIBBLE.__SIZE ]  = _instruction-1; //Borrow a slot in the Scribble data structure to store the instruction index
        ds_list_add(_button_list, _button);
    }
}