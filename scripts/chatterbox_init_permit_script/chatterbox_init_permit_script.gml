/// @param name      Script name, as a string
/// @param [script]  Numerical script index e.g. your_script

var _name   = argument[0];
var _script = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : asset_get_index(_script);

if (!script_exists(_script))
{
    show_error("Chatterbox:\nScript (" + string(_script) + ") doesn't exist!\n ", false);
    return false;
}

if ( !variable_global_exists("__chatterbox_init_complete") )
{
    show_error("Chatterbox:\nchatterbox_init_permit_script() should be called after initialising Chatterbox.\n ", false);
    return false;
}

if ( !is_string(_name) )
{
    show_error("Chatterbox:\nPermitted script names should be strings.\n(Input was \"" + string(_name) + "\")\n ", false);
    return false;
}

if ( !is_real(_script) )
{
    show_error("Chatterbox:\nScripts should be numerical script indices e.g. chatterbox_init_permit_script(\"name\", your_script);\n(Input was \"" + string(_name) + "\")\n ", false);
    return false;
}

switch(_name)
{
    case "if":
    case "else":
    case "elseif":
    case "end":
    case "set":
    case "stop":
    case "wait":
        show_error("Chatterbox:\nAction name \"" + _name + "\" is reserved for internal Chatterbox use.\nPlease choose another action name.\n ", false);
        return false;
    break;
}

var _old_script = global.__chatterbox_permitted_scripts[? _name ];
if ( is_real(_old_script) )
{
    show_debug_message("Chatterbox: WARNING! Overwriting script name \"" + _name + "\" tied to \"" + script_get_name(_old_script) + "()\"" );
}

global.__chatterbox_permitted_scripts[? _name ] = _script;
show_debug_message("Chatterbox: Permitting script \"" + _name + "\", calling \"" + script_get_name(_script) + "()\"" );
return true;