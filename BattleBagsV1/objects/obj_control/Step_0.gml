/// @description Smooth upward movement, horizontal swapping, and match detection

/// @description Smooth upward movement, horizontal swapping, and match detection

function mouse_dragged() {
    // When the left mouse button is pressed, record the starting cell
    if (mouse_check_button_pressed(mb_left)) {
        // Convert mouse coordinates to grid indices
        selected_x = floor((mouse_x - board_x_offset) / gem_size);
        selected_y = floor((mouse_y - global_y_offset) / gem_size);

        // Only allow dragging if the selected cell is valid and not empty
        if (
            selected_x >= 0 && selected_x < width &&
            selected_y >= 0 && selected_y < height &&
            grid[selected_x, selected_y].type != -1
        ) {
            dragged = false; // Prepare for dragging
        } else {
            // Reset selection if clicking on an empty space
            selected_x = -1;
            selected_y = -1;
        }
    }

    // While the left mouse button is held down
    if (mouse_check_button(mb_left)) {
        if (!dragged && selected_x != -1 && selected_y != -1) {
    var current_x = floor((mouse_x - board_x_offset) / gem_size);
    var current_y = floor((mouse_y - global_y_offset) / gem_size);

   if (
    current_x >= 0 && current_x < width &&
    current_y == selected_y && // Horizontal swaps only
    current_x != selected_x
    //grid[current_x, current_y].type != -1 // Ensure destination is valid
	) {
	    start_swap(selected_x, selected_y, current_x, selected_y);
	    selected_x = current_x;
	    dragged = true;
	}

}
    }

    // When the left mouse button is released
    if (mouse_check_button_released(mb_left)) {
        selected_x = -1;
        selected_y = -1;
        dragged = false;
    }
}

mouse_dragged();

for (var i = 0; i < width; i++) {
    for (var j = 0; j < height; j++) {
        if (!is_struct(grid[i, j])) {
            show_debug_message("Invalid gem at (" + string(i) + ", " + string(j) + ")");
        }
    }
}
// ------------------------------------------------------
// 2) SMOOTH UPWARD MOVEMENT + SHIFT
// ------------------------------------------------------
global_y_offset -= shift_speed;

if (global_y_offset <= -gem_size) {
    global_y_offset = 0;
    shift_up();
    // find_and_destroy_matches(); (commented out or your choice)
}

// ------------------------------------------------------
// 3) DARKEN BOTTOM ROW LOGIC
// ------------------------------------------------------
darken_alpha += 0.02;
if (darken_alpha > 1) {
    darken_alpha = 1;
}

// ------------------------------------------------------
// 4) GAME OVER CHECK
// ------------------------------------------------------
update_topmost_row();
if (global.topmost_row <= 0) {
    check_game_over();
}

if (!swap_in_progress && all_blocks_landed()) {
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            grid[i, j].offset_x = 0;
            grid[i, j].offset_y = 0;
        }
    }
}

function update_gem_positions() {
    // Increment the timer
    global.fall_timer++;

    // Check if it's time to move the blocks down
    if (global.fall_timer >= 60) { // Every 30 frames
        global.fall_timer = 0; // Reset the timer

        // Process rows from bottom to top
        for (var j = height - 2; j >= 0; j--) { // Skip bottom row
            for (var i = 0; i < width; i++) {
                var gem = grid[i, j];
                if (gem.type != -1 && gem.falling) { // Only process falling gems
                    var below = grid[i, j + 1]; // The cell below the current gem

                    // Check if the cell below is empty
                    if (below.type == -1) {
                        // Move the gem logically in the grid
                        grid[i, j + 1] = gem;
                        grid[i, j] = create_gem(-1); // Clear the old position

                        // Mark the gem as still falling if there's more room below
                        gem.falling = (j + 2 < height && grid[i, j + 2].type == -1);
                    } else {
                        // Stop falling if the cell below is not empty
                        gem.falling = false;
                    }
                }
            }
        }
    }

    //// Smoothly animate the visual positions of all gems
    //for (var i = 0; i < width; i++) {
    //    for (var j = 0; j < height; j++) {
    //        var gem = grid[i, j];
    //        if (gem.type != -1) {
    //            // Calculate the target pixel position
    //            var target_y = j * gem_size;

    //            // Smoothly adjust the gem's offset_y to match the target
    //            var diff = target_y - gem.offset_y;
    //            if (abs(diff) > 1) {
    //                gem.offset_y += sign(diff) * min(abs(diff), 4); // Adjust speed
    //            } else {
    //                gem.offset_y = target_y; // Snap to position when close enough
    //            }
    //        }
    //    }
    //}
}

