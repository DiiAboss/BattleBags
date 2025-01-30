function destroy_blocks_in_direction_from_point(_self, start_x, start_y, _dir_x, _dir_y) {
    var width = _self.width;
    var height = _self.height;
    var blocks_destroyed = 0; // ✅ Count destroyed blocks
	var points_awarded  = 0;
	
    // Get the mouse-over position
	var hover_i = start_x;
	var hover_j = start_y;

    // Ensure it's within bounds
    if (hover_i < 0 || hover_i >= width || hover_j < 0 || hover_j >= height) return;

    // Start at the hovered position
    var i = hover_i;
    var j = hover_j;

    // Move in the chosen direction
    while (i >= 0 && i < width && j >= 0 && j < height) {
        if (_self.grid[i, j].type == -1) {
            break; // Stop if an empty space is encountered
        }
		
		
        blocks_destroyed++; // ✅ Increase count
		points_awarded = calculate_match_points(self, blocks_destroyed);
		
        // ✅ Mark block for destruction
        var pop_info = {
            x: i,
            y: j,
            gem_type: _self.grid[i, j].type,
            timer: 0,
            start_delay: max(abs(i - hover_i), abs(j - hover_j)) * 5, // Wave effect
            scale: 1.0,
            popping: true,
            powerup: _self.grid[i, j].powerup,
            offset_x: _self.grid[i, j].offset_x,
            offset_y: _self.grid[i, j].offset_y,
            color: _self.grid[i, j].color,
            y_offset_global: _self.global_y_offset,
			match_size: blocks_destroyed, // ✅ Store the match size
			match_points: points_awarded,			
        };

        _self.grid[i, j].popping = true;
        _self.grid[i, j].pop_timer = 0;

        ds_list_add(global.pop_list, pop_info);

        // Move in direction
        i += _dir_x;
        j += _dir_y;
    }

    // ✅ Add points based on destruction size
    _self.total_points += points_awarded;
}