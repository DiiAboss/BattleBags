

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

//--------------------------------------------------------
// CONTROLS
//--------------------------------------------------------
mouse_dragged(self);

var hover_i = floor((mouse_x - board_x_offset) / gem_size);
var hover_j = floor((mouse_y - global_y_offset) / gem_size);


// 🌟 Horizontal Destruction
if (keyboard_check_pressed(ord("L"))) { 
    destroy_blocks_in_direction_from_point(self, hover_i, hover_j, +1, 0); // 🔴 Right
}
if (keyboard_check_pressed(ord("J"))) { 
    destroy_blocks_in_direction_from_point(self, hover_i, hover_j, -1, 0); // 🔵 Left
}

// 🌟 Vertical Destruction
if (keyboard_check_pressed(ord("I"))) { 
    destroy_blocks_in_direction_from_point(self, hover_i, hover_j, 0, -1); // 🔼 Up
}
if (keyboard_check_pressed(ord("K"))) { 
    destroy_blocks_in_direction_from_point(self, hover_i, hover_j, 0, +1); // 🔽 Down
}

// 🌟 Diagonal Destruction
if (keyboard_check_pressed(ord("U"))) { 
    destroy_blocks_in_direction_from_point(self, hover_i, hover_j, -1, -1); // 🔼🔵 Top-Left
}
if (keyboard_check_pressed(ord("O"))) { 
    destroy_blocks_in_direction_from_point(self, hover_i, hover_j, +1, -1); // 🔼🔴 Top-Right
}
if (keyboard_check_pressed(ord("M"))) { 
    destroy_blocks_in_direction_from_point(self, hover_i, hover_j, -1, +1); // 🔽🔵 Bottom-Left
}
if (keyboard_check_pressed(ord("."))) { 
    destroy_blocks_in_direction_from_point(self, hover_i, hover_j, +1, +1); // 🔽🔴 Bottom-Right
}


if (keyboard_check_pressed(vk_shift)) {
	toss_down_row(self, true);
}

if keyboard_check_pressed(ord("E")) {
	activate_bomb_gem(self, hover_i, hover_j);
}

if keyboard_check_pressed(ord("W")) {
	colorize_column(self, hover_i, 2);
}

if keyboard_check_pressed(ord("D")) {
	colorize_row(self, hover_j, 2);
}

if keyboard_check_pressed(ord("A")) {
	freeze_block(self, hover_i, hover_j);
}

if (keyboard_check_pressed(ord("R"))) {
    increase_color_spawn(BLOCK.RED, 1);
}


if (keyboard_check_pressed(ord("U"))) {
	bring_up_upgrade_menu();
}

if (keyboard_check_pressed(ord("Q"))) {

	// Increase Bomb spawn rate by 2
	adjust_powerup_weights(POWERUP.BOMB, 2);

	// Increase Wild Potion spawn rate by 5
	adjust_powerup_weights(POWERUP.WILD_POTION, 5);
}

// Space for speed up
if (fight_for_your_life)
{
	global.gameSpeed = game_speed_default * game_speed_fight_for_your_life_modifier;
	global.enemy_timer_game_speed = global.gameSpeed;
}
else if (keyboard_check(vk_space)) {
    global.gameSpeed = game_speed_default + game_speed_increase_modifier;
} else {
	    if (combo <= 1) 
		{
	        global.gameSpeed = game_speed_default;
			global.enemy_timer_game_speed = global.gameSpeed;
	    }
	    else 
		{
	        global.gameSpeed = game_speed_default * game_speed_combo_modifier;
			global.enemy_timer_game_speed = global.gameSpeed;
	    }
}



total_time += 1;

var t_i_s = (total_time / FPS);
time_in_seconds = round(t_i_s);

if (t_i_s % 30 == 0)
{
	game_speed_default += 0.1;
}


if (keyboard_check_pressed(ord("1"))) {
    toss_down_shape(self, string("h_1x2"));
}
if (keyboard_check_pressed(ord("2"))) {
    toss_down_shape(self, "h_2x1");
}
if (keyboard_check_pressed(ord("3"))) {
    toss_down_shape(self, "triangle_down_3x3");
}
if (keyboard_check_pressed(ord("4"))) {
    toss_down_shape(self, "cross");
}
if (keyboard_check_pressed(ord("5"))) {
    toss_down_shape(self, "x_shape");
}

