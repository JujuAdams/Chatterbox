/// Add a custom action definition and binds it to a script call
/// 
/// Custom actions can be added to Chatterbox by using the chatterbox_init_add_action() script. Custom actions must be added after calling
/// chatterbox_init_start() and before calling chatterbox_init_end(). Custom action names cannot contain spaces or commas.
/// 
///     GML:    chatterbox_init_start("Yarn");
///             chatterbox_init_add_action("playMusic", play_background_music);
///             chatterbox_init_add_json("example.json");
///             chatterbox_init_end();
/// 
///     Yarn:   Here's some text!
///             <<playMusic>>
///             The music will have started now.
/// 
/// By adding the custom action "playMusic" and binding it to the script play_background_music(), Chatterbox will now call this script
/// whenever <<playMusic>> is processed by Chatterbox.
/// 
/// Custom actions can also have parameters. These parameters can be any Chatterbox value - a real number, a string, or a variable.
/// Parameters should separated by spaces. Parameters are passed into a script as an array of values in argument0.
/// 
///     GML:    chatterbox_init_start("Yarn");
///             chatterbox_init_add_action("gotoRoom", go_to_room);
///             chatterbox_init_add_json("example.json");
///             chatterbox_init_end();
/// 
///     Yarn:   Let's go see what the priest is up to.
///             <<gotoRoom "rChapel" $entrance>>
///             <<stop>>
/// 
/// Chatterbox will execute the script go_to_room() whenever <<gotoRoom>> is processed. In this case, go_to_room() will receive an array
/// of two values from Chatterbox. The first (index 0) element of the array will be "rChapel" and the second (index 1) element will
/// hold whatever value is in the "$entrance" variable.
/// 
/// @param name       Action name, as a string
/// @param function   Function to call

function chatterbox_add_action(_name, _function)
{
	if (!is_string(_name))
	{
	    __chatterbox_error("Action names should be strings.\n(Input to script was \"", _name, "\")");
	    return false;
	}
    
	if (!is_method(_function))
	{
	    __chatterbox_error("Scripts should be numerical script indices e.g. chatterbox_add_action(\"example\", your_script);\n(Input to script was \"", _name, "\")");
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
	        __chatterbox_error("Action name \"", _name, "\" is reserved for internal Chatterbox use.\nPlease choose another action name.");
	        return false;
	    break;
	}
    
	var _old_script = global.__chatterbox_actions[? _name];
	if (is_method(_old_script))
	{
	    __chatterbox_trace("WARNING! Overwriting action \"", _name, "\" tied to function \"", _function, "()\"" );
	}
    
	global.__chatterbox_actions[? _name] = _function;
	__chatterbox_trace("Tying action \"", _name, "\" to function \"", _function, "()\"" );
	return true;
}