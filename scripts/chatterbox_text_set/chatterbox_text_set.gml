/// @param chatterbox
/// @param isOption
/// @param index
/// @param property
/// @param value
/// @param [value]

var _chatterbox = argument[0];
var _is_option  = argument[1];
var _index      = argument[2];
var _property   = argument[3];
var _value      = argument[4];
var _value_2    = (argument_count > 5)? argument[5] : undefined;

switch(_property)
{
    case CHATTERBOX_PROPERTY.WIDTH:
        show_error("Chatterbox:\nCHATTERBOX_COMPONENT.WIDTH is a read-only property.\n ", false);
        return false;
    break;
    
    case CHATTERBOX_PROPERTY.HEIGHT:
        show_error("Chatterbox:\nCHATTERBOX_COMPONENT.HEIGHT is a read-only property.\n ", false);
        return false;
    break;
    
    case CHATTERBOX_PROPERTY.SCRIBBLE:
        show_error("Chatterbox:\nCHATTERBOX_COMPONENT.SCRIBBLE is a read-only property.\n ", false);
        return false;
    break;
    
    case CHATTERBOX_PROPERTY.HIGHLIGHTED:
        show_error("Chatterbox:\nCHATTERBOX_COMPONENT.HIGHLIGHTED is a read-only property.\n ", false);
        return false;
    break;
}

if (_is_option)
{
    var _list = _chatterbox[| __CHATTERBOX.OPTION_LIST ];
    
    #region Fill in gaps if we're modifying an index larger than what we already have
    
    var _count = ds_list_size(_list);
    repeat (1 + _index - _count)
    {
        var _new_array = array_create(CHATTERBOX_PROPERTY.__SIZE);
        _new_array[@ CHATTERBOX_PROPERTY.X              ] = 0;
        _new_array[@ CHATTERBOX_PROPERTY.Y              ] = 0;
        _new_array[@ CHATTERBOX_PROPERTY.XY             ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.XSCALE         ] = CHATTERBOX_OPTION_DRAW_DEFAULT_XSCALE;
        _new_array[@ CHATTERBOX_PROPERTY.YSCALE         ] = CHATTERBOX_OPTION_DRAW_DEFAULT_YSCALE;
        _new_array[@ CHATTERBOX_PROPERTY.XY_SCALE       ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.ANGLE          ] = CHATTERBOX_OPTION_DRAW_DEFAULT_ANGLE;
        _new_array[@ CHATTERBOX_PROPERTY.BLEND          ] = CHATTERBOX_OPTION_DRAW_DEFAULT_BLEND;
        _new_array[@ CHATTERBOX_PROPERTY.ALPHA          ] = CHATTERBOX_OPTION_DRAW_DEFAULT_ALPHA;
        _new_array[@ CHATTERBOX_PROPERTY.PMA            ] = CHATTERBOX_OPTION_DRAW_DEFAULT_PMA;
        _new_array[@ CHATTERBOX_PROPERTY.MAX_WIDTH      ] = CHATTERBOX_OPTION_DRAW_DEFAULT_MAX_WIDTH;
        _new_array[@ CHATTERBOX_PROPERTY.HIGHLIGHTABLE  ] = true;
        _new_array[@ CHATTERBOX_PROPERTY.SELECTABLE     ] = true;
        _new_array[@ CHATTERBOX_PROPERTY.__SECTION0     ] = "-- Read-Only Properties --";
        _new_array[@ CHATTERBOX_PROPERTY.ITERATION      ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.WIDTH          ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.HEIGHT         ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.SCRIBBLE       ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.HIGHLIGHTED    ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.__INSTRUCTION0 ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.__INSTRUCTION1 ] = undefined;
        ds_list_add(_list, _new_array);
    }
    
    #endregion
    
}
else
{
    var _list = _chatterbox[| __CHATTERBOX.TEXT_LIST ];
    
    #region Fill in gaps if we're modifying an index larger than what we already have
    
    var _count = ds_list_size(_list);
    repeat(1 + _index - _count)
    {
        var _new_array = array_create(CHATTERBOX_PROPERTY.__SIZE);
        _new_array[@ CHATTERBOX_PROPERTY.X              ] = 0;
        _new_array[@ CHATTERBOX_PROPERTY.Y              ] = 0;
        _new_array[@ CHATTERBOX_PROPERTY.XY             ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.XSCALE         ] = CHATTERBOX_TEXT_DRAW_DEFAULT_XSCALE;
        _new_array[@ CHATTERBOX_PROPERTY.YSCALE         ] = CHATTERBOX_TEXT_DRAW_DEFAULT_YSCALE;
        _new_array[@ CHATTERBOX_PROPERTY.XY_SCALE       ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.ANGLE          ] = CHATTERBOX_TEXT_DRAW_DEFAULT_ANGLE;
        _new_array[@ CHATTERBOX_PROPERTY.BLEND          ] = CHATTERBOX_TEXT_DRAW_DEFAULT_BLEND;
        _new_array[@ CHATTERBOX_PROPERTY.ALPHA          ] = CHATTERBOX_TEXT_DRAW_DEFAULT_ALPHA;
        _new_array[@ CHATTERBOX_PROPERTY.PMA            ] = CHATTERBOX_TEXT_DRAW_DEFAULT_PMA;
        _new_array[@ CHATTERBOX_PROPERTY.MAX_WIDTH      ] = CHATTERBOX_TEXT_DRAW_DEFAULT_MAX_WIDTH;
        _new_array[@ CHATTERBOX_PROPERTY.HIGHLIGHTABLE  ] = true;
        _new_array[@ CHATTERBOX_PROPERTY.SELECTABLE     ] = true;
        _new_array[@ CHATTERBOX_PROPERTY.__SECTION0     ] = "-- Read-Only Properties --";
        _new_array[@ CHATTERBOX_PROPERTY.ITERATION      ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.WIDTH          ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.HEIGHT         ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.SCRIBBLE       ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.HIGHLIGHTED    ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.__INSTRUCTION0 ] = undefined;
        _new_array[@ CHATTERBOX_PROPERTY.__INSTRUCTION1 ] = undefined;
        ds_list_add(_list, _new_array);
    }
    
    #endregion
    
}

var _array = _list[| _index ];
if (_property == CHATTERBOX_PROPERTY.XY)
{
    _array[@ CHATTERBOX_PROPERTY.X ] = _value;
    _array[@ CHATTERBOX_PROPERTY.Y ] = _value_2;
}
else if (_property == CHATTERBOX_PROPERTY.XY_SCALE)
{
    _array[@ CHATTERBOX_PROPERTY.XSCALE ] = _value;
    _array[@ CHATTERBOX_PROPERTY.YSCALE ] = _value_2;
}
else
{
    _array[@ _property ] = _value;
}

return true;