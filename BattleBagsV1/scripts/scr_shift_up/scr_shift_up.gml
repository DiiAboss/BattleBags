// Script Created By DiiAboss AKA Dillon Abotossaway
///@function shift_up
///
///@description Moves the entire board up by one row, including buffer spaces.
///
///@param {id} player - The game object that contains the grid.

function shift_up(player) {
    var width = player.board_width;
    var height = player.board_height;

    // 1️⃣ Shift from bottom to top (including buffer zones)
    for (var j = 0; j < height - 1; j++) { // ✅ Process all rows, including buffers
        for (var i = 0; i < width; i++) {
            var current_block = player.grid[i, j];
            
            
            
           // ✅ Process **Big Blocks** shifting upwards
           if (current_block.is_big) {
               shift_big_blocks(player, i, j);
           }
 
			else
			{
				// ✅ Normal gem movement
			    player.grid[i, j] = player.grid[i, j + 1];
                process_bug_blocks(player, i, j);
			}
        }
    }
    
    if (player.swap_in_progress)
    {
        player.swap_info.to_y   -= 1;
        player.swap_info.from_y -= 1;
    }

    // 2️⃣ Shift all popping gems in `_self.pop_list`
    for (var k = 0; k < ds_list_size(player.pop_list); k++) {
        var pop_data = ds_list_find_value(player.pop_list, k);
        
        // ✅ Move each popping gem up **one row**
        pop_data.y -= 1;
        pop_data.y_offset_global = player.global_y_offset;
        
        ds_list_replace(player.pop_list, k, pop_data);
    }

    // 3️⃣ Spawn a new random row at the **very bottom of the grid**
    for (var i = 0; i < width; i++) {
        // ✅ Ensure **only spawn new blocks in the last row**
        player.grid[i, height - 1] = create_block(player, BLOCK.RANDOM, POWERUP.NONE);
    }

    // 4️⃣ Reset darken alpha so the new row fades in again
    player.darken_alpha = 0;
    
	number_of_rows_spawned ++;
    
    objective_progress(OBJECTIVE_TYPE.CLEAR_LINES, undefined, 1);
}


function process_bug_blocks(player, block_x, block_y)
{
    var board_x_offset   = player.board_x_offset;
    var gem_size         = player.gem_size;
    var offset           = player.offset;
    var global_y_offset  = player.global_y_offset;
    var _depth           = player.depth;
    var current_block    = player.grid[block_x, block_y];
    
    if (current_block.type == BLOCK.BUG)
    {
        player.grid[block_x, block_y].life_counter -= 1;
        //show_debug_message("BUG[" +string(i) + ", " + string(j) + "] - " + string(current_block.life_counter));
        if (current_block.life_counter <= 0)
        {
            //show_debug_message("BUG[" +string(i) + ", " + string(j) + "] - Targetted for destroy")
            var spawn_x = board_x_offset + (block_x * gem_size) + offset + current_block.offset_x;
            var spawn_y = (block_y * gem_size) + global_y_offset + current_block.offset_y + offset + current_block.draw_y;
            var bug = instance_create_depth(spawn_x, spawn_y, _depth - 1, obj_bug);  
            bug.target = obj_recycler;
            //destroy_block(self, block_x, block_y);
            player.grid[block_x, block_y] = create_block(player, BLOCK.BLACK); 
            player.grid[block_x, block_y].type = BLOCK.NONE;
            //continue; 
        }
    }
}


function shift_big_blocks(player, block_x, block_y)
{
    var current_block = player.grid[block_x, block_y];
    var parent_x = current_block.big_parent[0];
    var parent_y = current_block.big_parent[1];
    var parent_block = player.grid[parent_x, parent_y];
    var big_block_width = parent_block.mega_width;
    var big_block_height = parent_block.mega_height;

    // ✅ Only process once for the **parent block**
    if (block_x == parent_x && block_y == parent_y) {
        var new_y = parent_y - 1; // 🔹 Move up one row
        
        // ✅ Create a list to store all block positions
        var parts_to_move = ds_list_create();
    
        // ✅ Loop through all parts of the shape & store their positions
        for (var bx = 0; bx < big_block_width; bx++) {
            for (var by = 0; by < big_block_height; by++) {
                var old_x = parent_x + bx;
                var old_y = parent_y + by;
                var new_x = old_x;
                var new_y_pos = old_y - 1; // 🔹 Shift Up
    
                // ✅ Only add if it's part of the big block
                if (player.grid[old_x, old_y].big_parent[0] == parent_x && player.grid[old_x, old_y].big_parent[1] == parent_y) {
                    ds_list_add(parts_to_move, [old_x, old_y, new_x, new_y_pos]);
                }
            }
        }
    
        // ✅ Check if all parts can move up before proceeding
        var can_move = true;
        for (var k = 0; k < ds_list_size(parts_to_move); k++) {
            var data = ds_list_find_value(parts_to_move, k);
            var new_x = data[2];
            var new_y_pos = data[3];
        }
    
        // ✅ If all parts can move, proceed with shifting
        if (can_move) {
            for (var k = 0; k < ds_list_size(parts_to_move); k++) {
                var data = ds_list_find_value(parts_to_move, k);
                var old_x = data[0];
                var old_y = data[1];
                var new_x = data[2];
                var new_y_pos = data[3];
                
                if (new_y_pos < 0)
                {
                    return;
                }
                
                // ✅ Move block to new position
                player.grid[new_x, new_y_pos] = player.grid[old_x, old_y];
                
                player.grid[old_x, old_y] = player.grid[old_x, old_y + 1]; // This actually worked (I used to create an empty block here...
                
                player.grid[new_x, new_y_pos].big_parent = [parent_x, new_y]; // ✅ Update parent reference
            }
    
            // ✅ Ensure Mega Block remains properly referenced
            player.grid[parent_x, new_y].mega_width = big_block_width;
            player.grid[parent_x, new_y].mega_height = big_block_height;
        }
    
        // ✅ Clean up memory
        ds_list_destroy(parts_to_move);
    }
}
