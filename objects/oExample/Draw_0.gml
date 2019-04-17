var _y = 10;

var _text_count = chatterbox_get_child_count(chatterbox, CHATTERBOX_TEXT);
for(var _i = 0; _i < _text_count; _i++)
{
    draw_text(10, _y, chatterbox_get_string(chatterbox, CHATTERBOX_TEXT, _i));
    _y += 20;
}

var _option_count = chatterbox_get_child_count(chatterbox, CHATTERBOX_OPTION);
for(var _i = 0; _i < _option_count; _i++)
{
    draw_text(10, _y, chatterbox_get_string(chatterbox, CHATTERBOX_OPTION, _i));
    _y += 20;
}