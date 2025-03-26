function spawn_2x2_block(_self, _x, _y, _type) {
    
    if (_x < 0 || _x >= _self.width - 1 || _y < 0 || _y + 1 >= _self.bottom_playable_row) return;

    var parent_block = _self.grid[_x, _y];   // Top_left
    var top_right    = _self.grid[_x + 1, _y];
    var bottom_left  = _self.grid[_x, _y + 1];
    var bottom_right = _self.grid[_x + 1, _y + 1];
    
    // ✅ Check if space is available (NO big blocks already there)
    if (parent_block.is_big || top_right.is_big || bottom_left.is_big || bottom_right.is_big) {
        return; // ❌ Space is occupied, do NOT spawn
    }
	
	// ✅ Check if space is available (NO big blocks already there)
    if (parent_block.popping || top_right.popping ||
         bottom_left.popping || bottom_right.popping) {
        return; // ❌ Space is occupied, do NOT spawn
    }
	
    var width  = 2;
    var height = 2;

    // ✅ Clear the 2x2 space **before** placing the big block
    _self.grid[_x, _y]         = create_block(BLOCK.NONE);
    _self.grid[_x + 1, _y]     = create_block(BLOCK.NONE);
    _self.grid[_x, _y + 1]     = create_block(BLOCK.NONE);
    _self.grid[_x + 1, _y + 1] = create_block(BLOCK.NONE);
    
    // ✅ Generate unique, non-zero group_id
    // TODO: Create a function to generate ids 
    var group_id = irandom_range(1, 999999); // ✅ No -1 or 0

    // ✅ Create and assign the **big parent block**
    var big_gem         = create_block(_type);
    big_gem.is_big      = true;
    big_gem.group_id    = group_id;
    big_gem.big_parent  = [_x, _y];
	big_gem.mega_width  = width;
	big_gem.mega_height = height;
	

    _self.grid[_x, _y] = big_gem; // Place **actual big block**

    // ✅ Create & assign **child parts**
    for (var _dx = 0; _dx < width; _dx++) {
        for (var _dy = 0; _dy < height; _dy++) {
            if (_dx == 0 && _dy == 0) continue; // **Skip parent block**

            var child_gem = create_block(_type);
            child_gem.is_big     = true;
            child_gem.group_id   = group_id;
            child_gem.big_parent = [_x, _y];

            _self.grid[_x + _dx, _y + _dy] = child_gem; // Assign child parts
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

function is_2x2_match(_self, _x, _y) {
    // ✅ Bounds check
    if (_x < 0 || _x >= _self.width - 1 || _y < 0 || _y >= _self.height - 1) return false;
	
    // ✅ Retrieve 4 adjacent blocks
    var gem_0 = _self.grid[_x, _y];         // Top-left
    var gem_1 = _self.grid[_x + 1, _y];     // Top-right
    var gem_2 = _self.grid[_x, _y + 1];     // Bottom-left
    var gem_3 = _self.grid[_x + 1, _y + 1]; // Bottom-right
	
	if (gem_0.type == BLOCK.PUZZLE_1 || gem_0.type == BLOCK.BLACK || gem_0.type == BLOCK.CURSE) return false;
	
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

