///@function find_and_destroy_matches
///
///@description Finds and removes matches of 3+ in the grid, including horizontal, vertical, and diagonal matches.
///
///@param {id} mp_control - The game object managing the board.
///@return {bool} - Returns `true` if any matches were found.
function find_and_destroy_matches_mp(mp_control, player) {
    
    var width				 = mp_control.width;
    var bottom_row		     = mp_control.bottom_playable_row;
    var marked_for_removal	 = array_create(width, bottom_row);
    var found_any			 = false;
    var first_found			 = false; // ✅ Track the first block in the combo
    var total_match_points	 = 0;     // ✅ Accumulates points for multiple matches

    if (ds_list_size(player.pop_list) > 0)
    {
        return false;
    }
    //check_2x2_match(self);
    
    
    // Initialize the marked_for_removal array
    for (var xx = 0; xx < width; xx++) {
        for (var yy = 0; yy <= bottom_row; yy++) {
            marked_for_removal[xx, yy] = false;
            
            
            if (player.grid[xx, yy].shake_timer > 0)
            {
                player.grid[xx, yy].popping = true;
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
//
                //var dx = i - global.lastSwapX;
                //var dy = j - global.lastSwapY;
                var dist = 5;
            

                // ✅ Send the block to pop_list (Now applies to normal and transformed blocks)
                var pop_info = {
                    x: i,
                    y: j,
                    gem_type: gem.type,
                    timer: 0,
                    start_delay: dist, // Wave effect
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
                player.grid[i, j].pop_timer = dist;
                var _pitch = clamp(1 + (0.2 * player.combo), 0.5, 5);

                audio_play_sound(snd_pre_bubble_pop_test, 10, false, 0.25, 0, _pitch);
                ds_list_add(player.pop_list, pop_info);
            }
        }
    }
   
    return found_any;
}
