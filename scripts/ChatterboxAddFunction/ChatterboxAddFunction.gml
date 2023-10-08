// Feather disable all
/// Adds a custom function that can be called by expressions
/// 
/// Custom functions can return values, but they should be numbers or strings.
/// 
///     GML:    ChatterboxLoadFromFile("example.json");
///             ChatterboxAddFunction("AmIDead", am_i_dead);
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
/// Parameters for custom functions executed by Yarn script should be separated by spaces. The parameters
/// are passed into the given function as an array of values as argument0.
/// 
/// Custom functions can be added at any point but should be added before loading in any source files.
/// 
/// @param name      Script name; as a string
/// @param function  Function to call

function ChatterboxAddFunction(_name, _in_function)
{
    var _function = _in_function;
    
    if (!is_string(_name))
    {
        __ChatterboxError("Function names should be strings\n(Input was \"", _name, "\")");
        return false;
    }
    
    if (CHATTERBOX_ALLOW_SCRIPTS && is_numeric(_function) && script_exists(_function))
    {
        if (CHATTERBOX_VERBOSE) __ChatterboxTrace("Function provided for \"", _name, "\" was a script index (", _function, "=", script_get_name(_function), "), binding to <undefined> scope");
        _function = method(undefined, _function);
    }
    else if (!is_method(_function))
    {
        __ChatterboxError("Function/method supplied for \"", _name, "\" is invalid (", _in_function, ")");
        return false;
    }
    
    switch(_name)
    {
        case "if":
        case "else":
        case "elseif":
        case "else if":
        case "end":
        case "endif":
        case "end if":
        case "declare":
        case "constant":
        case "set":
        case "jump":
        case "stop":
        case "wait":
        case "fastforward":
        case "fastmark":
        case "forcewait":
        case "hop":
        case "hopback":
        case "visited":
        case "optionChosen":
            __ChatterboxError("Function name \"", _name, "\" is reserved for internal Chatterbox use.\nPlease choose another action name.");
            return false;
        break;
    }
    
    if (!variable_global_exists("__chatterboxFunctions"))
    {
        global.__chatterboxFunctions = ds_map_create();
    }
    
    var _old_function = global.__chatterboxFunctions[? _name];
    if (is_method(_old_function))
    {
        __ChatterboxTrace("WARNING! Overwriting script name \"", _name, "\" tied to \"", _old_function, "()\"" );
    }
    
    global.__chatterboxFunctions[? _name ] = _function;
    if (CHATTERBOX_VERBOSE) __ChatterboxTrace("Permitting script \"", _name, "\", calling \"", _function, "()\"" );
    return true;
}
