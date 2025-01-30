function activate_bomb_gem(_self, _x, _y) {
    var blocks_destroyed = 0; // ✅ Count destroyed blocks

    for (var i = _x - 1; i <= _x + 1; i++) {
        for (var j = _y - 1; j <= _y + 1; j++) {
            // ✅ Ensure within grid bounds & is a valid gem
            if (i >= 0 && i < _self.width && j >= 0 && j < _self.height && _self.grid[i, j].type != -1) {
				
				blocks_destroyed++; // ✅ Increase count
				points_awarded = calculate_match_points(self, blocks_destroyed);
		
		        // ✅ Mark block for destruction
		        var pop_info = {
		            x: i,
		            y: j,
		            gem_type: _self.grid[i, j].type,
		            timer: 0,
		            start_delay: max(abs(i - _x), abs(j - _y)) * 10, // Wave effect
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

				
                destroy_block(_self, i, j); // ✅ Destroy block
                blocks_destroyed += 1; // ✅ Track destroyed blocks
            }
        }
    }

    // ✅ Award points based on blocks destroyed
    if (blocks_destroyed > 0) {
        var points_awarded = calculate_match_points(_self, blocks_destroyed);
        _self.total_points += points_awarded;
    }
}