// Feather disable all
/// Returns an array of structs containing data for each content string in a chatterbox
/// 
/// THe array is populated in canonical order: the 0th element of the array is equivalent to ChatterboxGetContent(chatterbox, 0) etc.
/// 
/// Each struct has this format:
/// {
///     text: <content string>,
///     metadata: <metadata for the string>
/// }
/// 
/// @param chatterbox

function ChatterboxGetContentArray(_chatterbox)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.GetContentArray();
}
