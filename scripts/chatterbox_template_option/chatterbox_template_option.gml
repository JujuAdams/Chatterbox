/// @param chatterbox
/// @param minLineHeight     The minimum line height for each line of text. Defaults to the height of a space character of the default font
/// @param maxLineWidth      The maximum line width for each line of text. Use a negative number for no limit. Defaults to no limit
/// @param startingColour    The (initial) blend colour for the text. Defaults to white
/// @param startingFont      The (initial) font for the text. The font name should be provided as a string. Defaults to Scribble's global default font (the first font added during initialisation)
/// @param startingHAlign    The (initial) horizontal alignment for the test. Defaults to left justified
/// @param dataFieldsArray   The data field array that'll be passed into the shader to control various effects. Defaults to values set in __scribble_config()

var _chatterbox = argument0;
_chatterbox[| __CHATTERBOX.OPTION_MIN_LINE_HEIGHT ] = argument1;
_chatterbox[| __CHATTERBOX.OPTION_MAX_LINE_WIDTH  ] = argument2;
_chatterbox[| __CHATTERBOX.OPTION_STARTING_COLOUR ] = argument3;
_chatterbox[| __CHATTERBOX.OPTION_STARTING_FONT   ] = argument4;
_chatterbox[| __CHATTERBOX.OPTION_STARTING_HALIGN ] = argument5;
_chatterbox[| __CHATTERBOX.OPTION_DATA_FIELDS     ] = argument6;
return true;