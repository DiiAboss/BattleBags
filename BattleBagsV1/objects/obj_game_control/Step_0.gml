

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



var enable_shake = fight_for_your_life;

process_grid_shake(enable_shake);


function play_next_song() {
    // ✅ Stop any currently playing music
    audio_stop_all();

    // ✅ Move to the next song in the list
    current_song += 1;

    // ✅ Loop back to the first song when reaching the end
    if (current_song >= array_length(songs)) {
        current_song = 0;
    }

    // ✅ Play the new song
    audio_play_sound(songs[current_song], true, false);
}

	if (!audio_is_playing(songs[current_song])) {
    play_next_song();
}
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

function process_console_command(cmd)
{
	/// process_console_command(cmd)

// Convert input to lowercase for consistency
cmd = string_lower(cmd);

// Store in history
array_insert(console_history, 0, cmd);
if (array_length(console_history) > max_history) {
    array_delete(console_history, max_history, 1);
}

// 📜 Process Commands
if (cmd == "clear") {
    console_history = [];
} 
else if (cmd == "showhealth") {
    array_insert(console_history, 0, "Health: " + string(player_health));
} 
else if (string_pos("sethealth ", cmd) == 1) {
    var value = real(string_delete(cmd, 1, 10)); // Remove "set_health " part
    if (is_real(value)) {
        global.player_health = value;
        array_insert(console_history, 0, "Player health set to: " + string(value));
    } else {
        array_insert(console_history, 0, "Invalid value.");
    }
} 
else if (cmd == "showmoney") {
    array_insert(console_history, 0, "Gold: " + string(global.gold));
}
else if (string_pos("setspeed ", cmd) == 1) {
    var value = real(string_delete(cmd, 1, 10)); 
    if (is_real(value)) {
        global.gameSpeed = value;
        array_insert(console_history, 0, "Game speed set to: " + string(value));
    }
}

else {
    array_insert(console_history, 0, "Unknown command: " + cmd);
}

}

function spawn_2x2_block(_self, _x, _y, _type) {
    if (_x < 0 || _x >= _self.width - 1 || _y < 0 || _y >= _self.height) return;

    // ✅ Generate unique, non-zero group_id
    var group_id;
    group_id = irandom_range(1, 999999); // ✅ No -1 or 0


    var big_gem = create_gem(_type);
    big_gem.is_big     = true;
    big_gem.group_id   = group_id;
    big_gem.big_parent = [_x, _y];

    _self.grid[_x, _y] = big_gem;

    var child_gem        = create_gem(_type);
    child_gem.is_big     = true;
    child_gem.group_id   = group_id;
    child_gem.big_parent = [_x, _y];

    _self.grid[_x + 1, _y] = child_gem;
    _self.grid[_x, _y + 1] = child_gem;
    _self.grid[_x + 1, _y + 1] = child_gem;
    
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
		    // ✅ Transition to fight music
	    if (global.music_fight == -1) {
	        global.music_fight = audio_play_sound(music_fast_music_test, 1, true);
	    }
    
	    global.music_fight_volume = min(global.music_fight_volume + global.music_fade_speed, 1);
	    global.music_regular_volume = max(global.music_regular_volume - global.music_fade_speed, 0);
    
	    // 🛑 Pause regular music if volume is 0
	    if (global.music_regular_volume <= 0 && global.music_regular != -1) {
	        audio_pause_sound(global.music_regular);
	    }
    
	    // ▶️ Resume fight music if it was paused
	    if (global.music_fight_volume > 0 && audio_is_paused(global.music_fight)) {
	        audio_resume_sound(global.music_fight);
	    }
				
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

	    // ✅ Transition back to regular music
	    if (global.music_regular == -1) {
	        global.music_regular = audio_play_sound(songs[current_song], 1, true);
	    }
    
	    global.music_regular_volume = min(global.music_regular_volume + global.music_fade_speed, 1);
	    global.music_fight_volume = max(global.music_fight_volume - global.music_fade_speed, 0);
    
	    // 🛑 Pause fight music if volume is 0
	    if (global.music_fight_volume <= 0 && global.music_fight != -1) {
	        audio_pause_sound(global.music_fight);
	    }
    
	    // ▶️ Resume regular music if it was paused
	    if (global.music_regular_volume > 0 && audio_is_paused(global.music_regular)) {
	        audio_resume_sound(global.music_regular);
	    }
	}
}


