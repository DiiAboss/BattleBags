

if (instance_exists(obj_upgrade_menu))
{
	global.in_upgrade_menu = true;
}
else
{
	global.in_upgrade_menu = false;
	// ✅ Toggle Pause with "P" key
	if (keyboard_check_pressed(ord("P"))) {
	    global.paused = !global.paused; // Toggle the pause state
	}

}

// ✅ Stop everything except the pause check
if (global.paused) || global.in_upgrade_menu {
	return;
}

// ------------------------------------------------------
// TIMERS AND SPEEDS
// ------------------------------------------------------
spawn_timer = 60 / global.gameSpeed;
shift_speed = 0.1 * global.gameSpeed;

update_time(self, FPS);

update_draw_time(self);

process_gameboard_speed(self);


//--------------------------------------------------------
// CONTROLS
//--------------------------------------------------------
mouse_dragged(self);

var hover_i = floor((mouse_x - board_x_offset) / gem_size);
var hover_j = floor((mouse_y - global_y_offset) / gem_size);

enable_debug_controls(self, hover_i, hover_j, true);

var enable_shake = fight_for_your_life;

process_grid_shake(enable_shake);


check_and_apply_upgrades(self);


process_experience_points(self, target_experience_points, 0.0025);
	
gem_shake(self);


if (swap_in_progress) {
    swap_info.progress += swap_info.speed;

    if (swap_info.progress >= 1) {
        swap_info.progress = 1;
		
        // Complete the swap in the grid
        var temp = grid[swap_info.from_x, swap_info.from_y];
        grid[swap_info.from_x, swap_info.from_y] = grid[swap_info.to_x, swap_info.to_y];
        grid[swap_info.to_x, swap_info.to_y] = temp;

        // Reset offsets for both cells
        grid[swap_info.from_x, swap_info.from_y].offset_x = 0;
        grid[swap_info.from_x, swap_info.from_y].offset_y = 0;
        grid[swap_info.to_x, swap_info.to_y].offset_x = 0;
        grid[swap_info.to_x, swap_info.to_y].offset_y = 0;

        // End swap
        swap_in_progress = false;
    } else {
        // Animate the swap
        var distance = gem_size * swap_info.progress;

        // Update offsets for smooth animation
        if (swap_info.from_x < swap_info.to_x) {
            grid[swap_info.from_x, swap_info.from_y].offset_x =  distance;
            grid[swap_info.to_x,   swap_info.to_y].offset_x   = -distance;
        } else if (swap_info.from_x > swap_info.to_x) {
            grid[swap_info.from_x, swap_info.from_y].offset_x = -distance;
            grid[swap_info.to_x,   swap_info.to_y].offset_x   =  distance;
        }
        if (swap_info.from_y < swap_info.to_y) {
            grid[swap_info.from_x, swap_info.from_y].offset_y =  distance;
            grid[swap_info.to_x,   swap_info.to_y].offset_y   = -distance;
        } else if (swap_info.from_y > swap_info.to_y) {
            grid[swap_info.from_x, swap_info.from_y].offset_y = -distance;
            grid[swap_info.to_x,   swap_info.to_y].offset_y   =  distance;
        }
    }
}




// ------------------------------------------------------
// SMOOTH UPWARD MOVEMENT + SHIFT
// ------------------------------------------------------
global_y_offset -= shift_speed;

if (global_y_offset <= -gem_size) {
    global_y_offset = 0;
    shift_up();
}

darken_bottom_row(self);


// 5️⃣ Update the topmost row tracking
update_topmost_row(self);

if (global.topmost_row <= 0) {
    check_game_over(self);
}

if (!swap_in_progress && all_blocks_landed(self)) {
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            grid[i, j].offset_x = 0;
            grid[i, j].offset_y = 0;
        }
    }
}

var j = 0;
var reset = true;
for (var i = 0; i < width; i++) {

        var gem = grid[i, 0]; // Retrieve the gem object

        // Ensure the cell contains a valid gem object
		if (gem.type != -1) && !gem.falling
		{	
				reset = false;
		}
}

if (reset)
{
	lose_life_timer = 0;
}

if (all_pops_finished()) {
	
    // ✅ Drop blocks **AFTER** all pops finish
    drop_blocks(self);

    // ✅ If a new match is found, **increase** combo instead of resetting
    if find_and_destroy_matches() {
		combo_timer = 0;
        combo += 1;
    } 
}

process_combo_timer_and_record_max(self);


update_freeze_timer(self);


