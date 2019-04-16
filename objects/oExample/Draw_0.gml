draw_text(10, 200, chatterbox_variable_array(chatterbox, true));

if (chatterbox_get_state(chatterbox))
{
    chatterbox_draw(chatterbox, 110, 110, 1, 1, current_time/20);
    draw_text(410, 10, "Running");
}