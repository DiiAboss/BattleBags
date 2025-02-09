function drop_blocks(_self, fall_speed = 2) {
    var width = _self.width;
    var height = _self.height;
    var gem_size = _self.gem_size;
    var has_fallen = false; // ✅ Track if any block has moved

    for (var j = height - 2; j >= 0; j--) { // Process from bottom-up
        for (var i = 0; i < width; i++) {
            var gem = _self.grid[i, j];
			

            if (gem.type != BLOCK.NONE) { // Valid gem
				if (gem.frozen) && (gem.falling)
				{
					gem.falling = false;
					
				}
				
            var below = _self.grid[i, j + 1];
			//gem.falling = below.popping;
            // ✅ If the block below is empty, make this block fall
            if (below.type == BLOCK.NONE) && (below.popping == false){
                gem.falling = true; // ✅ Mark as falling
					
				// ✅ Handle 2x2 Block Falling
            if (gem.is_big) {
                var parent_x = gem.big_parent[0];
                var parent_y = gem.big_parent[1];
					
                var bottom_left  = _self.grid[parent_x,     parent_y + 1];
                var bottom_right = _self.grid[parent_x + 1, parent_y + 1];
				var top_left     = _self.grid[parent_x,     parent_y];
				var top_right    = _self.grid[parent_x + 1, parent_y];
				var empty_below_bottom_blocks = false;
				
				if (parent_y + 2 < height) { 
				var empty_below_bottom_blocks = _self.grid[parent_x,     parent_y + 2].type == BLOCK.NONE 
											 && _self.grid[parent_x + 1, parent_y + 2].type == BLOCK.NONE;
				}
                    // ✅ Both lower parts must be empty
                    if (empty_below_bottom_blocks) {
							
						_self.grid[parent_x,     parent_y + 2]  = bottom_left; // set the block below the parent block to the new parent block
                        _self.grid[parent_x + 1, parent_y + 2]  = bottom_right;  // set the block below the parent block to the new parent block
                        _self.grid[parent_x,     parent_y + 1]  = top_left; // set the block below the parent block to the new parent block
                        _self.grid[parent_x + 1, parent_y + 1]  = top_right;  // set the block below the parent block to the new parent block

						_self.grid[parent_x,     parent_y] = create_block(BLOCK.NONE); // set the old top row to null
                        _self.grid[parent_x + 1, parent_y] = create_block(BLOCK.NONE);
							
						// Update parent reference
                        _self.grid[parent_x,     parent_y + 2].big_parent = [parent_x, parent_y + 1];
                        _self.grid[parent_x + 1, parent_y + 2].big_parent = [parent_x, parent_y + 1];
						_self.grid[parent_x,     parent_y + 1].big_parent = [parent_x, parent_y + 1];
                        _self.grid[parent_x + 1, parent_y + 1].big_parent = [parent_x, parent_y + 1];
							
                        has_fallen = true;
                    }
					else
					{
						_self.grid[parent_x,     parent_y + 1].falling = false; // set the block below the parent block to the new parent block
                        _self.grid[parent_x + 1, parent_y + 1].falling = false;  // set the block below the parent block to the new parent block
						_self.grid[parent_x,     parent_y].falling = false; // set the block below the parent block to the new parent block
                        _self.grid[parent_x + 1,  parent_y].falling = false;  // set the block below the parent block to the new parent block
					}
                } 
					
                    // ✅ Countdown fall delay before moving
                    if (gem.fall_delay < gem.max_fall_delay) {
                        gem.fall_delay++;
                    } else {
                        // ✅ Move the gem **one row down**
                        _self.grid[i, j + 1] = gem;
                        _self.grid[i, j] = create_block(BLOCK.NONE); // Clear old position
                        //_self.gem_y_offsets[i, j + 1] = _self.gem_y_offsets[i, j]; // Keep offset
                        //_self.gem_y_offsets[i, j] = 0; // Reset previous position
                        
                        // ✅ Reset fall delay
                        gem.fall_delay = gem.max_fall_delay;
                        has_fallen = true; // ✅ A block has moved, so we need another pass
                    }
                } 
                else {
                    // ✅ **Only stop falling if this is the lowest block in a stack**
                    if (gem.falling) && (!below.falling) {
                        gem.falling = false;
						gem.fall_delay = 0;
                    }
                }
            }
        }
    }
	
	    // 🔥 THIRD PASS: Explicitly Mark **Bottom-Row Blocks as Landed**
    for (var i = 0; i < width; i++) {
        var gem = _self.grid[i, _self.bottom_playable_row]; // Last row

        if (gem.type != -1) { // Valid gem
            gem.falling = false; // ✅ Ensure it is settled
            gem.fall_delay = 0;
        }
    }

    // ✅ Ensure we **propagate falling status** upward in columns
    for (var i = 0; i < width; i++) {
        for (var j = _self.bottom_playable_row; j >= 0; j--) {
            var gem = _self.grid[i, j];
            var below = _self.grid[i, j + 1];

            if (gem.type != -1 && below.falling) {
                gem.falling = true; // ✅ Keep the entire stack "falling"
				gem.fall_delay = below.fall_delay;
            }
        }
    }

    // ✅ **New Check: Reset `is_enemy_block` only when fully landed**
    if (!has_fallen) {
        for (var i = 0; i < width; i++) {
            for (var j = 0; j < _self.bottom_playable_row; j++) {
                var gem = _self.grid[i, j];

                if (gem.type != BLOCK.NONE && !gem.falling) {
                    gem.is_enemy_block = false; // ✅ Now safe to reset
					gem.fall_delay = 0;
                }
            }
        }
    }
}


function sync_big_blocks(_self) {
    var width = _self.width;
    var height = _self.height;

    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            var gem = _self.grid[i, j];

            if (gem.is_big) {
                var parent_x = gem.big_parent[0];
                var parent_y = gem.big_parent[1];

                // ✅ Ensure all blocks have the correct parent
                if (i != parent_x || j != parent_y) {
                    _self.grid[i, j].big_parent = [parent_x, parent_y];
                }

                // ✅ If the bottom row of the block has landed, lock the top row to it
                var bottom_left  = _self.grid[parent_x, parent_y + 1];
                var bottom_right = _self.grid[parent_x + 1, parent_y + 1];

                if (!bottom_left.falling && !bottom_right.falling) {
                    _self.grid[parent_x, parent_y].falling = false;
                    _self.grid[parent_x + 1, parent_y].falling = false;
                    _self.grid[parent_x, parent_y + 1].falling = false;
                    _self.grid[parent_x + 1, parent_y + 1].falling = false;
                }
            }
        }
    }
}


function should_block_fall(_self, i, j) {
    if (j >= _self.height - 1) return false; // Last row never falls

    var below = _self.grid[i, j + 1];

    // ✅ If the block below is EMPTY or POPPING, this block should fall
    return (below.type == -1 || below.popping);
}






