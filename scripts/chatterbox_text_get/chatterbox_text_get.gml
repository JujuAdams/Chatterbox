/// @param chatterbox
/// @param isOption
/// @param index
/// @param property

var _chatterbox = argument0;
var _is_option  = argument1;
var _index      = argument2;
var _property   = argument3;

var _list = _chatterbox[| _is_option? __CHATTERBOX.OPTION_LIST : __CHATTERBOX.TEXT_LIST ];

var _array = _list[| _index ];
if (_property == CHATTERBOX_PROPERTY.XY)
{
    if (_index < 0) || (_index >= ds_list_size(_list)) return [0, 0];
    return [_array[ CHATTERBOX_PROPERTY.X ], _array[ CHATTERBOX_PROPERTY.Y ]];
}
else if (_property == CHATTERBOX_PROPERTY.XY_SCALE)
{
    if (_index < 0) || (_index >= ds_list_size(_list)) return [0, 0];
    return [_array[ CHATTERBOX_PROPERTY.XSCALE ], _array[ CHATTERBOX_PROPERTY.YSCALE ]];
}
else if (_property == CHATTERBOX_PROPERTY.HIGHLIGHTED)
{
    if (_index < 0) || (_index >= ds_list_size(_list)) return false;
    return (_index == _chatterbox[| __CHATTERBOX.HIGHLIGHTED ]);
}
else if (_property == CHATTERBOX_PROPERTY.WIDTH   )
     || (_property == CHATTERBOX_PROPERTY.HEIGHT  )
     || (_property == CHATTERBOX_PROPERTY.SCRIBBLE)
{
    if (_index < 0) || (_index >= ds_list_size(_list))
    {
        return (_property == CHATTERBOX_PROPERTY.SCRIBBLE)? undefined : 0;
    }
    
    var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
    
    if ( !is_real(_scribble) || !ds_exists(_scribble, ds_type_list) )
    {
        return (_property == CHATTERBOX_PROPERTY.SCRIBBLE)? undefined : 0;
    }
    
    if (_property == CHATTERBOX_PROPERTY.SCRIBBLE) return _scribble;
    if (_property == CHATTERBOX_PROPERTY.WIDTH   ) return _scribble[| __SCRIBBLE.WIDTH  ];
    if (_property == CHATTERBOX_PROPERTY.HEIGHT  ) return _scribble[| __SCRIBBLE.HEIGHT ];
}
else
{
    if (_index < 0) || (_index >= ds_list_size(_list)) return 0;
    return _array[ _property ];
}