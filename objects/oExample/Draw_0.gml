if (chatterbox_get_state(chatterbox))
{
    chatterbox_draw(chatterbox);
    draw_text(410, 10, "Running");
}

draw_text(10, 200, chatterbox_variable_array(chatterbox, true));