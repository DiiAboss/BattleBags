
// Script Created By DiiAboss AKA Dillon Abotossaway
///@function find_and_destroy_matches
///
///@description Finds and removes matches of 3+ in the grid, including horizontal, vertical, and diagonal matches.
///
///@param {id} _self - The game object managing the board.
///@return {bool} - Returns `true` if any matches were found.
function find_and_destroy_matches(_self) {
    var width				 = _self.board_width;
	var bottom_row		     = _self.bottom_playable_row - 1;
    var min_match            = 3;
    var marked_for_removal	 = array_create(width, bottom_row);
    var found_any			 = false; 
    var first_found			 = false; // ✅ Track the first block in the combo
    var total_match_points	 = 0;     // ✅ Accumulates points for multiple matches
    var total_match_count    = 0;
	var last_swap_x          = global.lastSwapX;
    var last_swap_y          = global.lastSwapY;
    
    var total_pop_timer      = 0;
	var black_blocks_to_transform = ds_list_create(); // ✅ Store black blocks that will transform
    
    var pop_timer_per_block = 5;
    
	global.black_blocks_to_transform = ds_list_create(); // ✅ Track black blocks to transform
	
	check_2x2_match(self);
    
    
    // Initialize the marked_for_removal array
    for (var xx = 0; xx < width; xx++) {
        for (var yy = 0; yy <= bottom_row; yy++) {
            marked_for_removal[xx, yy] = false;
			
			if (_self.grid[xx, yy].pop_timer > 0)
			{
                _self.grid[xx, yy].pop_timer --;
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
    for (var j = 0; j <= bottom_row; j++) {
        var match_count = 1;
        var start_idx = 0;
        
        for (var i = 1; i < width; i++) {
            if (can_match(_self.grid[i, j], _self.grid[i - 1, j])) {
                if (match_count == 1) start_idx = i - 1;
                match_count++;
            } else {
                if (match_count >= min_match) {
                    for (var k = 0; k < match_count; k++) {
                        var xx = start_idx + k;
                        if (xx >= 0 && xx < width) {
                            marked_for_removal[xx, j] = true;
                            
                            var dist = abs(last_swap_x - xx) + abs(last_swap_y - j);
                            total_pop_timer      += pop_timer_per_block;
                            
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
                    total_match_count += match_count;
                    total_match_points += calculate_match_points(self, match_count);
                }
                match_count = 1;
            }
        }
        if (match_count >= min_match) {
            for (var k = 0; k < match_count; k++) {
                var xx = start_idx + k;
                if (xx >= 0 && xx < width) {
                    marked_for_removal[xx, j] = true;

                    var dist = abs(last_swap_x - xx) + abs(last_swap_y - j);
                    total_pop_timer      += pop_timer_per_block;
                    
                    if (!first_found) {
                        combo_x = xx;
                        combo_y = j;
                        first_found = true;
                    }
					 // ✅ Check for adjacent black blocks
                     check_adjacent_black_blocks(self, j, xx, black_blocks_to_transform);
                }
            }
            total_match_count += match_count;
           total_match_points += calculate_match_points(self, match_count);
        }
    }

    // -------------------------
    // ✅ VERTICAL MATCHES
    // -------------------------
    for (var i = 0; i < width; i++) {
        var match_count = 1;
        var start_idx = 0;

        for (var j = 1; j <= bottom_row; j++) {
            if (can_match(_self.grid[i, j], _self.grid[i, j - 1])) {
                if (match_count == 1) start_idx = j - 1;
                    
                match_count++;
                
            } else {
                if (match_count >= min_match) {
                    for (var k = 0; k < match_count; k++) {
                        var yy = start_idx + k;
						
                        if (yy >= 0 && yy <= bottom_row) {
                            marked_for_removal[i, yy] = true;
                            
                            var dist = abs(last_swap_x - i) + abs(last_swap_y - yy);
                            total_pop_timer      += pop_timer_per_block;
                            
                            if (!first_found) {
                                combo_x = i;
                                combo_y = yy;
                                first_found = true;
                            }
							 // ✅ Check for adjacent black blocks
                            check_adjacent_black_blocks(self, i, yy, black_blocks_to_transform);
                        }
                    }
                    total_match_count += match_count;
                    total_match_points += calculate_match_points(self, match_count);
                }
                match_count = 1;
            }
        }
        if (match_count >= min_match) {
            for (var k = 0; k < match_count; k++) {
                var yy = start_idx + k;
                if (yy >= 0 && yy <= bottom_row) {
                    marked_for_removal[i, yy] = true;

                    var dist = abs(last_swap_x - i) + abs(last_swap_y - yy);
                    total_pop_timer      += pop_timer_per_block;
                    
                    if (!first_found) {
                        combo_x = i;
                        combo_y = yy;
                        first_found = true;
                    }
					 // ✅ Check for adjacent black blocks
                     check_adjacent_black_blocks(self, i, yy, black_blocks_to_transform);
                }
            }
            total_match_count += match_count;
            total_match_points += calculate_match_points(self, match_count);
        }
    }

     //------------------------------
     //✅ DIAGONAL MATCHES (If enabled)
     //------------------------------
	 diagonal_match_process(self, _self.diagonal_matches);
	 
    // -------------------------
    // ✅ HANDLE MATCHED GEMS
    // -------------------------
    var first_match     = false;
    
    show_debug_message("TOTAL_POP_TIMER: " + string(total_pop_timer));

    
    var current_match_count = total_match_count;
    // This will go through the entire board, and remove any blocks that are morked for removal, we could isolate the blocks for removal to skip this for loop possibly.
	for (var i = 0; i < width; i++) {
	    for (var j = 0; j <= bottom_row; j++) {
            var block = _self.grid[i, j];
            var big_block_match = handle_find_and_destroy_big_block(_self, block, total_match_count, total_match_points);
            total_pop_timer   += big_block_match[0];
            total_match_count += big_block_match[1];
            
            if (marked_for_removal[i, j]) {
	            found_any = true;
                
	            //var gem = _self.grid[i, j];
                
                var m_size = 1;
                if !(first_match)
                {
                    first_match = true;
                    m_size = total_match_count;
                    objective_progress(OBJECTIVE_TYPE.MATCH_SIZE, undefined, total_match_count);
                    
                }
                else {
                    m_size = 1;
                }                
                
                var current_match_points = total_match_points * 1.5;
                
                var dx = i - last_swap_x;
                var dy = j - last_swap_y;
                
                var per_block = total_pop_timer / total_match_count;
                                
                var delay = per_block * current_match_count;
                //var dist = abs(dx) + abs(dy);
                //var delay = dist * 5;
                
	            // ✅ Send the block to pop_list (Now applies to normal and transformed blocks)
	            var pop_info = create_pop_info(self, block, i, j);
                pop_info.start_delay  = delay;
                pop_info.match_size   = m_size;
                pop_info.match_points = current_match_points;

                var combo = _self.combo;
                play_pitched_pop_sound(snd_pre_bubble_pop_test, combo);
                send_pop_info_to_pop_list(_self, pop_info, i, j);
                
                
                current_match_count -= 1;
	        }
	    }
	}
    
    ds_list_destroy(black_blocks_to_transform);
	
    return found_any;
}








function send_pop_info_to_pop_list(player, pop_info, x_pos, y_pos)
{
    if (player.game_over_state) return;
    
    player.grid[x_pos, y_pos].shake_timer = 30;
    player.grid[x_pos, y_pos].popping = true;
    player.grid[x_pos, y_pos].pop_timer = pop_info.start_delay + player.grid[x_pos, y_pos].shake_timer;
    pop_info.timer = 0;
    //player.grid[x_pos, y_pos].shake_timer = pop_info.start_delay;
    ds_list_add(player.pop_list, pop_info);
}

function play_pitched_pop_sound(sound, pitch_offset, pitch_gain_per_offset = 0.2, min_pitch = 1, max_pitch = 5)
{
    var current_pitch = (min_pitch + (pitch_gain_per_offset * pitch_offset))
    var pitch = clamp(current_pitch, min_pitch, max_pitch);
    audio_play_sound(sound, 10, false, 0.25, 0, pitch);
}

function handle_find_and_destroy_big_block(player, block, current_match_size, current_total_points)
{
    if !(block.is_big) return [0, 0];
        
    var group_id     = block.group_id;
    var block_type   = block.type;
    var bottom_row   = player.bottom_playable_row - 1;
    var parent_block = player.grid[block.big_parent[0], block.big_parent[1]];
    
    var parent_x = block.big_parent[0];
    var parent_y = block.big_parent[1];
    var width  = parent_block.mega_width;  // 2x2 block
    var height = parent_block.mega_height; // 2x2 block
    var max_x = parent_x + width;
    var max_y = parent_y + height;
    
    var last_swap_x = global.lastSwapX;
    var last_swap_y = global.lastSwapY;
    var total_dist  = 20;
    var current_block = 4;
    show_debug_message("2x2 BLOCK Found: \n[" + string(parent_x) + ", " + string(parent_y) + "] WIDTH: " + string(width) + ", HEIGHT: " + string(height));
    
    for (var _x = parent_x; _x < max_x; _x++) {
        for (var _y = parent_y; _y < max_y; _y++) { 
            var other_gem = player.grid[_x, _y];
            if (other_gem.group_id == group_id) {
                
                var delay = total_dist/current_block;
                current_block -=1;
                player.grid[_x, _y] = create_block(block.type);
                
                // ✅ Send the block to pop_list (Now applies to normal and transformed blocks)
                var pop_info          = create_pop_info(player, block, _x, _y);
                pop_info.start_delay  = delay;
                pop_info.match_size   = current_match_size;
                pop_info.match_points = current_total_points * 1.5;
                //pop_info.is_big = true;

                var combo = player.combo;
                play_pitched_pop_sound(snd_pre_bubble_pop_test, combo);
                send_pop_info_to_pop_list(player, pop_info, _x, _y);
            }
        }
    }
    
    return [total_dist, 2];
}