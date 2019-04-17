/// @param chatterbox
/// @param offColour
/// @param offAlpha
/// @param onColour
/// @param onAlpha

var _chatterbox = argument0;
var _off_colour = argument1;
var _off_alpha  = argument2;
var _on_colour  = argument3;
var _on_alpha   = argument4;

var _count = chatterbox_text_get_number(_chatterbox, true);
for(var _i = 0; _i < _count; _i++)
{
    var _highlighted = chatterbox_text_get(_chatterbox, true, _i, CHATTERBOX_PROPERTY.HIGHLIGHTED);
    _highlighted = (_highlighted == undefined)? false : _highlighted;
    var _colour = _highlighted? _on_colour : _off_colour;
    var _alpha  = _highlighted? _on_alpha  : _off_alpha;
    
    chatterbox_text_set(_chatterbox, true, _i, CHATTERBOX_PROPERTY.BLEND, _colour);
    chatterbox_text_set(_chatterbox, true, _i, CHATTERBOX_PROPERTY.ALPHA , _alpha);
}