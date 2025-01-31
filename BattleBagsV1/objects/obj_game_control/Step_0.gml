// ✅ Toggle Pause with "P" key
if (keyboard_check_pressed(ord("P"))) {
    global.paused = !global.paused; // Toggle the pause state
}

// ✅ Stop everything except the pause check
if (global.paused) return;

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


// Space for speed up
if (fight_for_your_life)
{
	global.gameSpeed = game_speed_default * game_speed_fight_for_your_life_modifier;
}
else if (keyboard_check(vk_space)) {
    global.gameSpeed = game_speed_default * game_speed_increase_modifier;
} else {
	    if (combo == 0) 
		{
	        global.gameSpeed = game_speed_default;
	    }
	    else 
		{
	        global.gameSpeed = game_speed_default * game_speed_combo_modifier;
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
    toss_down_shape(self, string("square_3x3"));
}
if (keyboard_check_pressed(ord("2"))) {
    toss_down_shape(self, "line_1x3");
}
if (keyboard_check_pressed(ord("3"))) {
    toss_down_shape(self, "block_2x3");
}
if (keyboard_check_pressed(ord("4"))) {
    toss_down_shape(self, "cross");
}
if (keyboard_check_pressed(ord("5"))) {
    toss_down_shape(self, "x_shape");
}


if (global.grid_shake_amount > 0) {
    global.grid_shake_amount *= 0.9; // Slowly decay the shake
}

if (experience_points >= max_experience_points)
{
	var temp_exp = experience_points - max_experience_points;
	level += 1;
	max_experience_points = 10 + ((10 * level) + (level * level)) - level;
	experience_points = temp_exp;
}

if (keyboard_check(vk_alt))
{
	experience_points += 10;
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


// ✅ Only reset combo **if absolutely everything has stopped moving**
if (!blocks_still_moving(self)) {
	combo = 0;
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

if (all_pops_finished()) {
	// Now we can drop blocks
	drop_blocks(self);

	// ✅ If a match is found, increase combo
	if find_and_destroy_matches() {
		combo += 1;
	} 
}

update_freeze_timer(self);

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
        gem_y_offsets[i, height - 1] = gem_size;
    }
	
    // 4️⃣ Reset alpha so the newly spawned row fades in again
    darken_alpha = 0;
}
	
	// -------------------------
// ✅ POINT CALCULATION FUNCTION
// -------------------------



function find_and_destroy_matches() {
    var marked_for_removal = array_create(width, height);
    var found_any = false;
    var first_found = false; // ✅ Track the first block in the combo
    var total_match_points = 0; // ✅ Accumulates points for multiple matches
	var black_blocks_to_transform = ds_list_create(); // ✅ Store black blocks that will transform

    // Initialize the marked_for_removal array
    for (var xx = 0; xx < width; xx++) {
        for (var yy = 0; yy < height; yy++) {
            marked_for_removal[xx, yy] = false;
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



    // -------------------------
    // ✅ HANDLE MATCHED GEMS
    // -------------------------
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            if (marked_for_removal[i, j]) {
                found_any = true;
                grid[i, j].shake_timer = 30; // Start shaking effect

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
                    offset_x: gem.offset_x,
                    offset_y: gem.offset_y,
                    color: gem.color,
                    y_offset_global: global_y_offset,
					match_size: match_count, // ✅ Store the match size
					match_points: total_match_points
                };

                gem.popping = true;
                gem.pop_timer = _start_delay;

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
        } else {
            // Grow effect
            pop_data.scale += 0.05;

            // Once scale >= 1.1, pop is done
            if (pop_data.scale >= 1.1) {
                // Now we remove from the grid
                destroy_block(self, pop_data.x, pop_data.y);

                // Compute pixel position for new object
                var px = (pop_data.x * gem_size) + board_x_offset + offset;
                var py = (pop_data.y * gem_size) + offset + global_y_offset + gem_y_offsets[pop_data.x, pop_data.y];

                // Create visual effect
                effect_create_depth(depth, ef_firework, px, py - 4, 0.5, pop_data.color);

                // -------------------------------------
                // ✅ Create Attack Object with Score
                // -------------------------------------
                var attack = instance_create_depth(px, py, depth - 1, obj_player_attack);
                attack.color = pop_data.color;

                // 🔥 Assign points based on match size (Uses previous logic)
                attack.damage = pop_data.match_points / pop_data.match_size;
				
				// ✅ Add accumulated match points to total_points
				total_points += attack.damage;
				
				

                // Then remove from pop_list
                ds_list_delete(global.pop_list, i);
                i--; 
                continue;
            }
        }

        // Write back updated pop_data
        ds_list_replace(global.pop_list, i, pop_data);
    }
}

function start_swap(ax, ay, bx, by) {
	if (swap_in_progress) return; // Prevent stacking swaps
    // Ensure the source and target are valid grid positions
    if (
        ax >= 0 && ax < width && ay >= 0 && ay < height &&
        bx >= 0 && bx < width && by >= 0 && by < height
    ) {
        // Prevent swapping with a position marked for destruction
        if (is_being_destroyed(ax, ay) || is_being_destroyed(bx, by)) {
            return; // Do not allow swap
        }
		if (grid[ax, ay].frozen || grid[bx, by].frozen) return;

        swap_in_progress = true;
		
        swap_info.from_x = ax;
        swap_info.from_y = ay;
        swap_info.to_x   = bx;
        swap_info.to_y   = by;
        swap_info.progress = 0;
        swap_info.speed = 0.1; // e.g., 0.1 means ~10 frames
    }
}
	