// 🎚 Apply volume settings
if (global.music_regular != -1) audio_sound_gain(global.music_regular, global.music_regular_volume, 0);
if (global.music_fight != -1) audio_sound_gain(global.music_fight, global.music_fight_volume, 0);


// -----------------------------------------------------------------------
// FUNCTIONS
// -----------------------------------------------------------------------

function shift_up() {
    // 1️⃣ Process from bottom to top
    for (var j = 0; j < height - 1; j++) {
        for (var i = 0; i < width; i++) {
            var gem = grid[i, j + 1];

            // ✅ If it's part of a big block, check if it needs bottom row
            if (gem.is_big) {
                var parent_x = gem.big_parent[0];
                var parent_y = gem.big_parent[1];

                // ✅ Only process the parent block
                if (i == parent_x && j + 1 == parent_y) {
                    var new_y = parent_y - 1;

                    // ✅ Move entire 2x2 block up
                    grid[parent_x,     new_y]    = grid[parent_x,     parent_y];
                    grid[parent_x + 1, new_y]    = grid[parent_x + 1, parent_y];
                    grid[parent_x,     parent_y] = grid[parent_x,     parent_y + 1];
                    grid[parent_x + 1, parent_y] = grid[parent_x + 1, parent_y + 1];

                    // ✅ Update `big_parent`
                    grid[parent_x,     new_y].big_parent     = [parent_x, new_y];
                    grid[parent_x + 1, new_y].big_parent     = [parent_x, new_y];
                    grid[parent_x,     new_y + 1].big_parent = [parent_x, new_y];
                    grid[parent_x + 1, new_y + 1].big_parent = [parent_x, new_y];

                    // ✅ Mark as "big"
                    grid[parent_x,     new_y].is_big     = true;
                    grid[parent_x + 1, new_y].is_big     = true;
                    grid[parent_x,     new_y + 1].is_big = true;
                    grid[parent_x + 1, new_y + 1].is_big = true;

                    // ✅ Clear space below if the block was at row 15
                    if (new_y == height - 3) {
                        grid[parent_x,     height ] = create_gem(BLOCK.RANDOM);
                        grid[parent_x + 1, height ] = create_gem(BLOCK.RANDOM);
                    }
                }
            } 
            // ✅ Normal gem movement
            grid[i, j] = grid[i, j + 1];  
            
            // ✅ Carry offsets properly
            //gem_y_offsets[i, j] = gem_y_offsets[i, j + 1];
			
        }
    }
	


    // 2️⃣ Shift all popping gems in `global.pop_list`
    for (var k = 0; k < ds_list_size(global.pop_list); k++) {
        var pop_data = ds_list_find_value(global.pop_list, k);
        
        // ✅ Move each popping gem up **one row**
        pop_data.y -= 1;
        pop_data.y_offset_global = global_y_offset;
        
        ds_list_replace(global.pop_list, k, pop_data);
    }

    // 3️⃣ Spawn a new random row at the bottom **EXCLUDING BIG BLOCKS**
    for (var i = 0; i < width; i++) {
        // ✅ Ensure **only spawn new blocks if no big blocks are present**
            grid[i, height - 1] = create_gem(BLOCK.RANDOM);
    }

    // 4️⃣ Reset darken alpha so the new row fades in again
    darken_alpha = 0;
}

			


function check_puzzle_match(_self, _x, _y) {
    // ✅ Bounds check (to avoid out-of-grid errors)
    if (_x < 0 || _x >= _self.width - 1 || _y < 0 || _y >= _self.height - 1) return false;

    // ✅ Retrieve 4 adjacent blocks
    var gem_0 = _self.grid[_x, _y];         // Top-left
    var gem_1 = _self.grid[_x + 1, _y];     // Top-right
    var gem_2 = _self.grid[_x, _y + 1];     // Bottom-left
    var gem_3 = _self.grid[_x + 1, _y + 1]; // Bottom-right

    // ✅ Check if all blocks are `BLOCK.PUZZLE_1`
    if (gem_0.type != BLOCK.PUZZLE_1 || gem_1.type != BLOCK.PUZZLE_1 ||
        gem_2.type != BLOCK.PUZZLE_1 || gem_3.type != BLOCK.PUZZLE_1) {
        return false;
    }


    // ✅ Ensure they match the correct `img_number` pattern
    if (gem_0.img_number == 0 && gem_1.img_number == 1 &&
        gem_2.img_number == 2 && gem_3.img_number == 3) {
        return true; // ✅ Match Found!
    }

    return false; // ❌ No match
}