if (keyboard_check(ord("F")))
{
	fight_for_your_life = true;
}

if (fight_for_your_life)
{
	global.grid_shake_amount = 1;
}
else
{

	if (global.grid_shake_amount > 0) {
	    global.grid_shake_amount *= 0.9; // Slowly decay the shake
	}
	else
	{
		global.grid_shake_amount = 0;
	}
}


/// @function process_experience_points(_self, amount, increment_speed)
/// @description Gradually increases experience points toward a target value
/// and levels up when the experience bar is full.
/// - _self: The object (or global struct) whose experience is being updated.
/// - amount: The total XP to add.
/// - increment_speed: The speed factor (default = 0.01).
//function process_experience_points(_self, amount, increment_speed = 2) 
//{
//    // Gradual XP increment
//    var diff = _self.experience_points + amount;

//    if (abs(diff) < 1) {
//        _self.experience_points = _self.target_experience_points;
//        _self.target_experience_points = 0;
//    } 
//    else 
//	{
//        var delta = diff * increment_speed;

//        if (abs(delta) < 1) {
//            delta = sign(delta) * 1;
//        }
//        _self.experience_points += delta;
//		_self.target_experience_points -= delta;
//    }
//	process_level_up(_self);
//}

//function process_level_up(_self)
//{
	
//	    // **Check for Level Up**
//    if (_self.experience_points >= _self.max_experience_points) {
//        _self.experience_points -= _self.max_experience_points; // Carry over excess XP
//        _self.level += 1;
		
//		bring_up_upgrade_menu();

//        // **Recalculate max XP for the next level**
//        _self.max_experience_points = _self.max_exp_mod + ((_self.max_exp_level_mod * _self.level) + (_self.level * _self.level)) - _self.level;
        
//        // If the target XP was exceeded, keep processing until all XP is accounted for
//        if (_self.target_experience_points <= _self.experience_points) {
//            _self.target_experience_points = 0;
//        }
//    }
//}

/// @function process_experience_points(_self, amount, increment_speed)
/// @description Gradually increases experience points toward a target value
/// and levels up when the experience bar is full.
/// - _self: The object (or global struct) whose experience is being updated.
/// - amount: The total XP to add.
/// - increment_speed: The speed factor (default = 0.01).
function process_experience_points(_self, amount, increment_speed = 2) 
{
    // Gradual XP increment
    var diff = _self.experience_points + amount;

    if (abs(diff) < 1) {
        _self.experience_points = _self.target_experience_points;
        _self.target_experience_points = 0;
    } 
    else 
	{
        var delta = diff * increment_speed;

        if (abs(delta) < 1) {
            delta = sign(delta) * 1;
        }
        _self.experience_points += delta;
		_self.target_experience_points -= delta;
    }

    process_level_up(_self);
}

/// @function process_level_up(_self)
/// @description Handles leveling up and queues up multiple upgrades if needed.
function process_level_up(_self)
{
    var levels_gained = 0;

    // **Check for multiple Level Ups**
    while (_self.experience_points >= _self.max_experience_points) {
        _self.experience_points -= _self.max_experience_points; // Carry over excess XP
        _self.level += 1;
        levels_gained += 1; //  Track levels gained
		game_speed_default += 0.05;

        // **Recalculate max XP for the next level**
        _self.max_experience_points = _self.max_exp_mod + ((_self.max_exp_level_mod * _self.level) + (_self.level * _self.level)) - _self.level;
        
        // If the target XP was exceeded, keep processing until all XP is accounted for
        if (_self.target_experience_points <= _self.experience_points) {
            _self.target_experience_points = 0;
        }
    }

    // ✅ Store total levels gained but **don't trigger upgrade menu yet**
    target_level += levels_gained;
}

