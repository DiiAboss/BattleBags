uOuterIntensity        = max(0, uOuterIntensity + (keyboard_check(ord("W")) - keyboard_check(ord("Q"))) * .01);
uInnerIntensity        = max(0, uInnerIntensity + (keyboard_check(ord("S")) - keyboard_check(ord("A"))) * .01);
uInnerLengthMultiplier = max(0, uInnerLengthMultiplier + (keyboard_check(ord("C")) - keyboard_check(ord("X"))) * .01);

if (instance_exists(obj_recycler))
{
    recycler = obj_recycler;
}


//------------------------------------------
// INPUT MANAGER (GAME_MANAGER CONTROLLED)
//------------------------------------------
var input = obj_game_manager.input;
input.Update(self, last_position[0], last_position[1]);

//geogrid.geogrid_update(self, input);
//------------------------------------------
// GAME OVER STATE
//------------------------------------------
game_over_screen(self, game_over_state);

if (game_over_state)
{
    // This is very crude and will be updated with all audio functions later on.

    alarm[0] = scan_board;
    return;
}

function set_paused()
{
    if (after_menu_counter != after_menu_counter_max) || instance_exists(obj_upgrade_menu) || instance_exists(obj_shop_controller) 
    {
        global.paused = true;
    }
    else {
        if (global.paused)
        {
            global.paused = false;
        }
        else {
            global.paused = true;
        }
    }   
}

if (keyboard_check_pressed(vk_escape))
{
    set_paused();
}



//-----------------------------------------
// VICTORY STATE
//-----------------------------------------

// This should only play after a battle.
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
var in_menu = instance_exists(obj_upgrade_menu) || instance_exists(obj_shop_controller) ; // optimize
//process_upgrades(self, in_menu, input);

//------------------------------------------------------
// PAUSE THE GAME
//------------------------------------------------------
if (global.paused){
	return;
}



//----------------------------------------------------------
// DRONE CONTROLLER
//----------------------------------------------------------
for (var d = 0; d< number_of_drones; d++)
{
    drone_array[d].update();
    
}


// ------------------------------------------------------
// TIMERS AND SPEEDS
// ------------------------------------------------------
spawn_timer = 60 / global.gameSpeed;
shift_speed = 0.1 * global.gameSpeed;

update_time(self, _FPS);

update_draw_time(self);

global.modifier = game_speed_default / game_speed_start;

// Speed up gameboard with space bar





//--------------------------------------------------------
// CONTROLS
//--------------------------------------------------------

if (input.InputType == INPUT.GAMEPAD)
{
    control_mode = "legacy";
    //is_targeting_enemy = input.CycleSkillUp;
}
else 
{
    control_mode = "modern";
    //is_targeting_enemy = mouse_x > board_x_offset + (gem_size * width) + 256;    
}



// Enemy Targetting System
//process_targetting_enemy(self, input, enemy_control, is_targeting_enemy);


if (control_mode == "modern") {
    block_dragged(self, input.ActionPress, input.ActionKey, input.ActionRelease);
} else if (control_mode == "legacy") {
    mouse_legacy_swap(self, input.ActionPress);
}

swap_queue_array = [];



hover_x = floor((mouse_x - board_x_offset) / gem_size);
hover_y = floor((mouse_y - global_y_offset) / gem_size);
if (input.InputType == INPUT.GAMEPAD)
{
    hover_x = last_position[0];
    hover_y = last_position[1];
}
process_inputs_and_delay(self, input);
process_gameboard_speed(self, input.SpeedUpKey);





process_all_mega_blocks(self);

if (!obj_game_manager.console_active)
{
    enable_debug_controls(self, hover_x, hover_y, true);	
}