//update_gem_positions();
// ------------------------------------------------------
// 5) Timers, speeds
// ------------------------------------------------------
spawn_timer = 60 / global.gameSpeed;
shift_speed = 0.1 * global.gameSpeed;

// Space for speed up
if (keyboard_check(vk_space)) {
    global.gameSpeed = 6;
} else {
    // NOTE: There's a likely bug here: "if (combo = 0)" sets combo to 0
    // Instead of "if (combo == 0)" you might want "==" for a comparison.
    if (combo == 0) {
        global.gameSpeed = 3;
    }
    else {
        global.gameSpeed = 1;
    }
}

var fall_speed = 4;
for (var i = 0; i < width; i++) {
    for (var j = 0; j < height; j++) {
        if (gem_y_offsets[i, j] < 0) {
            gem_y_offsets[i, j] += fall_speed;
            if (gem_y_offsets[i, j] >= 0) {
                gem_y_offsets[i, j] = 0;
                locked[i, j] = false;
            }
        }
        else if (gem_y_offsets[i, j] > 0) {
            // Move block upward
            gem_y_offsets[i, j] -= fall_speed;
            if (gem_y_offsets[i, j] < 0) {
                gem_y_offsets[i, j] = 0;
            }
        }
    }
}



// -----------------------------------------------------------------------
// FUNCTIONS
// -----------------------------------------------------------------------

function all_blocks_landed() {
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            if (gem_y_offsets[i, j] < 0) {
                return false; // There's at least one still falling
            }
        }
    }
    return true; // Everything is settled
}

/// Spawns a new row at the bottom (not currently called in this Step)
function spawn_new_row() {
    // Shift all grid values up by one row
	
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height - 1; j++) {
            grid[i, j] = grid[i, j + 1];
        }
    }
    // Add a new random row at the bottom
    for (var i = 0; i < width; i++) {
        grid[i, height - 1] = create_gem(irandom_range(0, numberOfGemTypes - 1));
    }
}

function resolve_board() {
    // We'll keep looping until no more matches are found
    var keepGoing = true;
    while (keepGoing) {
        // find_and_destroy_matches now returns 'true' if something was destroyed
        keepGoing = find_and_destroy_matches();
        if (keepGoing) {
            drop_blocks();
        }
    }
}

/// Moves the grid up one row logically
function shift_up() {
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height - 1; j++) {
            grid[i, j] = grid[i, j + 1];             // Shift
            gem_y_offsets[i, j] = gem_y_offsets[i, j + 1]; // Carry offsets
        }
    }
    // Spawn a new random row at bottom
    for (var i = 0; i < width; i++) {
        grid[i, height - 1] = create_gem(irandom_range(0, numberOfGemTypes - 1));
        gem_y_offsets[i, height - 1] = gem_size;
    }
	    // Reset alpha so the newly spawned row fades in again
	//find_and_destroy_matches();  
    darken_alpha = 0;
	
    update_topmost_row();
}

function destroy_block(_x, _y) {
    grid[_x, _y] = create_gem(-1); // Replace with an empty gem
    gem_y_offsets[_x, _y] = 0;
    update_topmost_row();
}


