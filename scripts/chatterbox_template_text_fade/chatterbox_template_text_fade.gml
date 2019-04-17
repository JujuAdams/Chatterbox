/// @param chatterbox
/// @param inMethod       The fade in method to use
/// @param inSpeed        The speed of the fade in effect
/// @param inSmoothness   The smoothness of the fade in effect
/// @param outMethod      The fade out method to use
/// @param outSpeed       The speed of the fade out effect
/// @param outSmoothness  The smoothness of the fade out effect

var _chatterbox = argument0;
_chatterbox[| __CHATTERBOX.TEXT_FADE_IN_METHOD      ] = argument1;
_chatterbox[| __CHATTERBOX.TEXT_FADE_IN_SPEED       ] = argument2;
_chatterbox[| __CHATTERBOX.TEXT_FADE_IN_SMOOTHNESS  ] = argument3;
_chatterbox[| __CHATTERBOX.TEXT_FADE_OUT_METHOD     ] = argument4;
_chatterbox[| __CHATTERBOX.TEXT_FADE_OUT_SPEED      ] = argument5;
_chatterbox[| __CHATTERBOX.TEXT_FADE_OUT_SMOOTHNESS ] = argument6;
return true;