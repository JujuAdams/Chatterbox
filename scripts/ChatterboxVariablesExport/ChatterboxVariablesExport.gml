/// Returns a string that represents the names and values of all Chatterbox variables

function ChatterboxVariablesExport()
{
    return json_encode(global.chatterboxVariablesMap);
}