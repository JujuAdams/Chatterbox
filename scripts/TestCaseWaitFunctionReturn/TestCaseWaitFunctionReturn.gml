ChatterboxAddFunction("testcaseWaitReturn", TestCaseWaitFunctionReturn);

function TestCaseWaitFunctionReturn(_a, _b, _c, _d, _e, _f)
{
    show_debug_message("Called TestCaseWaitFunctionReturn()");
    return "<<wait>>";
}