/// @function check_and_apply_upgrades()
/// @description Waits for upgrade menu to close, then applies next upgrade.
function check_and_apply_upgrades()
{
    // Only run if the player has pending upgrades
    if (target_level > 0 && !global.in_upgrade_menu && combo == 0) {
        
        // ✅ **Spawn the upgrade menu**
        bring_up_upgrade_menu();
        
        // ✅ **Track that we are inside the upgrade menu**
        global.in_upgrade_menu = true;
        
        // ✅ **Decrement the target level after closing**
        target_level -= 1;
    }
}


check_and_apply_upgrades();

if keyboard_check_pressed(vk_alt)
{
	target_experience_points += 100;
}

if (target_experience_points > 0)
{
	process_experience_points(self, target_experience_points, 0.0025);
	
}

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

// ------------------------------------------------------
// GAME OVER CHECK
// ------------------------------------------------------
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

// ------------------------------------------------------
// TIMERS AND SPEEDS
// ------------------------------------------------------
spawn_timer = 60 / global.gameSpeed;
shift_speed = 0.1 * global.gameSpeed;

//if (all_pops_finished()) {
//	// Now we can drop blocks
//	drop_blocks(self);

//	// ✅ If a match is found, increase combo
//	if find_and_destroy_matches() {
//		combo += 1;
//	} 
//}


if (all_pops_finished()) {
    // ✅ Drop blocks **AFTER** all pops finish
    drop_blocks(self);

    // ✅ If a new match is found, **increase** combo instead of resetting
    if find_and_destroy_matches() {
		combo_timer = 0;
        combo += 1;
    } 
}

// ✅ Ensure combo resets **ONLY when no movement remains**
if (!blocks_still_moving(self) ){
	if (combo_timer < max_combo_timer)
	{
		combo_timer ++;
	}
	else
	{
		combo = 0;
		combo_timer = max_combo_timer;
	}
}
else
{
	combo_timer = 0;
}

//if (!blocks_still_moving(self))
//{
//	combo = 0;
//}

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
        //grid[i, height - 1] = create_gem(irandom_range(0, numberOfGemTypes - 1));
		grid[i, height - 1] = create_gem(-99);
        gem_y_offsets[i, height - 1] = 0;
    }
	
    // 4️⃣ Reset alpha so the newly spawned row fades in again
    darken_alpha = 0;
}
	
	// -------------------------
// ✅ POINT CALCULATION FUNCTION
// -------------------------



//function find_and_destroy_matches() {
//    var marked_for_removal = array_create(width, height);
//    var found_any = false;
//    var first_found = false; // ✅ Track the first block in the combo
//    var total_match_points = 0; // ✅ Accumulates points for multiple matches
//	var black_blocks_to_transform = ds_list_create(); // ✅ Store black blocks that will transform

//    // Initialize the marked_for_removal array
//    for (var xx = 0; xx < width; xx++) {
//        for (var yy = 0; yy < height; yy++) {
//            marked_for_removal[xx, yy] = false;
			
//			if (grid[xx, yy].shake_timer > 0)
//			{
//				grid[xx, yy].popping = true;
//			}
			
//        }
//    }

//    // -------------------------
//    // ✅ HORIZONTAL MATCHES
//    // -------------------------
//    for (var j = 0; j < height; j++) {
//        var match_count = 1;
//        var start_idx = 0;

//        for (var i = 1; i < width; i++) {
//            if (can_match(grid[i, j], grid[i - 1, j])) {
//                if (match_count == 1) start_idx = i - 1;
//                match_count++;
//            } else {
//                if (match_count >= 3) {
//                    for (var k = 0; k < match_count; k++) {
//                        var xx = start_idx + k;
//                        if (xx >= 0 && xx < width) {
//                            marked_for_removal[xx, j] = true;

//                            if (!first_found) {
//                                global.combo_x = xx;
//                                global.combo_y = j;
//                                first_found = true;
//                            }
//							 // ✅ Check for adjacent black blocks
//                            check_adjacent_black_blocks(self, j, xx, black_blocks_to_transform);
//                        }
//                    }
//                    // ✅ Add points based on match size
//                    total_match_points += calculate_match_points(self, match_count);
//                }
//                match_count = 1;
//            }
//        }
//        if (match_count >= 3) {
//            for (var k = 0; k < match_count; k++) {
//                var xx = start_idx + k;
//                if (xx >= 0 && xx < width) {
//                    marked_for_removal[xx, j] = true;

