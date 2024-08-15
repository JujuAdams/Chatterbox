// Feather disable all
/// Loads a Yarn source for use with Chatterbox directly from a buffer (formatted as either a .yarn or .json file)
///
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax()
///
/// @param aliasName  Alias to use for this buffer (effectively a fake filename)
/// @param buffer     Buffer to read

function ChatterboxLoadFromBuffer(_aliasName, _buffer)
{
    static _system = __ChatterboxSystem();
    
    _aliasName = __ChatterboxReplaceBackslashes(_aliasName);
    
    if (CHATTERBOX_REPLACE_ALIAS_BACKSLASHES)
    {
        _aliasName = string_replace_all(_aliasName, "\\", "/");
    }
    
    if (ChatterboxIsLoaded(_aliasName))
    {
        //Unload what we have already if needed
        //This will invalidate any chatterboxes that currently exist and are using the file
        ChatterboxUnload(_aliasName);
    }
    
    //Set our default file if we don't already have one
    if (_system.__defaultFile == "") _system.__defaultFile = _aliasName;
    
    //Create a struct that represents this source
    var _source = new __ChatterboxClassSource(_aliasName, _buffer, true);
    
    //If we successfully decoded a buffer add it to our collection of chatterboxes
    if ((instanceof(_source) == "__ChatterboxClassSource") && _source.loaded)
    {
        _system.__files[? _aliasName] = _source;
    }
}
