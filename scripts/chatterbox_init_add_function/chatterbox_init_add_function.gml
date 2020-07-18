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
function chatterbox_init_add_function() {

	var _name   = argument[0];
	var _script = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : asset_get_index(_script);

	if (!script_exists(_script))
	{
	    __chatterbox_error("Script (" + string(_script) + ") doesn't exist!");
	    return false;
	}

	if ( !variable_global_exists("__chatterbox_init_complete") )
	{
	    __chatterbox_error("chatterbox_init_add_function() should be called after initialising Chatterbox.");
	    return false;
	}

	if ( !is_string(_name) )
	{
	    __chatterbox_error("Permitted script names should be strings.\n(Input was \"" + string(_name) + "\")");
	    return false;
	}

	if ( !is_real(_script) )
	{
	    __chatterbox_error("Scripts should be numerical script indices e.g. chatterbox_init_add_function(\"name\", your_script);\n(Input was \"" + string(_name) + "\")");
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
	        __chatterbox_error("Action name \"" + _name + "\" is reserved for internal Chatterbox use.\nPlease choose another action name.");
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


}