for (var i = 0; i < width; i++) {
	if (grid[i, 1].type != -1 && !grid[i, 1].falling) { 
		var block_y = (1 * gem_size) + global_y_offset; // Actual Y position
		var progress = 1 - clamp(block_y / gem_size, 0, 1); // 0 = row 1, 1 = row 0
				
		if (progress > 0 && combo > 0)
		{
			fight_for_your_life = true;
		}
		else
		{
			fight_for_your_life = false;
		}
	} 
	else 
	{
			fight_for_your_life = false;
	}
}

// -----------------------------------------------------------------------
// FUNCTIONS
// -----------------------------------------------------------------------

function shift_up() {
    // 1️⃣ First, shift the main board up
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height - 1; j++) {
            grid[i, j] = grid[i, j + 1];             // Shift normal blocks up
            gem_y_offsets[i, j] = gem_y_offsets[i, j + 1]; // Carry offsets
        }
    }

    // 2️⃣ Now, shift all popping gems in `global.pop_list`
    for (var k = 0; k < ds_list_size(global.pop_list); k++) {
        var pop_data = ds_list_find_value(global.pop_list, k);
        
        // Move each popping gem up **one row**
        pop_data.y -= 1; // ✅ Keeps the gem's position in sync with the grid
        
        // Ensure we update the stored offset properly
        pop_data.y_offset_global = global_y_offset;
        
        // Save updated data back into `global.pop_list`
        ds_list_replace(global.pop_list, k, pop_data);
    }

    // 3️⃣ Spawn a new random row at the bottom
    for (var i = 0; i < width; i++) {
		grid[i, height - 1] = create_gem(BLOCK.RANDOM);
        gem_y_offsets[i, height - 1] = 0;
    }
	
    // 4️⃣ Reset alpha so the newly spawned row fades in again
    darken_alpha = 0;
}
	
