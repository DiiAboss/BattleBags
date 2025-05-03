function spawn_2x2_block(player, _x, _y, _type) {
    var width      = player.board_width;
    var bottom_row = player.bottom_playable_row;
    
    if (_x < 0 || _x >= width - 1 || _y < 0 || _y + 1 >= bottom_row) return;

    var parent_block = player.grid[_x, _y];   // Top_left
    var top_right    = player.grid[_x + 1, _y];
    var bottom_left  = player.grid[_x, _y + 1];
    var bottom_right = player.grid[_x + 1, _y + 1];
    
    // ✅ Check if space is available (NO big blocks already there)
    if (parent_block.is_big || top_right.is_big || bottom_left.is_big || bottom_right.is_big) {
        return; // ❌ Space is occupied, do NOT spawn
    }
	
	// ✅ Check if space is available (NO big blocks already there)
    if (parent_block.popping || top_right.popping ||
         bottom_left.popping || bottom_right.popping) {
        return; // ❌ Space is occupied, do NOT spawn
    }
	
    var block_width  = 2;
    var block_height = 2;

    // ✅ Clear the 2x2 space **before** placing the big block
    player.grid[_x, _y]         = create_block(player, BLOCK.NONE);
    player.grid[_x + 1, _y]     = create_block(player, BLOCK.NONE);
    player.grid[_x, _y + 1]     = create_block(player, BLOCK.NONE);
    player.grid[_x + 1, _y + 1] = create_block(player, BLOCK.NONE);
    
    // ✅ Generate unique, non-zero group_id
    // TODO: Create a function to generate ids 
    var group_id = irandom_range(1, 999999); // ✅ No -1 or 0

    // ✅ Create and assign the **big parent block**
    var big_gem         = create_block(player, _type);
    big_gem.is_big      = true;
    big_gem.group_id    = group_id;
    big_gem.big_parent  = [_x, _y];
	big_gem.mega_width  = block_width;
	big_gem.mega_height = block_height;
	

    player.grid[_x, _y] = big_gem; // Place **actual big block**

    // ✅ Create & assign **child parts**
    for (var _dx = 0; _dx < block_width; _dx++) {
        for (var _dy = 0; _dy < block_height; _dy++) {
            if (_dx == 0 && _dy == 0) continue; // **Skip parent block**

            var child_gem = create_block(player, _type);
            child_gem.is_big     = true;
            child_gem.group_id   = group_id;
            child_gem.big_parent = [_x, _y];

            player.grid[_x + _dx, _y + _dy] = child_gem; // Assign child parts
        }
    }
}



function check_2x2_match(player, big_block_enabled = true) {
    if (!big_block_enabled) return; // ✅ Only run if enabled
	
	var width      = player.board_width;
	var bottom_row = player.bottom_playable_row - 1;
    
    for (var _x = 0; _x < width - 1; _x++) {
        for (var _y = 0; _y < bottom_row; _y++) {
            // ✅ Check if a 2x2 match exists
            if (is_2x2_match(player, _x, _y)) {
                spawn_2x2_block(player, _x, _y, player.grid[_x, _y].type); 
            }
        }
    }
}




function is_2x2_match(player, _x, _y) {
    // ✅ Bounds check
    var width  = player.board_width;
    var height = player.board_height;
    
    if (_x < 0 || _x >= width - 1 || _y < 0 || _y >= height - 1) return false;
	
    // ✅ Retrieve 4 adjacent blocks
    var gem_0 = player.grid[_x, _y];         // Top-left
    var gem_1 = player.grid[_x + 1, _y];     // Top-right
    var gem_2 = player.grid[_x, _y + 1];     // Bottom-left
    var gem_3 = player.grid[_x + 1, _y + 1]; // Bottom-right
	
	if (gem_0.type == BLOCK.PUZZLE_1 || gem_0.type == BLOCK.BLACK || gem_0.type == BLOCK.CURSE || gem_0.type == BLOCK.MEGA) return false;
	
    // ✅ Ensure all blocks match **type** & are NOT already big
    if (gem_0.type != BLOCK.NONE && 
        gem_0.type == gem_1.type && 
        gem_0.type == gem_2.type && 
        gem_0.type == gem_3.type &&
        !gem_0.is_big && !gem_1.is_big && !gem_2.is_big && !gem_3.is_big) {
        
        return true; // ✅ Match Found!
    }

    return false; // ❌ No match
}

