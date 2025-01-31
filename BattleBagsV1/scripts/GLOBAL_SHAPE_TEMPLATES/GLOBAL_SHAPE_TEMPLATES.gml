

function global_shape_function_init()
{
	// ------------------------------------------------------
	// Shape Templates (Stored in DS Map)
	// ------------------------------------------------------
	global.shape_templates = ds_map_create();
	ds_map_add(global.shape_templates, "single_1x1", [
		[BLOCK.RANDOM]
	]);
	
	ds_map_add(global.shape_templates, "h_1x2", [
		[BLOCK.RANDOM, BLOCK.RANDOM]
	]);
	ds_map_add(global.shape_templates, "h_2x1", [
		[BLOCK.RANDOM],
		[BLOCK.RANDOM]
	]);

	ds_map_add(global.shape_templates, "blank_3x3", [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	]);
	
	ds_map_add(global.shape_templates, "triangle_down_3x3", [
		[BLOCK.BLACK, BLOCK.RANDOM, BLOCK.RANDOM, BLOCK.RANDOM, BLOCK.BLACK],
		[BLOCK.NONE,   BLOCK.BLACK, BLOCK.RANDOM, BLOCK.BLACK, BLOCK.NONE],
		[BLOCK.NONE,   BLOCK.NONE,   BLOCK.BLACK, BLOCK.NONE,   BLOCK.NONE]
	]);

	ds_map_add(global.shape_templates, "square_3x3", [
	    [BLOCK.RANDOM, BLOCK.RANDOM, BLOCK.RANDOM],
	    [BLOCK.RANDOM, BLOCK.RANDOM, BLOCK.RANDOM],
	    [BLOCK.RANDOM, BLOCK.RANDOM, BLOCK.RANDOM]
	]);
	ds_map_add(global.shape_templates, "line_1x3", [
	    [BLOCK.RANDOM, BLOCK.RANDOM, BLOCK.RANDOM]
	]);
	ds_map_add(global.shape_templates, "block_2x3", [
	    [BLOCK.RANDOM, BLOCK.RANDOM, BLOCK.RANDOM],
	    [BLOCK.RANDOM, BLOCK.RANDOM, BLOCK.RANDOM]
	]);
	ds_map_add(global.shape_templates, "cross", [
	    [BLOCK.NONE, BLOCK.RANDOM, BLOCK.NONE],
	    [BLOCK.RANDOM, BLOCK.RANDOM, BLOCK.RANDOM],
	    [BLOCK.NONE, BLOCK.RANDOM, BLOCK.NONE]
	]);
	ds_map_add(global.shape_templates, "x_shape", [
	    [BLOCK.RANDOM, BLOCK.NONE, BLOCK.RANDOM],
	    [BLOCK.NONE, BLOCK.RANDOM, BLOCK.NONE],
	    [BLOCK.RANDOM, BLOCK.NONE, BLOCK.RANDOM]
	]);
}