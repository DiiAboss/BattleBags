
// CONTROLS

function mouse_dragged() {
    // When the left mouse button is pressed, record the starting cell
    if (mouse_check_button_pressed(mb_left)) {
        // Convert mouse coordinates to grid indices
        selected_x = floor((mouse_x - board_x_offset) / gem_size);
        selected_y = floor((mouse_y - global_y_offset) / gem_size);

        // Only allow dragging if the selected cell is valid and not empty
        if (selected_x >= 0 && selected_x < width 
		&&  selected_y >= 0 && selected_y < height 
		&&  grid[selected_x, selected_y].type != -1) 
		{
            dragged = false; // Prepare for dragging
        } 
		else 
		{
            // Reset selection if clicking on an empty space
            selected_x = -1;
            selected_y = -1;
        }
    }

    // While the left mouse button is held down
    if (mouse_check_button(mb_left)) {
        if (!dragged && selected_x != -1 && selected_y != -1) 
		{
		    var current_x = floor((mouse_x - board_x_offset) / gem_size);
		    var current_y = floor((mouse_y - global_y_offset) / gem_size);

		   if (current_x >= 0 && current_x < width 
		   &&  current_y == selected_y // Horizontal swaps only
		   &&  current_x != selected_x) 
		   {
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

var hover_i = floor((mouse_x - board_x_offset) / gem_size);
var hover_j = floor((mouse_y - global_y_offset) / gem_size);

if (keyboard_check_pressed(vk_shift))
{
	toss_down_row(self);
}

if keyboard_check_pressed(ord("E"))
{
	activate_bomb_gem(self, hover_i, hover_j);
}

if keyboard_check_pressed(ord("W"))
{
	colorize_column(self, hover_i, 2);
}

if keyboard_check_pressed(ord("D"))
{
	colorize_row(self, hover_j, 2);
}

// ------------------------------------------------------
// 2) SMOOTH UPWARD MOVEMENT + SHIFT
// ------------------------------------------------------
global_y_offset -= shift_speed;

if (global_y_offset <= -gem_size) {
    global_y_offset = 0;
    shift_up();
}

darken_bottom_row(self);

// ------------------------------------------------------
// 4) GAME OVER CHECK
// ------------------------------------------------------
update_topmost_row();

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
// 5) Timers, speeds
// ------------------------------------------------------
spawn_timer = 60 / global.gameSpeed;
shift_speed = 0.1 * global.gameSpeed;

// Space for speed up
if (keyboard_check(vk_space)) {
	
    global.gameSpeed = 6;
	
} else {
	
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

// Then in Step or after your pop code:
if (all_pops_finished()) {
	// Now we can drop blocks
	drop_blocks(self);

	// Optional: find more matches, chain reaction
	if find_and_destroy_matches()
	{
		combo += 1;
	}
	else 
	{
		if (all_blocks_landed(self))
		{
			combo = 0;
		}
	}
}

gem_shake(self);

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
        grid[i, height - 1] = create_gem(irandom_range(0, numberOfGemTypes - 1));
        gem_y_offsets[i, height - 1] = gem_size;
    }

    // 4️⃣ Reset alpha so the newly spawned row fades in again
    darken_alpha = 0;

    // 5️⃣ Update the topmost row tracking
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
			    grid[i, j].shake_timer = 30; 
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
					color: gem.color,
					y_offset_global: global_y_offset
                };
				
				gem.popping = true;
				gem.pop_timer = 0;
				
                ds_list_add(global.pop_list, pop_info);
            }
        }
    }

    return found_any;
}




if all_blocks_landed(self)
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
	            destroy_block(self, pop_data.x, pop_data.y);
				// Mark gem for destruction after animation

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





function toss_down_row(_self) {
    var width = _self.width;
    var height = _self.height;
    var gem_size = _self.gem_size;
    
    for (var i = 0; i < width; i++) {
        var new_gem = create_gem(irandom_range(0, numberOfGemTypes - 1));

        // ✅ Place it in the grid at row 0
        _self.grid[i, 0] = new_gem;

        // ✅ Start it **above the screen** (visually)
        _self.gem_y_offsets[i, 0] = -gem_size * 2; 

        // ✅ Mark as falling
        new_gem.falling = true;
        new_gem.fall_delay = 10; // **Delay before falling**
    }

    // ✅ Ensure drop_blocks() will handle them
    drop_blocks(_self);
}


function drop_blocks_once() {
    var moved = false;
    
    for (var j = height - 1; j > 0; j--) { // ✅ Ensures `j - 1` is never negative
        for (var i = 0; i < width; i++) {
            if (grid[i, j].type == -1 && grid[i, j - 1].type != -1) { // ✅ Check before accessing
                // Move block from above
                grid[i, j] = grid[i, j - 1];
                grid[i, j - 1] = create_gem(-1);
                gem_y_offsets[i, j] = -(gem_size); // Smooth transition
                
                moved = true;
            }
        }
    }

    return moved;
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