/// Returns true if top row contains a gem
function is_top_row_filled() {
    for (var i = 0; i < width; i++) {
        if (grid[i, 0] != -1) {
            return true;
        }
    }
    return false;
}

/// Simple Game Over logic
function game_over() {
    show_message("Game Over!");
    // Additional logic can be added here
}

function check_game_over() {
    // 1) Skip game over if there's ANY locked gem in row 0
    for (var i = 0; i < width; i++) {
        if (grid[i, 0] != -1 && locked[i, 0]) {
            return; 
        }
    }

    // 2) If the loop completes, no locked gems at top row
    //    Then if row 0 has a gem, cause game over
    for (var i = 0; i < width; i++) {
        // FIX SYNTAX: Add parentheses around the entire condition
        if ((grid[i, 0] != -1) && (!locked[i, 0])) {
            //game_over();
            return;
        }
    }
}

/// Updates the global.topmost_row to the highest occupied row
function update_topmost_row() {
    global.topmost_row = height - 1;
    for (var j = 0; j < height; j++) {
        for (var i = 0; i < width; i++) {
            if (grid[i, j] != -1 && !locked[i, j]) {
                global.topmost_row = j;
                return;
            }
        }
    }
}

function drop_blocks() {
    for (var i = 0; i < width; i++) {
        var empty_row = height - 1;
        for (var j = height - 1; j >= 0; j--) {
            var gem = grid[i, j];
            if (gem.type != -1) { // If the cell is occupied
                if (j != empty_row) {
                    // Move the gem logically
                    grid[i, empty_row] = gem;
                    grid[i, j] = create_gem(-1); // Clear the original cell

                    // Set the fall target and mark as falling
                    gem.fall_target = empty_row;
                    gem.falling = true;
                }
                empty_row--; // Shift the empty row pointer up
            }
        }
    }
}

function find_and_destroy_matches() {
    var marked_for_removal = array_create(width, height);

    // Initialize the marked_for_removal array
    for (var xx = 0; xx < width; xx++) {
        for (var yy = 0; yy < height; yy++) {
            marked_for_removal[xx, yy] = false;
        }
    }

    // Helper function to check match conditions
    function can_match(gem1, gem2) {
        if (!gem1 || !gem2) return false; // Ensure both gems are valid objects
        return gem1.type != -1 && gem2.type != -1 && (
            gem1.type == gem2.type || 
            gem1.type == WILD_BLOCK || 
            gem2.type == WILD_BLOCK
        );
    }

    // Horizontal matches
    for (var j = 0; j < height; j++) {
        var match_count = 1;
        var start_idx = 0;

        for (var i = 1; i < width; i++) {
            if (can_match(grid[i, j], grid[i - 1, j])) {
                if (match_count == 1) start_idx = i - 1; // Start index of the match
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

        // Handle matches at the end of the row
        if (match_count >= 3) {
            for (var k = 0; k < match_count; k++) {
                var xx = start_idx + k;
                if (xx >= 0 && xx < width) {
                    marked_for_removal[xx, j] = true;
                }
            }
        }
    }

    // Vertical matches
    for (var i = 0; i < width; i++) {
        var match_count = 1;
        var start_idx = 0;

        for (var j = 1; j < height; j++) {
            if (can_match(grid[i, j], grid[i, j - 1])) {
                if (match_count == 1) start_idx = j - 1; // Start index of the match
                match_count++;
            } else {
                if (match_count >= 3) {
                    for (var k = 0; k < match_count; k++) {
                        var yy = start_idx + k;
                        if (yy >= 0 && yy < height) {
                            marked_for_removal[i, yy] = true;
                        }
                    }
                }
                match_count = 1;
            }
        }

        // Handle matches at the end of the column
        if (match_count >= 3) {
            for (var k = 0; k < match_count; k++) {
                var yy = start_idx + k;
                if (yy >= 0 && yy < height) {
                    marked_for_removal[i, yy] = true;
                }
            }
        }
    }

    // Handle matched gems
    var found_any = false;
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            if (marked_for_removal[i, j]) {
                found_any = true;
			    // Start shaking effect (30 frames before breaking)
			    grid[i, j].shake_timer = 60; 
                // Create pop info
                var gem = grid[i, j];
                var dx = i - global.lastSwapX;
                var dy = j - global.lastSwapY;
                var dist = sqrt(dx * dx + dy * dy);

                var pop_info = {
                    x: i,
                    y: j,
                    gem_type: gem.type,
                    timer: 0,
                    start_delay: dist * 10, // For wave effect
                    scale: 1.0,
                    popping: true,
					powerup: gem.powerup,
					offset_x: gem.offset_x,
					offset_y: gem.offset_y,
					color: gem.color
                };

                ds_list_add(global.pop_list, pop_info);

                // Mark gem for destruction after animation
                grid[i, j] = create_gem(-1); // Replace with empty gem
            }
        }
    }

    return found_any;
}