// ------------------------------------------------------
// SMOOTH UPWARD MOVEMENT + SHIFT
// ------------------------------------------------------
if (global_y_offset <= -gem_size) {
    global_y_offset = 0;
    just_shifted = true;
    speed_up_delay = 0;
    shift_up(self);
    last_position[1] -= 1;
    var number_per_big_block = 2;
    
    //SCAN TOP TO BOTTOM
    
    big_block_types_on_grid = [];
    scan_board_for_big_blocks(self);

    show_debug_message("Big Block Array Len: "+ string(array_length(big_block_types_on_grid)));
    // Apply bonuses based on detected big blocks
    for (var i = 0; i < array_length(big_block_types_on_grid); i++) {
        var block_type = big_block_types_on_grid[i];
        show_debug_message("Block Type: "+ string(block_type));
        var positions_excluding_big_block_types = return_bottom_row_positions_of_types_excluding(self, block_type);
        
        var _rand = irandom(array_length(positions_excluding_big_block_types) - 1);
        show_debug_message("Rand Pos: "+ string(_rand));
        grid[_rand, bottom_playable_row].type = block_type;
        
    }
    // Update the topmost row tracking
    update_topmost_row(self);
    
}
else
{
    //regular shift speeds
    global_y_offset -= shift_speed;
    // process and swaps i nthe queue
    drop_blocks(self);
    process_swap(self, swap_info);
    
}


darken_bottom_row(self);

var reset = true;

if (topmost_row < top_playable_row) {
    check_game_over(self);
	reset = false;
}

if (reset)
{
	lose_life_timer = 0;
}



// Have to find a way to drop blocks while locking in matches
if (all_pops_finished(self) && !victory_state) {

	// ✅ If a new match is found, **increase** combo instead of resetting
	if find_and_destroy_matches(self) {
		combo_timer = 0;
		combo += 1;
        
        if (combo_points < max_combo_points)
        {
            combo_points ++;
        }
	}	
    
    // Update the topmost row tracking
    update_topmost_row(self);
}

process_combo_timer_and_record_max(self);

update_freeze_timer(self);

find_all_puzzle_matches(self);

fight_for_your_life = process_fight_for_your_life(self, top_playable_row + 1);


//if (fight_for_your_life)
//{
	//transition_to_fast_song();	
//}
//else
//{
	//transition_to_regular_song(songs[current_song]);  
//}

// Apply volume settings
//apply_volume_settings();
//process_play_next_song(songs[current_song]);


//----------------------------------------------------------
// GRID SHAKE and GEM SHAKE
//-----------------------------------------------------------
process_grid_shake(fight_for_your_life, grid_shake_amount);

gem_shake(self);


var dist = -1;
for (var u = 0; u < array_length(powerup_slots); u++)
{
    if (powerup_slots[u] != -1)
    {
        var u_slot = powerup_slots[u];
        var current_x = u_slot.x_pos;
        var target_x = (u_slot.lane * 64) + (board_x_offset + offset);
        dist = current_x - target_x > dist ? current_x - target_x : dist;
        
        if (current_x - 4 <= target_x)
        {
            current_x = target_x;
            powerup_slots[u].angle = 0;
            var grid_slot = grid[u_slot.lane, bottom_playable_row];
            if (grid_slot.type != BLOCK.NONE) && !grid_slot.popping && powerup_slots[u].angle == 0
            {
                if (global_y_offset - shift_speed < -32)
                {
                   grid[u_slot.lane, bottom_playable_row].powerup = create_powerup(u_slot.value);
                    powerup_slots[u] = -1;
                }
            }
            
            continue;
        }
        else
        {
            if ((current_x - target_x) > dist) dist = current_x - target_x;
            var time = 30;
            var x_speed = ((current_x - target_x) / time);
            powerup_slots[u].x_pos -= x_speed;
            powerup_slots[u].angle += (360/dist);
            continue;
        }
    }
}
alarm[0] = -global_y_offset;

for (var _x = 0; _x < board_width - 1; _x++)
{
    for (var _y = board_height - 1; _y > 1; _y--)
    {
       if (grid[_x, _y].type == BLOCK.BUG)
        {
            
        } 
    }
}


if (next_event_timer < next_event_timer_max)
{
   next_event_timer += 1; 
    
    time_till_next_event = (next_event_timer / fps);
}
else {
    next_event_timer = 0;
}


