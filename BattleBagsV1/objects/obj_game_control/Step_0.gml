

var exp_inc = 0.0025;

if (instance_exists(obj_upgrade_menu))
{
	global.in_upgrade_menu = true;
	exp_inc = 1;
}
else
{
	if (target_level <= 0)
	{
		if (after_menu_counter < after_menu_counter_max)
		{
			after_menu_counter += 1;
		}
		else
		{
			after_menu_counter = after_menu_counter_max;
				global.in_upgrade_menu = false;
			//✅ Toggle Pause with "P" key
			if (keyboard_check_pressed(ord("P"))) {
			    global.paused = !global.paused; // Toggle the pause state
			}
		}
	}
	else
	{

		check_and_apply_upgrades(self);

	}
}
process_experience_points(self, target_experience_points, exp_inc);

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

process_grid_shake(fight_for_your_life);

gem_shake(self);





if (global.swap_queue.active) {
    // ✅ Make sure we only shift the row if a swap was NOT already shifted
    if (_self.global_y_offset == 0) {
        global.swap_queue.ay -= 1;
        global.swap_queue.by -= 1;
    }

    // ✅ Execute the swap AFTER adjusting its position
    execute_swap(self, global.swap_queue.ax, global.swap_queue.ay, global.swap_queue.bx, global.swap_queue.by);
    
    global.swap_queue.active = false; // Clear the swap queue
}


if (swap_in_progress) {
    swap_info.progress += swap_info.speed;

    // 🛑 Check if the swap is happening **mid-shift** (before progress reaches 1)
    if (swap_info.progress < 1 && global_y_offset == 0) {
        // 🔹 Move swap targets UP by one row since the board just shifted
        swap_info.from_y -= 1;
        swap_info.to_y -= 1;
    }

    if (swap_info.progress >= 1) {
        swap_info.progress = 1;

        // ✅ Ensure the swap happens at the correct row based on whether we just shifted
        if (global_y_offset != 0) {
            var temp = grid[swap_info.from_x, swap_info.from_y];
            grid[swap_info.from_x, swap_info.from_y] = grid[swap_info.to_x, swap_info.to_y];
            grid[swap_info.to_x, swap_info.to_y] = temp;
        } else {
            // 🔹 If the board just moved up, apply the swap **one row higher**
            var temp = grid[swap_info.from_x, swap_info.from_y - 1];
            grid[swap_info.from_x, swap_info.from_y - 1] = grid[swap_info.to_x, swap_info.to_y - 1];
            grid[swap_info.to_x, swap_info.to_y - 1] = temp;
        }

        // Reset offsets
        grid[swap_info.from_x, swap_info.from_y].offset_x = 0;
        grid[swap_info.from_x, swap_info.from_y].offset_y = 0;
        grid[swap_info.to_x, swap_info.to_y].offset_x = 0;
        grid[swap_info.to_x, swap_info.to_y].offset_y = 0;

        swap_in_progress = false;
    } else {
        // Animate the swap
        var distance = gem_size * swap_info.progress;

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



// Toggle Console On/Off
if (keyboard_check_pressed(vk_f1)) { 
    console_active = !console_active;
}

// If Console is Active, Process Input
if (console_active) {
    // Handle Backspace
    if (keyboard_check_pressed(vk_backspace)) {
        if (string_length(console_input) > 0) {
            console_input = string_copy(console_input, 1, string_length(console_input) - 1);
        }
    }

    // Handle Enter Key (Execute Command)
    if (keyboard_check_pressed(vk_enter)) {
        process_console_command(console_input);
        console_input = ""; // Clear after execution
    }
    // 🖊 Handle Typing Input (One Character Per Press)
    for (var i = 32; i <= 126; i++) { // ASCII Range for printable characters
        if (keyboard_check_pressed(i)) {
            if (string_length(console_input) < 50) {
                console_input += chr(i); // Convert ASCII code to character
            }
        }
    }
}
else
{
	enable_debug_controls(self, hover_i, hover_j, true);	
}


// ------------------------------------------------------
// SMOOTH UPWARD MOVEMENT + SHIFT
// ------------------------------------------------------
global_y_offset -= shift_speed;

if (global_y_offset <= -gem_size) {
    global_y_offset = 0;
    shift_up(self);
}

darken_bottom_row(self);

// 5️⃣ Update the topmost row tracking
update_topmost_row(self);


var reset = true;
if (global.topmost_row <= top_playable_row) {
    check_game_over(self);
	reset = false;
}

if (reset)
{
	lose_life_timer = 0;
}

if (!swap_in_progress && all_blocks_landed(self)) {
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            grid[i, j].offset_x = 0;
            grid[i, j].offset_y = 0;
        }
    }
}


drop_blocks(self);

if (all_pops_finished()) {
	
    // ✅ Drop blocks **AFTER** all pops finish
    

    // ✅ If a new match is found, **increase** combo instead of resetting
    if find_and_destroy_matches(self) {
		combo_timer = 0;
        combo += 1;
    } 
}


process_combo_timer_and_record_max(self);

update_freeze_timer(self);

find_all_puzzle_matches(self);	

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


if (fight_for_your_life)
{
	transition_to_fast_song();	
}
else
{
	transition_to_regular_song(songs[current_song]);  
}

// Apply volume settings
apply_volume_settings();
process_play_next_song(songs[current_song]);

// -----------------------------------------------------------------------
// FUNCTIONS
// -----------------------------------------------------------------------

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
            var py = (_y * gem_size) + offset + global_y_offset;
			
			var _color = c_white;
			if (variable_struct_exists(pop_data, "color"))
			{
				_color = pop_data.color;
			}
			
			effect_create_depth(depth + 1, ef_smoke, px, py - 4, 2, _color);
			
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

					if (gem.powerup == POWERUP.MULTI_2X) total_multiplier_next *= 2

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
					
					var _pitch = clamp(0.5 + (0.1 * combo), 0.5, 5);
					var _gain = clamp(0.5 + (0.1 * combo), 0.5, 0.75);
					
                
				audio_play_sound(snd_pop_test_1, 10, false, _gain, 0, _pitch);
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