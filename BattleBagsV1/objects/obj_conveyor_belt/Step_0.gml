/// @description Update Conveyor Movement

// Update belt animation
belt_animation_offset += conveyor_speed * throughput_rate * 0.5;
if (belt_animation_offset >= 32) belt_animation_offset = 0;

// Only process if conveyor is active
if (!conveyor_active) exit;

// Move all blocks upward
for (var i = 0; i < ds_list_size(conveyor_blocks); i++) {
    var block_data = conveyor_blocks[| i];
    
    // Apply movement based on speed and throughput
    var effective_speed = conveyor_speed * throughput_rate;
    if (variable_struct_exists(block_data, "speed_multiplier")) {
        effective_speed *= block_data.speed_multiplier;
    }
    
    block_data.y_pos -= effective_speed;
    
    // Check if block has reached activation position
    if (block_data.y_pos <= conveyor_activation_y) {
        // Get the block type
        var block_type = variable_struct_exists(block_data, "block_type") ? 
                    block_data.block_type : BLOCK.RANDOM;
        
        // Activate the block (add to game board)
        activate_block(block_type, block_data.lane);
        
        // Update stats
        blocks_processed++;
        if (variable_struct_exists(block_data, "is_special") && block_data.is_special) {
            special_blocks_processed++;
        }
        
        // Remove from conveyor
        ds_list_delete(conveyor_blocks, i);
        i--; // Adjust the loop index
    }
}

// Process the queue whenever called
process_block_queue();

// Pulsing animation for highlight effects
pulsing_alpha = 0.3 + 0.2 * sin(current_time * 0.003);
