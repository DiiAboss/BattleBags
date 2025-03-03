

uOuterIntensity        = max(0, uOuterIntensity + (keyboard_check(ord("W")) - keyboard_check(ord("Q"))) * .01);
uInnerIntensity        = max(0, uInnerIntensity + (keyboard_check(ord("S")) - keyboard_check(ord("A"))) * .01);
uInnerLengthMultiplier = max(0, uInnerLengthMultiplier + (keyboard_check(ord("C")) - keyboard_check(ord("X"))) * .01);

//------------------------------------------
// INPUT MANAGER (GAME_MANAGER CONTROLLED)
//------------------------------------------
var input = obj_game_manager.input;
input.Update(self, last_position[0], last_position[1]);

geogrid.geogrid_update(self, input);
//------------------------------------------
// GAME OVER STATE
//------------------------------------------
game_over_screen(self, game_over_state);

if (game_over_state)
{
    // This is very crude and will be updated with all audio functions later on.
    audio_stop_sound(songs[current_song]);
    audio_stop_sound(global.music_fight);
    audio_stop_sound(global.music_regular);
    return;
}

//-----------------------------------------
// VICTORY STATE
//-----------------------------------------
if (victory_state)
{
    if (combo <= 0)
    {
        if (victory_countdown > 0)
        {
            victory_alpha = 1 - victory_countdown / victory_max_countdown;
            victory_countdown --;
            return;
        }
        else {
            victory_countdown = 0;
            
            
            
            if (input.ActionPress)
            {
                room_restart();
            }
        }
    }
}

//------------------------------------------------
// Leveling and Upgrades
//------------------------------------------------
var in_menu = instance_exists(obj_upgrade_menu); // optimize
process_upgrades(self, in_menu, input);

//------------------------------------------------------
// PAUSE THE GAME
//------------------------------------------------------
if (global.paused) || global.in_upgrade_menu {
	return;
}

// ------------------------------------------------------
// TIMERS AND SPEEDS
// ------------------------------------------------------
spawn_timer = 60 / global.gameSpeed;
shift_speed = 0.1 * global.gameSpeed;

update_time(self, _FPS);

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
    is_targeting_enemy = mouse_x > board_x_offset + (gem_size * width) + 256;    
}

process_inputs_and_delay(self, input);

// Enemy Targetting System
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

//----------------------------------------------------------
// GRID SHAKE and GEM SHAKE
//-----------------------------------------------------------
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
    
    shift_up(self);
    last_position[1] -= 1;
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

drop_blocks(self);

// Have to find a way to drop blocks while locking in matches
if (all_pops_finished() && !victory_state) {
    
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


if (keyboard_check_pressed(vk_tab))
{
    if (effect < 3)
    {
        effect++;
    }
    else {
        effect = 0;
    }
}