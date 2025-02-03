function destroy_blocks_in_direction_from_point(_self, start_x, start_y, _dir_x, _dir_y) {
    var width = _self.width;
    var height = _self.height;
    var blocks_destroyed = 0;
    var points_awarded = 0;

    // ✅ Start at the given position
    var i = start_x;
    var j = start_y;

    // ✅ Move in the given direction
    while (i >= 0 && i < width && j >= 1 && j < height) {
        var gem = _self.grid[i, j];

        if (i < 0 || i > width) {
            break; // Stop if an empty space or already popping gem is encountered
        }

        blocks_destroyed++;

        // ✅ Calculate points for this destruction
        points_awarded = calculate_match_points(_self, blocks_destroyed);

        // ✅ Mark block for delayed destruction
        var pop_info = {
            x: i,
            y: j,
            gem_type: gem.type,
            timer: 0,
            start_delay: max(abs(i - start_x), abs(j - start_y)) * 5, // Wave effect
            scale: 1.0,
            popping: true,
            powerup: gem.powerup,
            offset_x: gem.offset_x,
            offset_y: gem.offset_y,
            color: gem.color,
            y_offset_global: _self.global_y_offset,
            match_size: blocks_destroyed,
            match_points: points_awarded,
			bomb_tracker: false,
			bomb_level: 1,
			dir: gem.dir,
        };

        gem.popping = true;
        gem.pop_timer = 0;
		
		if (gem.type == BLOCK.BLACK)
		{
			grid[i, j] = create_gem(-99);
		}
		else
		
		
		if (gem.type != -1)
		{
			ds_list_add(global.pop_list, pop_info);
		}

        // Move in the given direction
        i += _dir_x;
        j += _dir_y;
    }

    // ✅ Add total points from destruction
    _self.total_points += points_awarded;
}