function find_all_puzzle_matches(_self) {
    for (var _x = 0; _x < _self.width - 1; _x++) {
        for (var _y = 0; _y < _self.height - 1; _y++) {
            if (check_puzzle_match(_self, _x, _y)) {
                // ✅ Trigger match event (Destroy, transform, etc.)
                handle_puzzle_match(_self, _x, _y);
            }
        }
    }
}
find_all_puzzle_matches(self);

function handle_puzzle_match(_self, _x, _y) {
    // ✅ Retrieve the matched blocks
    var gem_0 = _self.grid[_x, _y];
    var gem_1 = _self.grid[_x + 1, _y];
    var gem_2 = _self.grid[_x, _y + 1];
    var gem_3 = _self.grid[_x + 1, _y + 1];
	
	var _start_delay = 20;
	var dx = _x - global.lastSwapX;
	var dy = _y - global.lastSwapY;
	var dist = sqrt(dx * dx + dy * dy);
    // ✅ Mark blocks for destruction
    gem_0.popping = true;
    gem_1.popping = true;
    gem_2.popping = true;
    gem_3.popping = true;
	
    // ✅ Send the block to pop_list (Now applies to normal and transformed blocks)
	var pop_info = {
	    x: _x,
	    y: _y,
	    gem_type: gem_0.type,
	    timer: 0,
	    start_delay: dist * _start_delay, // Wave effect
	    scale: 1.0,
	    popping: true,
	    powerup: gem_0.powerup,
	    dir: gem_0.dir,
	    offset_x: gem_0.offset_x,
	    offset_y: gem_0.offset_y,
	    color: gem_0.color,
	    y_offset_global: global_y_offset,
	    match_size: 1, // ✅ Store the match size
	    match_points: 1,
	    bomb_tracker: false, // Flag to mark this pop as bomb‐generated
	    bomb_level: 0,
		img_number: gem_0.img_number,
	};

	_self.grid[_x, _y].popping   = true;
	_self.grid[_x, _y].pop_timer = dist * _start_delay;
	ds_list_add(global.pop_list, pop_info);
	
		var pop_info = {
	    x: _x + 1,
	    y: _y,
	    gem_type: gem_1.type,
	    timer: 0,
	    start_delay: dist * _start_delay, // Wave effect
	    scale: 1.0,
	    popping: true,
	    powerup: gem_1.powerup,
	    dir: gem_1.dir,
	    offset_x: gem_1.offset_x,
	    offset_y: gem_1.offset_y,
	    color: gem_1.color,
	    y_offset_global: global_y_offset,
	    match_size: 1, // ✅ Store the match size
	    match_points: 1,
	    bomb_tracker: false, // Flag to mark this pop as bomb‐generated
	    bomb_level: 0,
		img_number: gem_1.img_number,
	};
		_self.grid[_x + 1, _y].popping   = true;	
	_self.grid[_x + 1, _y].pop_timer = dist * _start_delay;
	ds_list_add(global.pop_list, pop_info);
	
		var pop_info = {
	    x: _x,
	    y: _y + 1,
	    gem_type: gem_2.type,
	    timer: 0,
	    start_delay: dist * _start_delay, // Wave effect
	    scale: 1.0,
	    popping: true,
	    powerup: gem_2.powerup,
	    dir: gem_2.dir,
	    offset_x: gem_2.offset_x,
	    offset_y: gem_2.offset_y,
	    color: gem_2.color,
	    y_offset_global: global_y_offset,
	    match_size: 1, // ✅ Store the match size
	    match_points: 1,
	    bomb_tracker: false, // Flag to mark this pop as bomb‐generated
	    bomb_level: 0,
		img_number: gem_2.img_number,
	};
		_self.grid[_x, _y + 1].popping   = true;
	_self.grid[_x, _y + 1].pop_timer = dist * _start_delay;
	ds_list_add(global.pop_list, pop_info);
	
		var pop_info = {
	    x: _x + 1,
	    y: _y + 1,
	    gem_type: gem_3.type,
	    timer: 0,
	    start_delay: dist * _start_delay, // Wave effect
	    scale: 1.0,
	    popping: true,
	    powerup: gem_3.powerup,
	    dir: gem_3.dir,
	    offset_x: gem_3.offset_x,
	    offset_y: gem_3.offset_y,
	    color: gem_3.color,
	    y_offset_global: global_y_offset,
	    match_size: 1, // ✅ Store the match size
	    match_points: 1,
	    bomb_tracker: false, // Flag to mark this pop as bomb‐generated
	    bomb_level: 0,
		img_number: gem_3.img_number,
	};
		_self.grid[_x + 1, _y + 1].popping   = true;	
	_self.grid[_x + 1, _y + 1].pop_timer = dist * _start_delay;
ds_list_add(global.pop_list, pop_info);


	destroy_block(self, _x, + 1, _y + 1);
	destroy_block(self, _x, _y);
	destroy_block(self, _x, _y + 1);
	destroy_block(self, _x + 1, _y);
    //// ✅ Optional: Replace with another block (e.g., special reward block)
    //_self.grid[_x, _y] = create_gem(BLOCK.PUZZLE_1);
    //_self.grid[_x + 1, _y] = create_gem(BLOCK.PUZZLE_1);
    //_self.grid[_x, _y + 1] = create_gem(BLOCK.PUZZLE_1);
    //_self.grid[_x + 1, _y + 1] = create_gem(BLOCK.PUZZLE_1);

    // ✅ Create a "match detected" effect (placeholder method)
    //trigger_effect(_x, _y);
}


	
function find_and_destroy_matches() {
    var marked_for_removal	 = array_create(width, height);
    var found_any			 = false;
    var first_found			 = false; // ✅ Track the first block in the combo
    var total_match_points	 = 0;     // ✅ Accumulates points for multiple matches
	
	
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
	 diagonal_match_process(self, diagonal_matches);
	 
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
	            var _start_delay = (gem.type == BLOCK.BLACK) ? 20 : 5; // Longer delay for black blocks
			
	            // ✅ If it's a BIG BLOCK, transform it into separate blocks
	            if (gem.is_big) {
	                var group_id = gem.group_id;

	                for (var _x = 0; _x < width; _x++) {
	                    for (var _y = 0; _y < height; _y++) {
	                        var other_gem = grid[_x, _y];

	                        if (other_gem.group_id == group_id) {
	                            // ✅ Convert each big block part into a small block of the same type
	                            grid[_x, _y] = create_gem(gem.type);						
							
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
					                y_offset_global: global_y_offset,
					                match_size: match_count, // ✅ Store the match size
					                match_points: total_match_points,
					                bomb_tracker: false, // Flag to mark this pop as bomb‐generated
					                bomb_level: 0,
									img_number: gem.img_number,
					            };
							
	                            grid[_x, _y].popping   = true;  // Start popping process
	                            grid[_x, _y].pop_timer = dist * _start_delay;
								
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
	                y_offset_global: global_y_offset,
	                match_size: match_count, // ✅ Store the match size
	                match_points: total_match_points,
	                bomb_tracker: false, // Flag to mark this pop as bomb‐generated
	                bomb_level: 0,
					img_number: gem.img_number,
	            };

	            grid[i, j].popping   = true;
	            grid[i, j].pop_timer = dist * _start_delay;
					var _pitch = clamp(1 + (0.2 * combo), 0.5, 5);
					audio_play_sound(snd_pre_bubble_pop_test, 10, false, 0.25, 0, _pitch);
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






function create_puzzle_gem(_type, _group_id, _img_number) {
    var gem = create_gem(_type);
    gem.group_id = _group_id;
    gem.img_number = _img_number;
    return gem;
}
	
function spawn_puzzle_blocks(_self) {
    var width = _self.width;
    var height = _self.height;
    
    // ✅ Store 4 unique positions
    var random_pos_array = [];

    while (array_length(random_pos_array) < 4) {
        var start_x = irandom_range(0, width - 1);
        var start_y = irandom_range(0, height - 1);
        var position = [start_x, start_y];

        // 🔹 Ensure position is unique
        var is_duplicate = false;
        for (var i = 0; i < array_length(random_pos_array); i++) {
            if (random_pos_array[i][0] == start_x && random_pos_array[i][1] == start_y) {
                is_duplicate = true;
                break;
            }
        }

        if (!is_duplicate && _self.grid[start_x, start_y].type != BLOCK.PUZZLE_1) {
            array_push(random_pos_array, position);
        }
    }

    // ✅ Generate unique group_id
    var group_id = irandom_range(1, 999999);

    // ✅ Assign the puzzle gems using the unique positions
    for (var i = 0; i < 4; i++) {
        var _x = random_pos_array[i][0];
        var _y = random_pos_array[i][1];

        _self.grid[_x, _y] = create_puzzle_gem(BLOCK.PUZZLE_1, group_id, i);
    }

    return true;
}


if (keyboard_check_pressed(vk_tab))
{
	spawn_puzzle_blocks(self);
}




