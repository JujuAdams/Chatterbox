/// @param chatterbox

var _chatterbox = argument0;

if (_chatterbox[| __CHATTERBOX.TITLE ] == undefined) return CHATTERBOX_STATE_STOPPED;
if (_chatterbox[| __CHATTERBOX.SUSPENDED ]) return CHATTERBOX_STATE_SUSPENDED;
return CHATTERBOX_STATE_RUNNING;