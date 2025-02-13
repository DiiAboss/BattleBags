function drop_blocks(_self, fall_speed = 2) {
    var width = _self.width;
    var height = _self.height;
    var has_fallen = false; // ✅ Track if any block has moved

    //  Process from **bottom-up** (ensures things fall properly)
    for (var j = height - 2; j >= 0; j--) {
        for (var i = 0; i < width; i++) {
            var gem = _self.grid[i, j];
			process_mega_blocks(_self, i, j);
            if (gem.type != BLOCK.NONE) { // ✅ Only process valid blocks
                var below = _self.grid[i, j + 1];

                //  **Frozen blocks never fall**
                if (gem.frozen) {					
                    gem.fall_delay = 0;
                    gem.falling = false;
                    continue;
                }
				
                // 🔹 **Slime Block Falling**
                if (gem.slime_hp > 0) { 
                    if (below.type == BLOCK.NONE) {
                        if (gem.fall_delay < gem.max_fall_delay) {
                            gem.fall_delay++;
                            continue;
                        }

                        // ✅ **Move block down**
                        _self.grid[i, j + 1] = gem;
                        _self.grid[i, j] = create_block(BLOCK.NONE);

                        // 🔥 **Reduce Slime HP when moving**
                        gem.slime_hp -= 1;

                        // ✅ **If slime HP runs out, return to normal**
                        if (gem.slime_hp <= 0) {
                            gem.max_fall_delay = 5;  // ✅ Normal falling speed
                            gem.swap_speed = 0.15;    // ✅ Normal swap speed
                        }

                        gem.fall_delay = 0;
                        has_fallen = true;
                    }
                }

                //  **Handle 2x2 Block Falling**
                if (gem.is_big) {
                    var parent_x = gem.big_parent[0];
                    var parent_y = gem.big_parent[1];
					var parent_block = _self.grid[parent_x, parent_y];
					var big_block_width = parent_block.mega_width;
					var big_block_height = parent_block.mega_height;
					
                    // ✅ Only process once for **parent block**
                    if (i == parent_x && j == parent_y) {
                    var bottom_left  = _self.grid[parent_x,     parent_y + 1];
                    var bottom_right = _self.grid[parent_x + 1, parent_y + 1];
					
					var can_fall = true;
					
					for (var bbx = 0; bbx < big_block_width; bbx++)
					{
						var _block_x = parent_x + bbx;
						var _block_y = parent_y + big_block_height;
						
						
						if (_self.grid[_block_x, _block_y] && _self.grid[_block_x, _block_y].type != BLOCK.NONE) {
							can_fall = false;
                        }
					}

					// ✅ Check if the **entire bottom row** of the block can fall
                        if (can_fall) {
                            // ✅ Apply **fall delay**
                            if (gem.fall_delay < gem.max_fall_delay) {
                                gem.fall_delay++;
                                continue; // 🔹 Wait until delay finishes
                            }
							
							// ✅ Move the entire Mega Block **down one row**
                            for (var bbx = 0; bbx < big_block_width; bbx++) {
                                for (var bby = big_block_height - 1; bby >= 0; bby--) {
                                    var old_x = parent_x + bbx;
                                    var old_y = parent_y + bby;
                                    var new_x = old_x;
                                    var new_y = old_y + 1; // ✅ **Move down using your logic**

                                    _self.grid[new_x, new_y] = _self.grid[old_x, old_y]; // Move
                                    _self.grid[old_x, old_y] = create_block(BLOCK.NONE); // Clear
                                    _self.grid[new_x, new_y].big_parent = [parent_x, parent_y + 1]; // ✅ Update parent
                                }
                            }

                            gem.fall_delay = 1;
                            has_fallen = true;
                        } else {
							// ✅ **If it can’t fall, all blocks stop falling**
                            for (var bx = 0; bx < big_block_width; bx++) {
                                for (var by = 0; by < big_block_height; by++) {
                                    var block_x = parent_x + bx;
                                    var block_y = parent_y + by;
                                    _self.grid[block_x, block_y].falling = false;
									_self.grid[block_x, block_y].fall_delay = 0;
									_self.grid[block_x, block_y].is_enemy_block = false;
									has_fallen = true;
                                }
                            }
                        }
                    }
                } 
                //  **Normal Single Block Falling**
                else if (below.type == BLOCK.NONE) {
                    // ✅ Apply **fall delay**
                    if (gem.fall_delay < gem.max_fall_delay) {
                        gem.fall_delay++;
                        continue; //  Wait until delay finishes
                    }

                    _self.grid[i, j + 1] = gem;
                    _self.grid[i, j] = create_block(BLOCK.NONE);
                    gem.fall_delay = 0;
                    has_fallen = true;
                }
            }
        }
    }

    return has_fallen; // ✅ If anything fell, we need another update pass
}

function can_mega_block_fall(_self, _x, _y) {
    var parent_x = _self.grid[_x, _y].big_parent[0];
    var parent_y = _self.grid[_x, _y].big_parent[1];
    var group_id = _self.grid[parent_x, parent_y].group_id;
    
    var width = _self.grid[parent_x, parent_y].mega_width;
    var height = _self.grid[parent_x, parent_y].mega_height;
    
    // ✅ Check if all **bottom row** parts can fall
    for (var i = 0; i < width; i++) {
        var block_x = parent_x + i;
        var block_y = parent_y + height - 1; // Bottom-most row of the block
        
        if (block_y + 1 >= _self.height) return false; // 🔹 Prevent out-of-bounds

        var below = _self.grid[block_x, block_y + 1];
        if (below.type != BLOCK.NONE) return false; // 🔥 If ANY part is blocked, no fall
    }

    return true; // ✅ If all bottom parts can fall, return true
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






