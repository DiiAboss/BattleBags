///@function find_and_destroy_matches
///
///@description Finds and removes matches of 3+ in the grid, including horizontal, vertical, and diagonal matches.
///
///@param {id} mp_control - The game object managing the board.
///@return {bool} - Returns `true` if any matches were found.
function find_matches_and_add_to_pop_list(mp_control, player) {
    
    var width				 = mp_control.width;
    var bottom_row		     = mp_control.bottom_playable_row;
    var marked_for_removal	 = array_create(width, bottom_row);
    var found_any			 = false;
    var first_found			 = false; // ✅ Track the first block in the combo
    var total_match_points	 = 0;     // ✅ Accumulates points for multiple matches

    if (ds_list_size(player.pop_list) > 0)
    {
        //return false;
    }
    //check_2x2_match(self);
    
    
    // Initialize the marked_for_removal array
    for (var xx = 0; xx < width; xx++) {
        for (var yy = 0; yy <= bottom_row; yy++) {
            marked_for_removal[xx, yy] = false;
            
            
            if (player.grid[xx, yy].shake_timer > 0)
            {
                player.grid[xx, yy].popping = true;
                player.grid[xx, yy].falling = false;
                player.grid[xx, yy].fall_delay = 1;
            }
            else
            {
                player.grid[xx, yy].popping = false;
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
                    if (can_match(player.grid[i, j], player.grid[i - 1, j])) {
                        if (match_count == 1) start_idx = i - 1;
                        match_count++;
                    } else {
                        if (match_count >= 3) {
                            player.combo += 1;
                                        player.combo_timer = 0;
                            for (var k = 0; k < match_count; k++) {
                                var xx = start_idx + k;
                                if (xx >= 0 && xx < width) {
                                    marked_for_removal[xx, j] = true;
                                }
                            }
                        }
                        match_count = 1;
                    }
                }
                if (match_count >= 3) {
                    
                                player.combo += 1;
                                player.combo_timer = 0;
                    
                    for (var k = 0; k < match_count; k++) {
                        var xx = start_idx + k;
                        if (xx >= 0 && xx < width) {
                            marked_for_removal[xx, j] = true;
                        }
                    }
                }
            }
    
    

    // -------------------------
    // ✅ VERTICAL MATCHES
    // -------------------------
    for (var i = 0; i < width; i++) {
        var match_count = 1;
        var start_idx = 0;

        for (var j = 1; j <= bottom_row; j++) {
            if (can_match(player.grid[i, j], player.grid[i, j - 1])) {
                if (match_count == 1) start_idx = j - 1;
                match_count++;
            } else {
                if (match_count >= 3) {
                    player.combo += 1;
                                player.combo_timer = 0;
                    for (var k = 0; k < match_count; k++) {
                        var yy = start_idx + k;
                        
                        if (yy >= 0 && yy <= bottom_row) {
                            marked_for_removal[i, yy] = true;

                        }
                    }
                }
                match_count = 1;
            }
        }
        if (match_count >= 3) {
            
            player.combo += 1;
            player.combo_timer = 0;
            
            for (var k = 0; k < match_count; k++) {
                var yy = start_idx + k;
                if (yy >= 0 && yy <= bottom_row) {
                    marked_for_removal[i, yy] = true;

                }
            }
        }
    }

    // -------------------------
    // ✅ HANDLE MATCHED GEMS
    // -------------------------

    for (var i = 0; i < width; i++) {
        for (var j = 0; j <= bottom_row; j++) {
            if (marked_for_removal[i, j]) {
                found_any = true;
                //player.grid[i, j].shake_timer = player.max_shake_timer; // Start shaking effect
                
                var gem = player.grid[i, j];
                
                var dx = i - player.last_swap_x;
                var dy = j - player.last_swap_y;
                var dist = sqrt(dx * dx + dy * dy);
                var _start_delay = 5;
            

                // ✅ Send the block to pop_list (Now applies to normal and transformed blocks)
                var pop_info = {
                    x: i,
                    y: j,
                    gem_type: gem.type,
                    timer: 0,
                    start_delay: _start_delay * dist, // Wave effect
                    scale: 1.0,
                    popping: true,
                    powerup: gem.powerup,
                    dir: gem.dir,
                    offset_x: gem.offset_x,
                    offset_y: gem.offset_y,
                    color: gem.color,
                    y_offset_global: player.global_y_offset,
                    match_size: match_count, // ✅ Store the match size
                    match_points: 1,
                    bomb_tracker: false, // Flag to mark this pop as bomb‐generated
                    bomb_level: 0,
                    img_number: gem.img_number,
                };

                player.grid[i, j].popping   = true;
                player.grid[i, j].shake_timer   = _start_delay * dist;
                player.grid[i, j].pop_timer = dist;
                
                
                var _pitch = clamp(1 + (0.2 * player.combo), 0.5, 5);

                audio_play_sound(snd_pre_bubble_pop_test, 10, false, 0.25, 0, _pitch);
                ds_list_add(player.pop_list, pop_info);
            }
        }
    }
   
    return found_any;
}


function pop_blocks_in_pop_queue(mp_control, player) {
    if (ds_list_size(player.pop_list) == 0) return;

    for (var i = ds_list_size(player.pop_list) - 1; i >= 0; i--) {
        var pop_data = ds_list_find_value(player.pop_list, i);
        var _x = pop_data.x;
        var _y = pop_data.y;

        if (pop_data.timer < pop_data.start_delay) {
            pop_data.timer++;
            player.combo_timer = 0;

        
            
        } else {
            // Grow effect
            pop_data.scale += 0.05;
            
            // Once scale >= 1.1, pop is done
            if (pop_data.scale < 1.1) return;

            //if (player.grid[_x, _y] == BLOCK.NONE) return;
            
            // ✅ Store Gem Object Before Destroying
            var gem = player.grid[_x, _y];

            

            destroy_block(player, _x, _y);
            
            player.grid[_x, _y].shake_timer = 0;
            player.grid[_x, _y].popping = false;
            player.grid[_x, _y].pop_timer = false;
            
            // **Create visual effect**
            //effect_create_depth(_depth, ef_firework, px, py - 4, 0.5, pop_data.color);

            // ✅ Create Attack Object with Score
            //var attack = instance_create_depth(px, py, _depth - 1, obj_player_attack);
            //attack.color = pop_data.color;
        
            //attack.damage = (pop_data.match_points / pop_data.match_size) * total_multiplier_next; // 🔥 **Apply multiplier to damage!**

            // ✅ Add accumulated match points to total_points
            //total_points += attack.damage;
            
            if (player.grid[_x, _y - 1].type != BLOCK.NONE)
            {
                player.grid[_x, _y - 1].falling = true;
                player.grid[_x, _y - 1].fall_delay = 1;
                player.grid[_x, _y - 1].popping = false;
            }
        
        
            var _pitch = clamp(0.5 + (0.1 * player.combo), 0.5, 5);
            var _gain = clamp(0.5 + (0.1 * player.combo), 0.5, 0.75);
            
            
            audio_play_sound(snd_pop_test_1, 10, false, _gain, 0, _pitch);
            // Remove from pop_list
            ds_list_delete(player.pop_list, i);
            i--; 
            continue;
            
        }

        pop_data.scale += 0.05;

        if (pop_data.scale >= 1.1) {
            
            destroy_block(player, _x, _y);  // Just destroy, don't trigger fall

            audio_play_sound(snd_pop_test_1, 10, false, 0.5, 0, 1.0);

            ds_list_delete(player.pop_list, i);
            player.grid[_x, _y].popping = false;
        } else {
            ds_list_replace(player.pop_list, i, pop_data);
        }
    }
}



function process_popping_mp(player) {
    for (var i = 0; i < ds_list_size(player.pop_list); i++) {
        var pop_data = ds_list_find_value(player.pop_list, i);

        // ✅ Wait for start_delay
        if (pop_data.timer < pop_data.start_delay) {
            pop_data.timer++;
        } else {
            pop_data.scale += 0.05;

            if (pop_data.scale >= 1.1) {
                var _x = pop_data.x;
                var _y = pop_data.y;

                //if (player.grid[_x, _y] != -1) {
                    destroy_block(player, _x, _y);
                player.grid[_x, _y].popping = false;
                player.grid[_x, _y - 1].popping = false;
                //}

                var _pitch = clamp(0.5 + (0.1 * player.combo), 0.5, 5);
                var _gain = clamp(0.5 + (0.1 * player.combo), 0.5, 0.75);
                audio_play_sound(snd_pop_test_1, 10, false, _gain, 0, _pitch);

                // ✅ Remove from pop_list
                ds_list_delete(player.pop_list, i);
                i--; // Adjust index after deletion
                continue;
            }
        }
        
        ds_list_replace(player.pop_list, i, pop_data);
    }
}