for (var i = 0; i < width; i++) {
    for (var j = 0; j < height; j++) {
        var gem = grid[i, j];

        if (gem.type != -1 && gem.shake_timer > 0) {
            gem.shake_timer--;

            // Apply shaking effect by setting offset_x and offset_y
            gem.offset_x = irandom_range(-8, 8); // Shake horizontally
            gem.offset_y = irandom_range(-8, 8); // Shake vertically
        } else {
            // Reset offset when not shaking
            gem.offset_x = 0;
            gem.offset_y = 0;
        }
    }
}

if all_blocks_landed()
{
	for (var i = 0; i < ds_list_size(global.pop_list); i++) {
	    var pop_data = ds_list_find_value(global.pop_list, i);

	    // Wait for start_delay
	    if (pop_data.timer < pop_data.start_delay) {
	        pop_data.timer++;
	    }
	    else {
	        // Grow, e.g. pop_data.scale += 0.02
	        pop_data.scale += 0.02;

	        // Once scale >= 1.1, pop is done
	        if (pop_data.scale >= 1.1) {
	            // Now we remove from the grid
	            destroy_block(pop_data.x, pop_data.y);
				
				 // 1) Compute the pixel position for the new object
			    var px = (pop_data.x * gem_size) + board_x_offset + offset;
			    var py = (pop_data.y * gem_size) + offset + global_y_offset + gem_y_offsets[pop_data.x, pop_data.y];

			    // 2) Create the attack object
				effect_create_depth(depth, ef_firework, px, py-4, 0.5, pop_data.color);
			    var attack = instance_create_depth(px, py, depth - 1, obj_player_attack);
				attack.color = pop_data.color;
				
				
	            // Then remove from pop_list
	            ds_list_delete(global.pop_list, i);
	            i--; 
	            continue;
	        }
	    }

	    // Write back
	    ds_list_replace(global.pop_list, i, pop_data);
	}
	
	
}

function all_pops_finished() {
    return ds_list_size(global.pop_list) == 0;
	}

	// Then in Step or after your pop code:
	if (all_pops_finished()) {
	    // Now we can drop blocks
	    drop_blocks();

	    // Optional: find more matches, chain reaction
	    if find_and_destroy_matches()
		{
			combo += 1;
		}
		else 
		{
			combo = 0;
		}
	}


