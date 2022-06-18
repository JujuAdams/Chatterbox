ChatterboxAddFunction("testcaseWait", TestCaseWaitFunction);

function TestCaseWaitFunction(_a, _b, _c, _d, _e, _f)
{
    show_debug_message("Called TestCaseWaitFunction()");
    ChatterboxWait(CHATTERBOX_CURRENT);
}