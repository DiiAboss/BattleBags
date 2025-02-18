
var input = obj_game_manager.input;
input.Update(self, last_position[0], last_position[1]);



game_over_screen(self, game_over_state);

if (game_over_state)
{
    audio_stop_sound(songs[current_song]);
    audio_stop_sound(global.music_fight);
    audio_stop_sound(global.music_regular);
    return;
}

//------------------------------------------------
// Leveling and Upgrades
//------------------------------------------------
if (instance_exists(obj_upgrade_menu))
{
	global.in_upgrade_menu = true;
	var exp_inc = 1;
}
else
{
    var exp_inc = 0.0025;
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
			if (input.Escape) {
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

process_gameboard_speed(self, input.SpeedUpKey);

//--------------------------------------------------------
// CONTROLS
//--------------------------------------------------------
if (input.InputType == INPUT.GAMEPAD)
{
    control_mode = "legacy";
    is_targeting_enemy = input.CycleSkillUp;
}
else 
{
    control_mode = "modern";
    is_targeting_enemy = mouse_x > board_x_offset + (gem_size * width) + 128;    
}

process_inputs_and_delay(self, input);



process_targetting_enemy(self, input, enemy_control, is_targeting_enemy);





if (control_mode == "modern") {
    block_dragged(self, input.ActionPress, input.ActionKey, input.ActionRelease);
} else if (control_mode == "legacy") {
    mouse_legacy_swap(self, input.ActionPress);
}


hover_x = floor((mouse_x - board_x_offset) / gem_size);
hover_y = floor((mouse_y - global_y_offset) / gem_size);
if (input.InputType == INPUT.GAMEPAD)
{
    hover_x = last_position[0];
    hover_y = last_position[1];
}


process_grid_shake(fight_for_your_life);

gem_shake(self);


process_all_mega_blocks(self);


if (!obj_game_manager.console_active)
{
    enable_debug_controls(self, hover_x, hover_y, true);	
}

process_swap(self, swap_info);


// ------------------------------------------------------
// SMOOTH UPWARD MOVEMENT + SHIFT
// ------------------------------------------------------
global_y_offset -= shift_speed;

if (global_y_offset <= -gem_size) {
    global_y_offset = 0;
    last_position[1] -= 1;
    shift_up(self);
}


darken_bottom_row(self);

// Update the topmost row tracking
update_topmost_row(self);


var reset = true;

if (global.topmost_row < top_playable_row) {
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


// Have to find a way to drop blocks while locking in matches
if (all_pops_finished()) {
    
	drop_blocks(self);
	// ✅ If a new match is found, **increase** combo instead of resetting
	if find_and_destroy_matches(self) {
		combo_timer = 0;
		combo += 1;
        
        if (combo_points < max_combo_points)
        {
            combo_points ++;
        }
	}	
}



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
            var py = (_y * gem_size) + offset + global_y_offset;// + gem_y_offsets[_x, _y];

            // ✅ Store Gem Object Before Destroying
			if (self.grid[_x, _y] == -1) return;
			
            
            var gem = self.grid[_x, _y];
    
            if (gem.powerup == POWERUP.MULTI_2X) total_multiplier_next *= 2;

            //Loop Through Multipliers
            process_powerup(self, _x, _y, gem, total_multiplier_next);
                
            total_blocks_destroyed++;
            
            // **Destroy the block**
            destroy_block(self, _x, _y);
                
            // **Create visual effect**
            effect_create_depth(depth, ef_firework, px, py - 4, 0.5, pop_data.color);

            var damage = (pop_data.match_points / pop_data.match_size) * total_multiplier_next;
            
            create_attack_projectile(px, py, pop_data.color, damage)

            // ✅ Add accumulated match points to total_points
            total_points += damage;
                
            var _pitch = clamp(0.5 + (0.1 * combo), 0.5, 5);
            var _gain = clamp(0.5 + (0.1 * combo), 0.5, 0.75);
					
            if !(game_over_state)
            {
                audio_play_sound(snd_pop_test_1, 10, false, _gain, 0, _pitch);
            }
			 
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


process_combo_timer_and_record_max(self);

update_freeze_timer(self);

find_all_puzzle_matches(self);	


fight_for_your_life = process_fight_for_your_life(self, top_playable_row + 1);



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
