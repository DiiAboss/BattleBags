/// @description Update deposit block state

if (y > obj_conveyor_belt.conveyor_start_y)
{

    if (speed <= 0)
    {
        speed = 0;
        gravity = 0;
        //return;
    }
    else {
        speed = speed * 0.25;
        direction =- direction;
    }

    y = obj_conveyor_belt.conveyor_start_y;
}

if (x > room_width - 32)
{
    direction = 180;
}

if  (x < room_width * 0.5)
{
    direction = 0;
}

// NEW: Check for nearby blocks to stack with
if (speed == 0) // Only check for stacking when block is settled
{
    // Look for other blocks within stacking distance
    var stacking_distance = 32; // Adjust this value as needed
    var nearby_block = instance_nearest(x, y, obj_deposit_block);
    
    if (nearby_block != noone && nearby_block != id) // Make sure we don't detect ourselves
    {
        // Calculate distance to nearest block
        var dist = point_distance(x, y, nearby_block.x, nearby_block.y);
        
        if (dist <= stacking_distance)
        {
            // We found a block to stack with!
            
            // Initialize our stacked_blocks list if it doesn't exist
            if (!variable_instance_exists(id, "stacked_blocks"))
            {
                stacked_blocks = ds_list_create();
                ds_list_add(stacked_blocks, current_block_type);
                
                // Initialize pyramid grid
                initialize_pyramid_grid();
            }
            
            // Add the other block's types to our stack
            if (variable_instance_exists(nearby_block, "stacked_blocks"))
            {
                for (var i = 0; i < ds_list_size(nearby_block.stacked_blocks); i++)
                {
                    var block_type = ds_list_find_value(nearby_block.stacked_blocks, i);
                    ds_list_add(stacked_blocks, block_type);
                }
                
                // Clean up the other block's list
                ds_list_destroy(nearby_block.stacked_blocks);
            }
            else
            {
                // Just add the single block type
                ds_list_add(stacked_blocks, nearby_block.current_block_type);
            }
            
            // Update our pyramid grid with new blocks
            update_pyramid_with_blocks();
            
            // Destroy the other block
            with (nearby_block)
            {
                instance_destroy();
            }
            
            // Visual indication that blocks have stacked
            effect_create_above(ef_ring, x, y, 1, c_yellow);
        }
    }
}

// Function to select a block type based on weights
function choose_weighted_block_type() {
    // Create a weighted list
    var weighted_list = ds_list_create();
    // Add block types according to their weights
    var keys = ds_map_find_first(block_weights);
    while (!is_undefined(keys)) {
        var weight = ds_map_find_value(block_weights, keys);
        repeat(weight) {
            ds_list_add(weighted_list, keys);
        }
        keys = ds_map_find_next(block_weights, keys);
    }
    
    // Select a random block type from the weighted list
    var selected_type = ds_list_find_value(weighted_list, irandom(ds_list_size(weighted_list) - 1));
    
    // Clean up
    ds_list_destroy(weighted_list);
    
    return selected_type;
}


