ChatterboxLoadFromFile("testcase_parsers.yarn");
box = ChatterboxCreate();
ChatterboxJump(box, "Start");

speaker = "";
speech = "";
color = c_white;	//This will be changed by the speaker's data, if any has been set.
					//This can be used in a variety of ways that go beyond colors,
					//like image indexes, enum values, array positions, and more.
