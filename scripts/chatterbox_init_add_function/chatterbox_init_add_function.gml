/// Adds a custom function that can be called by expressions
/// 
/// Much like custom actions, custom functions can have parameters. Custom functions can be added at any
/// point, after calling chatterbox_init_start(), but should be added before using chatterbox_goto() or
/// chatterbox_select().
/// 
/// Parameters should be separated by spaces and are passed into a script as an array of values in argument0.
/// Custom functions can return values, but they should be reals or strings.
/// 
///     GML:    chatterbox_init_start("Yarn");
///             chatterbox_init_add_function("AmIDead", am_i_dead);
///             chatterbox_init_add_json("example.json");
///             chatterbox_init_end();
/// 
///     Yarn:   Am I dead?
///             <<if AmIDead("player")>>
///                 Yup. Definitely dead.
///             <<else>>
///                 No, not yet!
///             <<endif>>
/// 
/// This example shows how the script am_i_dead() is called by Chatterbox in an if statement. The value
/// returned from am_i_dead() determines which text is displayed.
/// 
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
    show_error("Chatterbox:\nchatterbox_init_add_function() should be called after initialising Chatterbox.\n ", false);
    return false;
}

if ( !is_string(_name) )
{
    show_error("Chatterbox:\nPermitted script names should be strings.\n(Input was \"" + string(_name) + "\")\n ", false);
    return false;
}

if ( !is_real(_script) )
{
    show_error("Chatterbox:\nScripts should be numerical script indices e.g. chatterbox_init_add_function(\"name\", your_script);\n(Input was \"" + string(_name) + "\")\n ", false);
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
    case "visited":
        show_error("Chatterbox:\nAction name \"" + _name + "\" is reserved for internal Chatterbox use.\nPlease choose another action name.\n ", false);
        return false;
    break;
}

var _old_script = global.__chatterbox_permitted_scripts[? _name ];
if ( is_real(_old_script) )
{
    __chatterbox_trace("WARNING! Overwriting script name \"" + _name + "\" tied to \"" + script_get_name(_old_script) + "()\"" );
}

global.__chatterbox_permitted_scripts[? _name ] = _script;
__chatterbox_trace("Permitting script \"" + _name + "\", calling \"" + script_get_name(_script) + "()\"" );
return true;