function create_mega_block(_width, _height) {
    return {
        x: -1, // Grid X position (top-left)
        y: -1, // Grid Y position (top-left)
        width: _width,
        height: _height,
        type: BLOCK.MEGA,
        falling: true,    // Gem type (e.g., 0 for red, 1 for blue, etc.)
        powerup: -1, // Power-up type (e.g., 0 for bomb, 1 for rainbow, etc.)
        locked: true,     // Whether the gem is locked
        offset_x: 0,       // Horizontal offset for animations
        offset_y: 0,       // Vertical offset for animations
        fall_target: -1,   // Target row for falling animations
		shake_timer: 0,    // New property for shaking effect
		color: c_white,
		fall_delay: 0,
		max_fall_delay: 10, 
		freeze_timer: 0,   // 🔥 New: Countdown to thaw
        frozen: false,      // 🔥 New: Flag for frozen state
		damage: 1,
		combo_multiplier: 1,
		pop_speed: 1,
		explode_on_four: false,
		explode_on_five: false,
		explode_on_six: false,
		popping: false,
		pop_timer: 0,
		group_id: irandom(99999)
    };
}

function spawn_mega_block(_self, _x, _y, _width, _height) {
    var mega_block = create_mega_block(_width, _height);
    mega_block.x = _x;
    mega_block.y = 0; // ✅ Start above screen
    mega_block.group_id = irandom(999999); // ✅ Unique ID for tracking
	mega_block.falling = true;

    // ✅ Reserve space in the grid for the entire Mega Block
    for (var i = 0; i < _width; i++) {
        for (var j = 0; j < _height; j++) {
            _self.grid[_x + i, _y + j] = mega_block; // Assign reference to the same object
        }
    }
}



function check_mega_block_transform(_self) {
    var transformed_groups = ds_map_create(); // ✅ Track which groups already transformed

    for (var j = 0; j < _self.height; j++) {
        for (var i = 0; i < _self.width; i++) {
            var gem = _self.grid[i, j];

            // ✅ Only process Mega Blocks
            if (gem.type == BLOCK.MEGA) {
                var group_id = gem.group_id;

                // ✅ Skip if this group has already transformed
                if (ds_map_exists(transformed_groups, group_id)) {
                    continue;
                }

                var transform = false;

                // ✅ **Check if any part of the Mega Block is next to a popping block**
                for (var bx = 0; bx < gem.width; bx++) {
                    for (var by = 0; by < gem.height; by++) {
                        var _x = gem.x + bx;
                        var _y = gem.y + by;

                        for (var dx = -1; dx <= 1; dx++) {
                            for (var dy = -1; dy <= 1; dy++) {
                                if (dx == 0 && dy == 0) continue; // Skip itself
                                var nx = _x + dx;
                                var ny = _y + dy;

                                if (nx >= 0 && nx < _self.width && ny >= 0 && ny < _self.height) {
                                    if (_self.grid[nx, ny] != -1 && _self.grid[nx, ny].popping) {
                                        transform = true;
                                    }
                                }
                            }
                        }
                    }
                }

                // ✅ **Trigger transformation**
                if (transform) {
                    gem.pop_timer += 1; // Start the popping delay

                    if (gem.pop_timer >= 30) { // 🔥 **Wait before transformation**
                        for (var bx = 0; bx < gem.width; bx++) {
                            for (var by = 0; by < gem.height; by++) {
                                var _x = gem.x + bx + board_x_offset;
                                var _y = gem.y + by;

                                // 🔥 **Create a pop effect before transformation**
                                effect_create_depth(_self.depth, ef_explosion, (_x * gem_size), (_y * gem_size), 0.5, c_white);

                                // ✅ **Transform the entire Mega Block**
                                _self.grid[_x, _y] = create_block(BLOCK.RANDOM);
                            }
                        }

                        // ✅ **Mark this group as transformed**
                        ds_map_add(transformed_groups, group_id, true);
                    }
                }
            }
        }
    }

    ds_map_destroy(transformed_groups); // ✅ Cleanup memory
}