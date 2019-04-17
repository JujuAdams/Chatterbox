/// @param chatter
/// @param up
/// @param down

var _chatterbox = argument0;
var _up         = argument1;
var _down       = argument2;

var _highlighted_index = _chatterbox[| __CHATTERBOX.HIGHLIGHTED ];
var _option_list       = _chatterbox[| __CHATTERBOX.OPTION_LIST ];

if (_highlighted_index != undefined)
{
    if (_up)   _highlighted_index--;
    if (_down) _highlighted_index++;
    
    _highlighted_index = clamp(_highlighted_index, 0, ds_list_size(_option_list)-1);
    _chatterbox[| __CHATTERBOX.HIGHLIGHTED ] = _highlighted_index;
}