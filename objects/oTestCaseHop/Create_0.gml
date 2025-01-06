if (!CHATTERBOX_END_OF_NODE_HOPBACK)
{
    __ChatterboxError("CHATTERBOX_END_OF_NODE_HOPBACK must be set to <true> for this test case");
}

ChatterboxLoadFromFile("testcase_hop.chatter");
ChatterboxLoadFromFile("testcase_hop_2.chatter");

box = ChatterboxCreate("testcase_hop.chatter");
ChatterboxJump(box, "Start");