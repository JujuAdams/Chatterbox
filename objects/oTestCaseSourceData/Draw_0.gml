var _source = ChatterboxGetCurrentSource(box);

draw_set_font(fntDefault);

draw_text(10,  10, "Source = \"" + _source + "\"");
draw_text(10, 110, "Node Count = " + string(ChatterboxSourceNodeCount(_source)));
draw_text(10, 210, "Node \"Start\" Exists = " + string(ChatterboxSourceNodeExists(_source, "Start")));
draw_text(10, 310, "Node \"Missing\" Exists = " + string(ChatterboxSourceNodeExists(_source, "Missing")));