//                    if (!first_found) {
//                        global.combo_x = xx;
//                        global.combo_y = j;
//                        first_found = true;
//                    }
//					 // ✅ Check for adjacent black blocks
//                     check_adjacent_black_blocks(self, j, xx, black_blocks_to_transform);
//                }
//            }
//           total_match_points += calculate_match_points(self, match_count);
//        }
//    }

//    // -------------------------
//    // ✅ VERTICAL MATCHES
//    // -------------------------
//    for (var i = 0; i < width; i++) {
//        var match_count = 1;
//        var start_idx = 0;

//        for (var j = 1; j < height; j++) {
//            if (can_match(grid[i, j], grid[i, j - 1])) {
//                if (match_count == 1) start_idx = j - 1;
//                match_count++;
//            } else {
//                if (match_count >= 3) {
//                    for (var k = 0; k < match_count; k++) {
//                        var yy = start_idx + k;
						
//                        if (yy >= 0 && yy < height) {
//                            marked_for_removal[i, yy] = true;

//                            if (!first_found) {
//                                global.combo_x = i;
//                                global.combo_y = yy;
//                                first_found = true;
//                            }
//							 // ✅ Check for adjacent black blocks
//                            check_adjacent_black_blocks(self, i, yy, black_blocks_to_transform);
//                        }
//                    }
//                    total_match_points += calculate_match_points(self, match_count);
//                }
//                match_count = 1;
//            }
//        }
//        if (match_count >= 3) {
//            for (var k = 0; k < match_count; k++) {
//                var yy = start_idx + k;
//                if (yy >= 0 && yy < height) {
//                    marked_for_removal[i, yy] = true;

//                    if (!first_found) {
//                        global.combo_x = i;
//                        global.combo_y = yy;
//                        first_found = true;
//                    }
//					 // ✅ Check for adjacent black blocks
//                     check_adjacent_black_blocks(self, i, yy, black_blocks_to_transform);
//                }
//            }
//            total_match_points += calculate_match_points(self, match_count);
//        }
//    }



//    // -------------------------
//    // ✅ HANDLE MATCHED GEMS
//    // -------------------------
//    for (var i = 0; i < width; i++) {
//        for (var j = 0; j < height; j++) {
//            if (marked_for_removal[i, j]) {
//                found_any = true;
//                grid[i, j].shake_timer = 30; // Start shaking effect
				
//                var gem = grid[i, j];
//                var dx = i - global.lastSwapX;
//                var dy = j - global.lastSwapY;
//                var dist = sqrt(dx * dx + dy * dy);
//				var _start_delay = 5;
				
//				if (gem.type == BLOCK.BLACK)
//				{
//					_start_delay = 20;
//				}
				
				
//                var pop_info = {
//                    x: i,
//                    y: j,
//                    gem_type: gem.type,
//                    timer: 0,
//                    start_delay: dist * _start_delay, // Wave effect
//                    scale: 1.0,
//                    popping: true,
//                    powerup: gem.powerup,
//					dir: gem.dir,
//                    offset_x: gem.offset_x,
//                    offset_y: gem.offset_y,
//                    color: gem.color,
//                    y_offset_global: global_y_offset,
//					match_size: match_count, // ✅ Store the match size
//					match_points: total_match_points,
//					bomb_tracker: false,               // Flag to mark this pop as bomb‐generated
//					bomb_level: 0
//                };
				
//				target_experience_points += (match_count + combo) + (global.modifier);

//                grid[i, j].popping = true;
//                grid[i, j].pop_timer = dist * _start_delay;

//                ds_list_add(global.pop_list, pop_info);
//            }
//        }
//    }
	
//	// ✅ Transform black blocks **after matches are removed**
//    update_black_blocks(self, black_blocks_to_transform);
//    ds_list_destroy(black_blocks_to_transform);
	
//    return found_any;
//}