function find_and_destroy_matches() {
    var marked_for_removal = array_create(width, height);
    var found_any = false;
    var first_found = false; // ✅ Track the first block in the combo
    var total_match_points = 0; // ✅ Accumulates points for multiple matches
	var black_blocks_to_transform = ds_list_create(); // ✅ Store black blocks that will transform

	
	global.black_blocks_to_transform = ds_list_create(); // ✅ Track black blocks to transform

    // Initialize the marked_for_removal array
    for (var xx = 0; xx < width; xx++) {
        for (var yy = 0; yy < height; yy++) {
            marked_for_removal[xx, yy] = false;
			
			if (grid[xx, yy].shake_timer > 0)
			{
				grid[xx, yy].popping = true;
			}
			
        }
    }

    // -------------------------
    // ✅ HORIZONTAL MATCHES
    // -------------------------
    for (var j = 0; j < height; j++) {
        var match_count = 1;
        var start_idx = 0;

        for (var i = 1; i < width; i++) {
            if (can_match(grid[i, j], grid[i - 1, j])) {
                if (match_count == 1) start_idx = i - 1;
                match_count++;
            } else {
                if (match_count >= 3) {
                    for (var k = 0; k < match_count; k++) {
                        var xx = start_idx + k;
                        if (xx >= 0 && xx < width) {
                            marked_for_removal[xx, j] = true;

                            if (!first_found) {
                                global.combo_x = xx;
                                global.combo_y = j;
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
                        global.combo_x = xx;
                        global.combo_y = j;
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

        for (var j = 1; j < height; j++) {
            if (can_match(grid[i, j], grid[i, j - 1])) {
                if (match_count == 1) start_idx = j - 1;
                match_count++;
            } else {
                if (match_count >= 3) {
                    for (var k = 0; k < match_count; k++) {
                        var yy = start_idx + k;
						
                        if (yy >= 0 && yy < height) {
                            marked_for_removal[i, yy] = true;

                            if (!first_found) {
                                global.combo_x = i;
                                global.combo_y = yy;
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
                if (yy >= 0 && yy < height) {
                    marked_for_removal[i, yy] = true;

                    if (!first_found) {
                        global.combo_x = i;
                        global.combo_y = yy;
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
    if (diagonal_matches) {
         //**↘ Diagonal Matches (Top-Left to Bottom-Right)**
        for (var j = 0; j < height - 2; j++) {
            for (var i = 0; i < width - 2; i++) {
                var match_count = 1;
                var _x = i, _y = j;
                while (_x + 1 < width && _y + 1 < height && can_match(grid[_x, _y], grid[_x + 1, _y + 1])) {
                    match_count++;
                    _x++; _y++;
                }
                if (match_count >= 3) mark_diagonal_match(marked_for_removal, i, j, match_count, "↘");
            }
        }
		
        //**↙ Diagonal Matches (Top-Right to Bottom-Left)**
        for (var j = 0; j < height - 2; j++) {
            for (var i = width - 1; i >= 2; i--) {
                var match_count = 1;
                var _x = i, _y = j;

                while (_x - 1 >= 0 && _y + 1 < height && can_match(grid[_x, _y], grid[_x - 1, _y + 1])) {
                    match_count++;
                    _x--; _y++;
                }

                if (match_count >= 3) mark_diagonal_match(marked_for_removal, i, j, match_count, "↙");
            }
        }
    }

    // -------------------------
    // ✅ HANDLE MATCHED GEMS
    // -------------------------
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            if (marked_for_removal[i, j]) {
                found_any = true;
                grid[i, j].shake_timer = max_shake_timer; // Start shaking effect
				
                var gem = grid[i, j];
				
                var dx = i - global.lastSwapX;
                var dy = j - global.lastSwapY;
                var dist = sqrt(dx * dx + dy * dy);
				var _start_delay = 5;
				
				if (gem.type == BLOCK.BLACK)
				{
					_start_delay = 20;
				}
				
				
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
                    y_offset_global: global_y_offset,
					match_size: match_count, // ✅ Store the match size
					match_points: total_match_points,
					bomb_tracker: false,               // Flag to mark this pop as bomb‐generated
					bomb_level: 0
                };
				
				//target_experience_points += (match_count + combo) + (global.modifier);

                grid[i, j].popping = true;
                grid[i, j].pop_timer = dist * _start_delay;

                ds_list_add(global.pop_list, pop_info);
            }
        }
    }
	
	// ✅ Transform black blocks **after matches are removed**
    update_black_blocks(self, black_blocks_to_transform);
    ds_list_destroy(black_blocks_to_transform);
	
    return found_any;
}


if all_blocks_landed(self) {
	
    for (var i = 0; i < ds_list_size(global.pop_list); i++) {
        var pop_data = ds_list_find_value(global.pop_list, i);
		
        // Wait for start_delay
        if (pop_data.timer < pop_data.start_delay) {
            pop_data.timer++;
			combo_timer = 0;

			var _x = pop_data.x;
            var _y = pop_data.y;
            var px = (_x * gem_size) + board_x_offset + offset;
            var py = (_y * gem_size) + offset + global_y_offset + gem_y_offsets[_x, _y];
			
			var _color = c_white;
			if (variable_struct_exists(pop_data, "color"))
			{
				_color = pop_data.color;
			}
			
			effect_create_depth(depth, ef_smoke, px, py - 4, 2, _color);
			
        } else {
            // Grow effect
            pop_data.scale += 0.05;
			
			
			
            // Once scale >= 1.1, pop is done
            if (pop_data.scale >= 1.1) {
                var _x = pop_data.x;
                var _y = pop_data.y;
                var px = (_x * gem_size) + board_x_offset + offset;
                var py = (_y * gem_size) + offset + global_y_offset + gem_y_offsets[_x, _y];

                // ✅ Store Gem Object Before Destroying
				if (self.grid[_x, _y] != -1)
				{
				   
				   var gem = self.grid[_x, _y];
				}
				else
				{
					return;
				}

					if (gem.powerup == POWERUP.MULTI_2X) total_multiplier_next *= 2;
	                //if (gem.powerup == POWERUP.MULTI_3X) total_multiplier *= 3;
	                // ✅ You can add more multipliers here later!

	                //Loop Through Multipliers
	                process_powerup(self, _x, _y, gem, total_multiplier_next);
					
					total_blocks_destroyed++;
					// **Destroy the block**
					destroy_block(self, _x, _y);
					
					// **Create visual effect**
	                effect_create_depth(depth, ef_firework, px, py - 4, 0.5, pop_data.color);

	                // ✅ Create Attack Object with Score
	                var attack = instance_create_depth(px, py, depth - 1, obj_player_attack);
	                attack.color = pop_data.color;
				
	                attack.damage = (pop_data.match_points / pop_data.match_size) * total_multiplier_next; // 🔥 **Apply multiplier to damage!**

	                // ✅ Add accumulated match points to total_points
	                total_points += attack.damage;

                // Remove from pop_list
                ds_list_delete(global.pop_list, i);
                i--; 
                continue;
            }
        }
		total_multiplier_next = 1;
        // Write back updated pop_data
        ds_list_replace(global.pop_list, i, pop_data);
    }
}




// If a swap is queued and the offset is above our threshold, execute it
if (self.global_y_offset >= 5 && global.swap_queue.active) {
    execute_swap(self, global.swap_queue.ax, global.swap_queue.ay, global.swap_queue.bx, global.swap_queue.by);
    global.swap_queue.active = false; // Clear the swap queue
}


	






