ChatterboxAddFunction("testcaseStop", TestCaseStopFunction);

function TestCaseStopFunction(_a, _b, _c, _d, _e, _f)
{
    show_debug_message("Called TestCaseStopFunction()");
    ChatterboxStop(CHATTERBOX_CURRENT);
}