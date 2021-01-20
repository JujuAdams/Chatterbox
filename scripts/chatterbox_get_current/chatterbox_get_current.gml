/// Returns the title of the current node of the given chatterbox
///
/// @param chatterbox

function chatterbox_get_current(_chatterbox)
{
    if (!is_chatterbox(_chatterbox)) return undefined;
    _chatterbox.verify_is_loaded();
	return _chatterbox.current_node.title;
}