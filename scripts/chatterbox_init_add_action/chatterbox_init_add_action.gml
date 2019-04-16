/// @param name     Action name, as a string
/// @param script   Numerical script index e.g. your_script

var _name   = argument0;
var _script = argument1;

if ( !variable_global_exists("__chatterbox_init_complete") )
{
    show_error("Chatterbox:\nchatterbox_add_action() should be called after initialising Chatterbox.\n ", false);
    return false;
}

if (global.__chatterbox_init_complete)
{
    show_error("Chatterbox:\nchatterbox_init_add_action() should be called before chatterbox_init_end()\n ", true);
    return false;
}

if ( !is_string(_name) )
{
    show_error("Chatterbox:\nAction names should be strings.\n(Input to script was \"" + string(_name) + "\")\n ", false);
    return false;
}

if ( !is_real(_script) )
{
    show_error("Chatterbox:\nScripts should be numerical script indices e.g. chatterbox_add_action(\"example\", your_script);\n(Input to script was \"" + string(_name) + "\")\n ", false);
    return false;
}

if ( !script_exists(_script) )
{
    show_error("Chatterbox:\nScript (" + string(_script) + ") doesn't exist!\n ", false);
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
    case "suspend":
    case "wait":
        show_error("Chatterbox:\nAction name \"" + _name + "\" is reserved for internal Chatterbox use.\nPlease choose another action name.\n ", false);
        return false;
    break;
}

var _old_script = global.__chatterbox_actions[? _name ];
if ( is_real(_old_script) )
{
    show_debug_message("Chatterbox: WARNING! Overwriting action \"" + _name + "\" tied to script \"" + script_get_name(_old_script) + "()\"" );
}

global.__chatterbox_actions[? _name ] = _script;
show_debug_message("Chatterbox: Tying action \"" + _name + "\" to script \"" + script_get_name(_script) + "()\"" );
return true;