
// Script Created By DiiAboss AKA Dillon Abotossaway
///@function find_and_destroy_matches
///
///@description Finds and removes matches of 3+ in the grid, including horizontal, vertical, and diagonal matches.
///
///@param {id} _self - The game object managing the board.
///@return {bool} - Returns `true` if any matches were found.
function find_and_destroy_matches(_self) {
    var width				 = _self.width;
	var bottom_row		     = _self.bottom_playable_row;
    var marked_for_removal	 = array_create(width, bottom_row);
    var found_any			 = false;
    var first_found			 = false; // ✅ Track the first block in the combo
    var total_match_points	 = 0;     // ✅ Accumulates points for multiple matches
	
	
	var black_blocks_to_transform = ds_list_create(); // ✅ Store black blocks that will transform
	
	global.black_blocks_to_transform = ds_list_create(); // ✅ Track black blocks to transform
	
	check_2x2_match(self);
    
    
    // Initialize the marked_for_removal array
    for (var xx = 0; xx < width; xx++) {
        for (var yy = 0; yy <= bottom_row; yy++) {
            marked_for_removal[xx, yy] = false;
			
			
			if (_self.grid[xx, yy].shake_timer > 0)
			{
				_self.grid[xx, yy].popping = true;
			}
			else
			{
				_self.grid[xx, yy].popping = false;
			}
			
        }
    }

    // -------------------------
    // ✅ HORIZONTAL MATCHES
    // -------------------------
    for (var j = 0; j <= _self.bottom_playable_row; j++) {
        var match_count = 1;
        var start_idx = 0;

        for (var i = 1; i < width; i++) {
            if (can_match(_self.grid[i, j], _self.grid[i - 1, j])) {
                if (match_count == 1) start_idx = i - 1;
                match_count++;
            } else {
                if (match_count >= 3) {
                    for (var k = 0; k < match_count; k++) {
                        var xx = start_idx + k;
                        if (xx >= 0 && xx < width) {
                            marked_for_removal[xx, j] = true;

                            if (!first_found) {
                                combo_x = xx;
                                combo_y = j;
                                first_found = true;
                            }
							 // ✅ Check for adjacent black blocks
                            check_adjacent_black_blocks(self, j, xx, black_blocks_to_transform);
                        }
                    }
                    // ✅ Add points based on match size
                    total_match_points += calculate_match_points(self, match_count);
                }
                match_count = 1;
            }
        }
        if (match_count >= 3) {
            for (var k = 0; k < match_count; k++) {
                var xx = start_idx + k;
                if (xx >= 0 && xx < width) {
                    marked_for_removal[xx, j] = true;

                    if (!first_found) {
                        combo_x = xx;
                        combo_y = j;
                        first_found = true;
                    }
					 // ✅ Check for adjacent black blocks
                     check_adjacent_black_blocks(self, j, xx, black_blocks_to_transform);
                }
            }
           total_match_points += calculate_match_points(self, match_count);
        }
    }

    // -------------------------
    // ✅ VERTICAL MATCHES
    // -------------------------
    for (var i = 0; i < width; i++) {
        var match_count = 1;
        var start_idx = 0;

        for (var j = 1; j <= _self.bottom_playable_row; j++) {
            if (can_match(_self.grid[i, j], _self.grid[i, j - 1])) {
                if (match_count == 1) start_idx = j - 1;
                match_count++;
            } else {
                if (match_count >= 3) {
                    for (var k = 0; k < match_count; k++) {
                        var yy = start_idx + k;
						
                        if (yy >= 0 && yy <= bottom_row) {
                            marked_for_removal[i, yy] = true;

                            if (!first_found) {
                                combo_x = i;
                                combo_y = yy;
                                first_found = true;
                            }
							 // ✅ Check for adjacent black blocks
                            check_adjacent_black_blocks(self, i, yy, black_blocks_to_transform);
                        }
                    }
                    total_match_points += calculate_match_points(self, match_count);
                }
                match_count = 1;
            }
        }
        if (match_count >= 3) {
            for (var k = 0; k < match_count; k++) {
                var yy = start_idx + k;
                if (yy >= 0 && yy <= bottom_row) {
                    marked_for_removal[i, yy] = true;

                    if (!first_found) {
                        combo_x = i;
                        combo_y = yy;
                        first_found = true;
                    }
					 // ✅ Check for adjacent black blocks
                     check_adjacent_black_blocks(self, i, yy, black_blocks_to_transform);
                }
            }
            total_match_points += calculate_match_points(self, match_count);
        }
    }

     //-------------------------
     //✅ DIAGONAL MATCHES (If enabled)
     //-------------------------
	 diagonal_match_process(self, _self.diagonal_matches);
	 
    // -------------------------
    // ✅ HANDLE MATCHED GEMS
    // -------------------------

	for (var i = 0; i < width; i++) {
	    for (var j = 0; j <= _self.bottom_playable_row; j++) {
	        if (marked_for_removal[i, j]) {
	            found_any = true;
	            _self.grid[i, j].shake_timer = _self.max_shake_timer; // Start shaking effect

	            var gem = _self.grid[i, j];

	            var dx = i - global.lastSwapX;
	            var dy = j - global.lastSwapY;
	            var dist = sqrt(dx * dx + dy * dy);
	            var _start_delay = (gem.type == BLOCK.BLACK) ? 5 : 5; // Longer delay for black blocks
			
	            // ✅ If it's a BIG BLOCK, transform it into separate blocks
	            if (gem.is_big) {
	                var group_id = gem.group_id;

	                for (var _x = 0; _x < width; _x++) {
	                    for (var _y = 0; _y <= bottom_row; _y++) {
	                        var other_gem = grid[_x, _y];

	                        if (other_gem.group_id == group_id) {
	                            // ✅ Convert each big block part into a small block of the same type
	                            _self.grid[_x, _y] = create_block(gem.type);						
							
								 // ✅ Send the block to pop_list (Now applies to normal and transformed blocks)
					            var pop_info = {
					                x: _x,
					                y: _y,
					                gem_type: gem.type,
					                timer: 0,
					                start_delay: dist * _start_delay, // Wave effect
					                scale: 1.0,
					                popping: true,
					                powerup: gem.powerup,
					                dir: gem.dir,
					                offset_x: gem.offset_x,
					                offset_y: gem.offset_y,
					                color: gem.color,
					                y_offset_global: _self.global_y_offset,
					                match_size: match_count, // ✅ Store the match size
					                match_points: total_match_points * 1.5,
					                bomb_tracker: false, // Flag to mark this pop as bomb‐generated
					                bomb_level: 0,
									img_number: gem.img_number,
					            };
							
	                            _self.grid[_x, _y].popping   = true;  // Start popping process
	                            _self.grid[_x, _y].pop_timer = dist * _start_delay;
								var _pitch = clamp(0.75 + (0.2 * _self.combo), 0.5, 5);
                                if !(_self.game_over_state)
                                {
                                    audio_play_sound(snd_pre_bubble_pop_test, 10, false, 0.25, 0, _pitch);
                                }
                                
								
								ds_list_add(global.pop_list, pop_info);
	                        }
	                    }
	                }
	            }

	            // ✅ Send the block to pop_list (Now applies to normal and transformed blocks)
	            var pop_info = {
	                x: i,
	                y: j,
	                gem_type: gem.type,
	                timer: 0,
	                start_delay: dist * _start_delay, // Wave effect
	                scale: 1.0,
	                popping: true,
	                powerup: gem.powerup,
	                dir: gem.dir,
	                offset_x: gem.offset_x,
	                offset_y: gem.offset_y,
	                color: gem.color,
	                y_offset_global: _self.global_y_offset,
	                match_size: match_count, // ✅ Store the match size
	                match_points: total_match_points,
	                bomb_tracker: false, // Flag to mark this pop as bomb‐generated
	                bomb_level: 0,
					img_number: gem.img_number,
	            };

	            _self.grid[i, j].popping   = true;
	            _self.grid[i, j].pop_timer = dist * _start_delay;
				var _pitch = clamp(1 + (0.2 * _self.combo), 0.5, 5);
                if !(_self.game_over_state)
                {
                    audio_play_sound(snd_pre_bubble_pop_test, 10, false, 0.25, 0, _pitch);
                }
	            ds_list_add(global.pop_list, pop_info);
	        }
	    }
	}
	
	
	// ✅ Transform black blocks **after matches are removed**
    update_black_blocks(self, black_blocks_to_transform);
	

    ds_list_destroy(black_blocks_to_transform);
	
    return found_any;
}


