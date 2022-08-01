ChatterboxAddFunction("testcaseActionArguments", TestCaseActionFunctionArguments);

function TestCaseActionFunctionArguments()
{
    show_debug_message("This has " + string(argument_count) + " arguments!");
    var _array = array_create(argument_count);
    var _i = 0;
    repeat(argument_count) {
        _array[_i] = argument[_i];
        ++_i;
    }
    show_debug_message(_array);
}