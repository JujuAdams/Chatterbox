chatterbox_step(chatterbox);

//Control position and colour of options
var _x_offset = chatterbox_text_get(chatterbox, false, 0, CHATTERBOX_PROPERTY.X)
              + 10;
              
var _y_offset = chatterbox_text_get(chatterbox, false, 0, CHATTERBOX_PROPERTY.Y)
              + chatterbox_text_get(chatterbox, false, 0, CHATTERBOX_PROPERTY.HEIGHT)
              + 10;

var _count = chatterbox_text_get_number(chatterbox, true);
for(var _i = 0; _i < _count; _i++)
{
    var _colour = chatterbox_text_get(chatterbox, true, _i, CHATTERBOX_PROPERTY.HIGHLIGHTED)? c_yellow : c_white;
    chatterbox_text_set(chatterbox, true, _i, CHATTERBOX_PROPERTY.COLOUR, _colour );
    chatterbox_text_set(chatterbox, true, _i, CHATTERBOX_PROPERTY.XY, _x_offset, _y_offset );
    
    _y_offset = chatterbox_text_get(chatterbox, true, _i, CHATTERBOX_PROPERTY.Y)
              + chatterbox_text_get(chatterbox, true, _i, CHATTERBOX_PROPERTY.HEIGHT);
}