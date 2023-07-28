// Feather disable all
/// Returns an array of structs containing data for each option string in a chatterbox
/// 
/// THe array is populated in canonical order: the 0th element of the array is equivalent to ChatterboxGetOption(chatterbox, 0) etc.
/// 
/// Each struct has this format:
/// {
///     text: <option string>,
///     conditionBool: <whether the conditional check for this option passed or failed>,
///     metadata: <metadata for the string>,
/// }
/// 
/// @param chatterbox

function ChatterboxGetOptionArray(_chatterbox)
{
    if (!IsChatterbox(_chatterbox)) return undefined;
    return _chatterbox.GetOptionArray();
}
