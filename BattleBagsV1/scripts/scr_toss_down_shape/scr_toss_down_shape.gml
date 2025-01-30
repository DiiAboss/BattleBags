function toss_down_shape(_self, shape_name) {
    var width = _self.width;
    var height = _self.height;
    var gem_size = _self.gem_size;

    // ✅ Use ds_map_find_value() to get the shape template
    var shape = ds_map_find_value(global.shape_templates, shape_name);

    if (shape == undefined) return; // ✅ Prevent errors if shape not found

    var shape_width = array_length(shape[0]);
    var shape_height = array_length(shape);

    // ✅ Choose a **random starting X position** (ensure it fits)
    var start_x = irandom_range(0, width - shape_width);

    // ✅ Place shape into the grid at row 0
    for (var j = 0; j < shape_height; j++) {
        for (var i = 0; i < shape_width; i++) {
            if (shape[j][i] == 1) { // ✅ Only place gems where `1` exists
                var gem_x = start_x + i;
                var gem_y = j;

                if (gem_x >= 0 && gem_x < width && gem_y >= 0 && gem_y < height) {
                    var new_gem = create_gem(irandom_range(0, _self.numberOfGemTypes - 1));
                    _self.grid[gem_x, gem_y] = new_gem;
                    _self.gem_y_offsets[gem_x, gem_y] = -gem_size * 2; // Start above
                    _self.grid[gem_x, gem_y].falling = true;
                    _self.grid[gem_x, gem_y].fall_delay = 0; // **No delay before falling**
                }
            }
        }
    }

    // ✅ Force a secondary drop pass **to process falling blocks**
    for (var i = 0; i < 3; i++) { // Run multiple passes to prevent a hang
        drop_blocks(_self);
    }
}