function find_and_destroy_matches() {
    var marked_for_removal = array_create(width, height);
    var found_any = false;
    var first_found = false;
    var total_match_points = 0;
    var black_blocks_to_transform = ds_list_create();

    // ✅ Initialize marked_for_removal array
    for (var xx = 0; xx < width; xx++) {
        for (var yy = 0; yy < height; yy++) {
            marked_for_removal[xx, yy] = false;
            if (grid[xx, yy].shake_timer > 0) {
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
                if (match_count >= 3) mark_match(marked_for_removal, start_idx, match_count, j, "horizontal");
                match_count = 1;
            }
        }
        if (match_count >= 3) mark_match(marked_for_removal, start_idx, match_count, j, "horizontal");
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
                if (match_count >= 3) mark_match(marked_for_removal, i, match_count, start_idx, "vertical");
                match_count = 1;
            }
        }
        if (match_count >= 3) mark_match(marked_for_removal, i, match_count, start_idx, "vertical");
    }

    // -------------------------
    // ✅ DIAGONAL MATCHES (If enabled)
    // -------------------------
    if (diagonal_matches) {
        // 🔵 **↘ Diagonal Matches (Top-Left to Bottom-Right)**
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

        // 🔴 **↙ Diagonal Matches (Top-Right to Bottom-Left)**
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
                grid[i, j].shake_timer = 30;

                var gem = grid[i, j];
                var dx = i - global.lastSwapX;
                var dy = j - global.lastSwapY;
                var dist = sqrt(dx * dx + dy * dy);
                var _start_delay = (gem.type == BLOCK.BLACK) ? 20 : 5;

                var pop_info = {
                    x: i, y: j, gem_type: gem.type,
                    timer: 0, start_delay: dist * _start_delay,
                    scale: 1.0, popping: true,
                    powerup: gem.powerup, dir: gem.dir,
                    offset_x: gem.offset_x, offset_y: gem.offset_y,
                    color: gem.color, y_offset_global: global_y_offset,
                    match_size: match_count, match_points: total_match_points,
                    bomb_tracker: false, bomb_level: 0
                };

                target_experience_points += (match_count + combo) + (global.modifier);
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

// ✅ Function to mark matches
function mark_match(marked_for_removal, _x, count, _y, _direction) {
    for (var k = 0; k < count; k++) {
        if (_direction == "horizontal") marked_for_removal[_x + k, _y] = true;
        else if (_direction == "vertical") marked_for_removal[_x, _y + k] = true;
    }
}

// ✅ Function to mark diagonal matches
function mark_diagonal_match(marked_for_removal, start_x, start_y, count, _direction) {
    for (var k = 0; k < count; k++) {
        if (_direction == "↘") marked_for_removal[start_x + k, start_y + k] = true;
        else if (_direction == "↙") marked_for_removal[start_x - k, start_y + k] = true;
    }
}


global.modifier = game_speed_default / game_speed_start;


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
			
			//self.grid[_x, _y].popping = true;
			
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
                //if (gem.powerup == POWERUP.MULTI_4X) total_multiplier *= 4;
                // ✅ You can add more multipliers here later!


                // 🔥 **Step 2: Loop Through Multipliers**
                process_powerup(self, _x, _y, gem, total_multiplier_next);

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


function process_powerup(_self, _x, _y, gem, total_multiplier) {
    if (gem.powerup == -1) return; // No power-up, do nothing
	
    // 🔥 Convert multiplier to level (max level 5)
    var level = clamp(ln(total_multiplier) / ln(2), 1, 5); // Maps 2→1, 4→2, 8→3, 16→4, 32+→5

    switch (gem.powerup.powerup) {
        case POWERUP.SWORD:
            // 💥 **Destroy the entire row & column**
            for (var offset = 0; offset < level; offset++) {
                destroy_blocks_in_direction_from_point(_self, _x + offset, _y, 1, 0);
                destroy_blocks_in_direction_from_point(_self, _x - offset, _y, -1, 0);
                destroy_blocks_in_direction_from_point(_self, _x, _y + offset, 0, 1);
                destroy_blocks_in_direction_from_point(_self, _x, _y - offset, 0, -1);
            }
            break;

        case POWERUP.BOW:
            // 💥 **Destroy same direction row below it for each level**
            for (var offset = 0; offset < level; offset++) {
                switch (gem.powerup.dir) {
                    case 0:   destroy_blocks_in_direction_from_point(_self, _x + offset, _y, 1, 0); break; // Right
                    case 90:  destroy_blocks_in_direction_from_point(_self, _x, _y - offset, 0, -1); break; // Up
                    case 180: destroy_blocks_in_direction_from_point(_self, _x - offset, _y, -1, 0); break; // Left
                    case 270: destroy_blocks_in_direction_from_point(_self, _x, _y + offset, 0, 1); break; // Down
                }
            }
            break;

        case POWERUP.BOMB:
            // 💣 **Explode in larger areas based on level**
            activate_bomb_gem(_self, _x, _y, level);
            break;

        case POWERUP.EXP:
            // ⭐ **Grant extra experience (scales infinitely)**
            experience_points += 10 * total_multiplier;
            break;

        case POWERUP.HEART:
            // 💖 **Heal infinitely without cap**
            player_health += total_multiplier;
            break;

        case POWERUP.MONEY:
            // 💰 **Grant points infinitely**
            total_points += 50 * total_multiplier;
            break;

        case POWERUP.POISON:
            // ☠️ **Reduce health scaled by level (not infinite)**
            player_health -= level;
            break;

        case POWERUP.FIRE:
            // 🔥 **Ignite area based on level (max 5)**
            for (var dx = -level; dx <= level; dx++) {
                for (var dy = -level; dy <= level; dy++) {
                    if (dx == 0 && dy == 0) continue;
                    var nx = _x + dx;
                    var ny = _y + dy;
                    if (nx >= 0 && nx < _self.width && ny >= 0 && ny < _self.height) {
                        _self.grid[nx, ny].popping = true;
                    }
                }
            }
            break;

        case POWERUP.ICE:
            // ❄️ **Freeze surrounding blocks (max level 5)**
            freeze_block(_self, _x, _y, level);
            break;

        case POWERUP.TIMER:
            // ⏳ **Slow down the game (max level 5)**
            global.gameSpeed = max(0.5 / level, 0.1);
            break;

        case POWERUP.FEATHER:
            // 🪶 **Remove gravity effect for short time**
            for (var j = 0; j < _self.height; j++) {
                for (var i = 0; i < _self.width; i++) {
                    _self.grid[i, j].falling = false;
                }
            }
            break;

        case POWERUP.WILD_POTION:
            // 🌀 **Spawn wild blocks infinitely (no level cap)**
            spawn_wild_block(_self, total_multiplier);
            break;
    }
}


function spawn_wild_block(_self, multiplier = 1) {
    var _rand_array = array_create(0); // Stores valid positions

    // ✅ Find valid positions for wild blocks
    for (var j = 0; j < _self.height; j++) {
        for (var i = 0; i < _self.width; i++) {
            if (_self.grid[i, j].type != -1) { // Only non-empty slots
                array_push(_rand_array, { x: i, y: j }); // ✅ Store x, y coordinates
            }
        }
    }

    // ✅ Ensure there's at least one valid position
    if (array_length(_rand_array) > 0) {
        for (var k = 0; k < multiplier; k++) { // ✅ Add multiplier functionality
            var _rand_index = irandom(array_length(_rand_array) - 1);
            var _rand_pos = _rand_array[_rand_index];

            // ✅ Change the block at the random position to WILD
            _self.grid[_rand_pos.x, _rand_pos.y].type = BLOCK.WILD;
        }
    }
}





// If a swap is queued and the offset is above our threshold, execute it
if (self.global_y_offset >= 5 && global.swap_queue.active) {
    execute_swap(self, global.swap_queue.ax, global.swap_queue.ay, global.swap_queue.bx, global.swap_queue.by);
    global.swap_queue.active = false; // Clear the swap queue
}




	
function create_mega_block(_width, _height) {
    return {
        x: -1, // Grid X position (top-left)
        y: -1, // Grid Y position (top-left)
        width: _width,
        height: _height,
        type: BLOCK.MEGA,
        falling: true,    // Gem type (e.g., 0 for red, 1 for blue, etc.)
        powerup: -1, // Power-up type (e.g., 0 for bomb, 1 for rainbow, etc.)
        locked: true,     // Whether the gem is locked
        offset_x: 0,       // Horizontal offset for animations
        offset_y: 0,       // Vertical offset for animations
        fall_target: -1,   // Target row for falling animations
		shake_timer: 0,    // New property for shaking effect
		color: c_white,
		fall_delay: 0,
		max_fall_delay: 10, 
		freeze_timer: 0,   // 🔥 New: Countdown to thaw
        frozen: false,      // 🔥 New: Flag for frozen state
		damage: 1,
		combo_multiplier: 1,
		pop_speed: 1,
		explode_on_four: false,
		explode_on_five: false,
		explode_on_six: false,
		popping: false,
		pop_timer: 0,
		group_id: irandom(99999)
    };
}

function spawn_mega_block(_self, _x, _y, _width, _height) {
    var mega_block = create_mega_block(_width, _height);
    mega_block.x = _x;
    mega_block.y = 0; // ✅ Start above screen
    mega_block.group_id = irandom(999999); // ✅ Unique ID for tracking
	mega_block.falling = true;

    // ✅ Reserve space in the grid for the entire Mega Block
    for (var i = 0; i < _width; i++) {
        for (var j = 0; j < _height; j++) {
            _self.grid[_x + i, _y + j] = mega_block; // Assign reference to the same object
        }
    }

    //mega_block.falling = true; // ✅ Mark the whole block as falling
    //ds_list_add(_self.mega_blocks, mega_block);
}



function check_mega_block_transform(_self) {
    var transformed_groups = ds_map_create(); // ✅ Track which groups already transformed

    for (var j = 0; j < _self.height; j++) {
        for (var i = 0; i < _self.width; i++) {
            var gem = _self.grid[i, j];

            // ✅ Only process Mega Blocks
            if (gem.type == BLOCK.MEGA) {
                var group_id = gem.group_id;

                // ✅ Skip if this group has already transformed
                if (ds_map_exists(transformed_groups, group_id)) {
                    continue;
                }

                var transform = false;

                // ✅ **Check if any part of the Mega Block is next to a popping block**
                for (var bx = 0; bx < gem.width; bx++) {
                    for (var by = 0; by < gem.height; by++) {
                        var _x = gem.x + bx;
                        var _y = gem.y + by;

                        for (var dx = -1; dx <= 1; dx++) {
                            for (var dy = -1; dy <= 1; dy++) {
                                if (dx == 0 && dy == 0) continue; // Skip itself
                                var nx = _x + dx;
                                var ny = _y + dy;

                                if (nx >= 0 && nx < _self.width && ny >= 0 && ny < _self.height) {
                                    if (_self.grid[nx, ny] != -1 && _self.grid[nx, ny].popping) {
                                        transform = true;
                                    }
                                }
                            }
                        }
                    }
                }

                // ✅ **Trigger transformation**
                if (transform) {
                    gem.pop_timer += 1; // Start the popping delay

                    if (gem.pop_timer >= 30) { // 🔥 **Wait before transformation**
                        for (var bx = 0; bx < gem.width; bx++) {
                            for (var by = 0; by < gem.height; by++) {
                                var _x = gem.x + bx + board_x_offset;
                                var _y = gem.y + by;

                                // 🔥 **Create a pop effect before transformation**
                                effect_create_depth(_self.depth, ef_explosion, (_x * gem_size), (_y * gem_size), 0.5, c_white);

                                // ✅ **Transform the entire Mega Block**
                                _self.grid[_x, _y] = create_gem(irandom(_self.numberOfGemTypes - 1));
                            }
                        }

                        // ✅ **Mark this group as transformed**
                        ds_map_add(transformed_groups, group_id, true);
                    }
                }
            }
        }
    }

    ds_map_destroy(transformed_groups); // ✅ Cleanup memory
}




