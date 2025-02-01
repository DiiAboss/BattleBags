function drop_blocks(_self, fall_speed = 2) {
    var width = _self.width;
    var height = _self.height;
    var gem_size = _self.gem_size;
    var has_fallen = false; // ✅ Track if any block has moved

    for (var j = height - 2; j >= 0; j--) { // Process from bottom-up
        for (var i = 0; i < width; i++) {
            var gem = _self.grid[i, j];

            if (gem.type != -1) { // Valid gem
                var below = _self.grid[i, j + 1];

                // ✅ If the block below is empty, make this block fall
                if (below.type == -1) {
                    gem.falling = true; // ✅ Mark as falling

                    // ✅ Countdown fall delay before moving
                    if (gem.fall_delay < gem.max_fall_delay) {
                        gem.fall_delay++;
                    } else {
                        // ✅ Move the gem **one row down**
                        _self.grid[i, j + 1] = gem;
                        _self.grid[i, j] = create_gem(-1); // Clear old position
                        _self.gem_y_offsets[i, j + 1] = _self.gem_y_offsets[i, j]; // Keep offset
                        _self.gem_y_offsets[i, j] = 0; // Reset previous position
                        
                        // ✅ Reset fall delay
                        gem.fall_delay = 0;
                        has_fallen = true; // ✅ A block has moved, so we need another pass
                    }
                } 
                else {
                    // ✅ **Only stop falling if this is the lowest block in a stack**
                    if (gem.falling) {
                        gem.falling = false;
                    }
                }
            }
        }
    }

    // ✅ Ensure we **propagate falling status** upward in columns
    for (var i = 0; i < width; i++) {
        for (var j = height - 2; j >= 0; j--) {
            var gem = _self.grid[i, j];
            var below = _self.grid[i, j + 1];

            if (gem.type != -1 && below.falling) {
                gem.falling = true; // ✅ Keep the entire stack "falling"
				gem.fall_delay = 0;
            }
        }
    }

    // ✅ **New Check: Reset `is_enemy_block` only when fully landed**
    if (!has_fallen) {
        for (var i = 0; i < width; i++) {
            for (var j = 0; j < height; j++) {
                var gem = _self.grid[i, j];

                if (gem.type != -1 && !gem.falling) {
                    gem.is_enemy_block = false; // ✅ Now safe to reset
					gem.fall_delay = 0;
                }
            }
        }
    }
}