function toss_down_row() {
    // Find topmost occupied row from top to bottom
    var topmost = height - 1;
    for (var j = 0; j < height; j++) {
        for (var i = 0; i < width; i++) {
            if (grid[i, j].type != -1) {
                topmost = j;
                break;
            }
        }
        if (topmost != height - 1) break;
    }

    // We want to place the new row *above* that
    var spawn_row = topmost - 1;
    if (spawn_row < 0) spawn_row = 0; // don't go negative

    // Now place gems in spawn_row
    for (var i = 0; i < width; i++) {
        grid[i, spawn_row] = irandom_range(0, numberOfGemTypes - 1);
        // Negative offset so it visually appears above
        gem_y_offsets[i, spawn_row] = -(gem_size * 2);
        locked[i, spawn_row] = true;
    }

    // Then do repeated drop until stable, if you want:
    var keepDropping = true;
    while (keepDropping) {
        keepDropping = drop_blocks_once();
    }
}
// Adapt drop_blocks into a version that returns true if it moved anything
function drop_blocks_once() {
    var moved = false;
    // Do the single pass bottom-to-top
    for (var i = 0; i < width; i++) {
        for (var j = height - 1; j > 0; j--) {
            if (grid[i, j].type == -1 && grid[i, j - 1].type != -1) {
                // Move block from above
                grid[i, j] = grid[i, j - 1];
                grid[i, j - 1] = create_gem(-1);
                gem_y_offsets[i, j] = -(gem_size); // or so
                moved = true;
            }
        }
    }
    return moved;
}

if (keyboard_check_pressed(vk_shift))
{
	toss_down_row();
}

/// @description Change all occupied cells in a given column to a single color (gem type).
/// @param colIndex  The column index (0..width-1)
/// @param newColor  The gem type or color index you want to apply
function colorize_column(colIndex, newColor) {
    
    // Safety check: ensure 'colIndex' is in range
    if (colIndex < 0 || colIndex >= width) {
        return;
    }
    
    // Loop through each row in this column
    for (var row = 0; row < height; row++) {
        // If the cell is occupied (not -1), set it to 'newColor'
        if (grid[colIndex, row].type != -1) {
            grid[colIndex, row].type = newColor;
        }
    }
}

/// @description Change all occupied cells in a given row to a single color (gem type).
/// @param rowIndex  The row index (0..height-1)
/// @param newColor  The gem type or color index you want to apply
function colorize_row(rowIndex, newColor) {

    // Safety check: if 'rowIndex' is outside the grid, do nothing
    if (rowIndex < 0 || rowIndex >= height) {
        return;
    }

    // Iterate each column in this row
    for (var col = 0; col < width; col++) {
        // If this cell is occupied (not -1), set it to newColor
        if (grid[col, rowIndex].type != -1) {
            grid[col, rowIndex].type = newColor; 
        }
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

        swap_in_progress = true;

        swap_info.from_x = ax;
        swap_info.from_y = ay;
        swap_info.to_x   = bx;
        swap_info.to_y   = by;
        swap_info.progress = 0;
        swap_info.speed = 0.1; // e.g., 0.1 means ~10 frames
    }
}

function is_being_destroyed(x, y) {
    for (var i = 0; i < ds_list_size(global.pop_list); i++) {
        var pop_data = ds_list_find_value(global.pop_list, i);
        if (pop_data.x == x && pop_data.y == y) {
            return true; // Found in the destruction list
        }
    }
    return false;
}

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



var hover_i = floor((mouse_x - board_x_offset) / gem_size);
var hover_j = floor((mouse_y - global_y_offset) / gem_size);

function colorize_block(rowIndex, colIndex, newColor)
{
	grid[rowIndex, colIndex].type = newColor;
}

function activate_bomb_gem(_x, _y) {
    for (var i = _x - 1; i <= _x + 1; i++) {
        for (var j = _y - 1; j <= _y + 1; j++) {
            if (i >= 0 && i < width && j >= 0 && j < height && grid[i, j] != -1) {
                destroy_block(i, j);
            }
        }
    }
}

function activate_shuffle() {
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            if (grid[i, j] != -1) {
                grid[i, j] = create_gem(irandom(numberOfGemTypes - 1));
            }
        }
    }
}

if keyboard_check_pressed(ord("E"))
{
	activate_bomb_gem(hover_i, hover_j);
}

if keyboard_check_pressed(ord("W"))
{
	colorize_column(hover_i, 2);
}

if keyboard_check_pressed(ord("D"))
{
	colorize_row(hover_j, 2);
}