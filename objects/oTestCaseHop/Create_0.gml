if (!CHATTERBOX_END_OF_NODE_HOPBACK)
{
    __ChatterboxError("CHATTERBOX_END_OF_NODE_HOPBACK must be set to <true> for this test case");
}

ChatterboxLoadFromFile("testcase_hop.yarn");
ChatterboxLoadFromFile("testcase_hop_2.yarn");

box = ChatterboxCreate("testcase_hop.yarn");
ChatterboxJump(box, "Start");