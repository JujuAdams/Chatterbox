/// @param chatterbox
/// @param isButton
/// @param index
/// @param property

var _chatterbox = argument0;
var _is_button  = argument1;
var _index      = argument2;
var _property   = argument3;

var _meta_list = _chatterbox[| _is_button? __CHATTERBOX.BUTTONS_META : __CHATTERBOX.TEXTS_META ];
if (_index < 0) || (_index >= ds_list_size(_meta_list)) return undefined;

var _array = _meta_list[| _index ];
if (_property == CHATTERBOX_PROPERTY.XY)
{
    return [_array[@ CHATTERBOX_PROPERTY.X ], _array[@ CHATTERBOX_PROPERTY.Y ]];
}
else if (_property == CHATTERBOX_PROPERTY.XY_SCALE)
{
    return [_array[@ CHATTERBOX_PROPERTY.XSCALE ], _array[@ CHATTERBOX_PROPERTY.YSCALE ]];
}
else if (_property == CHATTERBOX_PROPERTY.HIGHLIGHTED)
{
    return (_index == _chatterbox[| __CHATTERBOX.HIGHLIGHTED ]);
}
else if (_property == CHATTERBOX_PROPERTY.WIDTH   )
     || (_property == CHATTERBOX_PROPERTY.HEIGHT  )
     || (_property == CHATTERBOX_PROPERTY.SCRIBBLE)
{
    if (_is_button)
    {
        var _list = _chatterbox[| __CHATTERBOX.BUTTONS ];
        if (_index >= ds_list_size(_list)) return 0;
        var _button_array = _list[| _index ];
        var _scribble = _button_array[ __CHATTERBOX_BUTTON.TEXT ];
    }
    else
    {
        var _list = _chatterbox[| __CHATTERBOX.TEXTS ];
        if (_index >= ds_list_size(_list)) return 0;
        var _scribble = _list[| _index ];
    }
    
    if (_property == CHATTERBOX_PROPERTY.SCRIBBLE )
    {
        return (!is_real(_scribble) || !ds_exists(_scribble, ds_type_list))? undefined : _scribble;
    }
    
    if ( !is_real(_scribble) || !ds_exists(_scribble, ds_type_list) ) return 0;
    
    if (_property == CHATTERBOX_PROPERTY.WIDTH ) return _scribble[| __SCRIBBLE.WIDTH  ];
    if (_property == CHATTERBOX_PROPERTY.HEIGHT) return _scribble[| __SCRIBBLE.HEIGHT ];
}
else
{
    return _array[ _property ];
}