// NEW: Initialize pyramid grid structure
function initialize_pyramid_grid() {
    // Pyramid configuration
    max_width = 5;
    max_height = 4;
    block_size = 32;
    horizontal_spacing = 32;
    vertical_spacing = 24;
    
    // Create the grid to hold block types
    blocks_grid = ds_grid_create(max_width, max_height);
    
    // Initialize all grid positions to empty
    for (var yy = 0; yy < max_height; yy++) {
        for (var xx = 0; xx < max_width; xx++) {
            blocks_grid[# xx, yy] = -1; // -1 represents no block
        }
    }
}

// NEW: Update pyramid with current stacked blocks
function update_pyramid_with_blocks() {
    // Reset the grid
    for (var yy = 0; yy < max_height; yy++) {
        for (var xx = 0; xx < max_width; xx++) {
            blocks_grid[# xx, yy] = -1;
        }
    }
    
    // Get total number of blocks
    var total_blocks = ds_list_size(stacked_blocks);
    var block_index = 0;
    
    // Fill from bottom to top
    for (var yy = max_height - 1; yy >= 0; yy--) {
        // Calculate width for this row (wider at bottom, narrower at top)
        var row_width = min(max_width, max_height - yy);
        
        // Center the blocks in each row
        var start_x = floor((max_width - row_width) / 2);
        
        for (var xx = 0; xx < max_width; xx++) {
            // Only place blocks within the row's width and if we have blocks left
            if (xx >= start_x && xx < start_x + row_width && block_index < total_blocks) {
                // Get the block type from our stacked_blocks list
                var block_type = ds_list_find_value(stacked_blocks, block_index);
                blocks_grid[# xx, yy] = block_type;
                block_index++;
            }
        }
    }
}

// NEW: Get offset for centering blocks in row
function x_offset_for_row(row) {
    var row_width = min(max_width, max_height - row);
    return (max_width - row_width) * horizontal_spacing / 2;
}

// NEW: Function to find and remove the top block (for drones)
function get_top_block() {
    if (!variable_instance_exists(id, "stacked_blocks") || ds_list_size(stacked_blocks) == 0) {
        return -1; // No blocks available
    }
    
    // Find the topmost block in the pyramid
    for (var yy = 0; yy < max_height; yy++) {
        for (var xx = 0; xx < max_width; xx++) {
            if (blocks_grid[# xx, yy] != -1) {
                // Found a block, get its type
                var block_type = blocks_grid[# xx, yy];
                
                // Remove from grid
                blocks_grid[# xx, yy] = -1;
                
                // Remove from list (find the index in the list)
                var list_index = -1;
                for (var i = 0; i < ds_list_size(stacked_blocks); i++) {
                    if (ds_list_find_value(stacked_blocks, i) == block_type) {
                        list_index = i;
                        break;
                    }
                }
                
                if (list_index != -1) {
                    ds_list_delete(stacked_blocks, list_index);
                }
                
                // Update the pyramid grid
                update_pyramid_with_blocks();
                
                // Create effect at the position where block was removed
                var block_x = xx * horizontal_spacing + x_offset_for_row(yy);
                var block_y = yy * vertical_spacing;
                effect_create_above(ef_spark, x + block_x, y - block_y, 0, c_white);
                
                // Return the block type
                return block_type;
            }
        }
    }
    
    return -1; // Should never reach here if we've checked correctly
}

// NEW: Check if a block is on top (no block above it)
function is_top_block(x_pos, y_pos) {
    // If we're already at the top row, it's a top block
    if (y_pos == 0) return true;
    
    // Check if there's any block above this one
    for (var yy = 0; yy < y_pos; yy++) {
        if (blocks_grid[# x_pos, yy] != -1) {
            return false;
        }
    }
    
    return true;
}

// Visual updates
float_offset = sin(current_time * float_speed) * float_range;
glow_alpha = 0.5 + sin(current_time * 0.002) * 0.2;

// Sparkle effect timer (when block is ready)
if (state == "ready") {
    sparkle_timer++;
    if (sparkle_timer >= sparkle_interval) {
        sparkle_timer = 0;
        var sparkle_x = x + irandom_range(-16, 16);
        var sparkle_y = y - 16 + irandom_range(-8, 8);
        //effect_create_above(ef_star, sparkle_x, sparkle_y, 0, c_white);
    }
}

// State updates
switch(state) {
    case "cooldown":
        // Increment regeneration timer
        regen_timer++;
        
        // Check if regeneration is complete
        if (regen_timer >= max_regen_time) {
            state = "ready";
            
            // Create effect to show block is ready
            //effect_create_above(ef_ring, x, y - 16, 0, c_white);
        }
        break;
        
    case "depleted":
        // Increment depletion recovery timer
        depletion_timer++;
        
        // Check if depletion recovery is complete
        if (depletion_timer >= max_depletion_time) {
            state = "ready";
            current_block_type = choose_weighted_block_type(self);
            
            // Create effect to show source is active again
            repeat(5) {
                var effect_x = x + irandom_range(-24, 24);
                var effect_y = y + irandom_range(-24, 0);
                effect_create_above(ef_firework, effect_x, effect_y, 0, c_white);
            }
        }
        break;
}
