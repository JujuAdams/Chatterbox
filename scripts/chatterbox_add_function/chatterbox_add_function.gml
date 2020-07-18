/// Adds a custom function that can be called by expressions
/// 
/// Much like custom actions, custom functions can have parameters. Custom functions can be added at any
/// point but should be added before loading in any source files
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
/// @param name        Script name, as a string
/// @param [function]  Function to call

function chatterbox_add_function(_name, _function)
{
	if (!is_string(_name))
	{
	    __chatterbox_error("Function names should be strings\n(Input was \"", _name, "\")");
	    return false;
	}
    
	if (!is_method(_function))
	{
	    __chatterbox_error("Function supplied is invalid\n(Input was \"", _name, "\")");
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
	        __chatterbox_error("Function name \"", _name, "\" is reserved for internal Chatterbox use.\nPlease choose another action name.");
	        return false;
	    break;
	}
    
	var _old_function = global.__chatterbox_permitted_functions[? _name];
	if (is_method(_old_function))
	{
	    __chatterbox_trace("WARNING! Overwriting script name \"", _name, "\" tied to \"", _old_function, "()\"" );
	}
    
	global.__chatterbox_permitted_functions[? _name ] = _function;
	__chatterbox_trace("Permitting script \"", _name, "\", calling \"", _function, "()\"" );
	return true;
}