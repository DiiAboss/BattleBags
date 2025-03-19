/// @description Update Conveyor Movement
/// 
/// 

if (global.paused) return;

if loading_blocks_timer > 0
{
    loading_blocks_timer --;
}

function group_blocks_step(conveyor_blocks) {
    y_positions = [];
    grouped_blocks = [];

    for (var i = 0; i < ds_list_size(conveyor_blocks); i++) {
        var block_data = conveyor_blocks[| i];
        var y_value = block_data.y_pos;

        var found_index = -1;
        for (var j = 0; j < array_length(y_positions); j++) {
            if (y_positions[j] == y_value) {
                found_index = j;
                break;
            }
        }

        if (found_index == -1) {
            array_push(y_positions, y_value);
            array_push(grouped_blocks, [i]);
        } else {
            array_push(grouped_blocks[found_index], i);
        }
    }
}

group_blocks_step(conveyor_blocks);
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
    
    if (array_length(conveyor_drones) > 0)
    {
        var num_of_drones = array_length(conveyor_drones);
        
        for (var d = 0; d < num_of_drones; d++)
        {
            if (block_data.y_pos > conveyor_drones[d].range_min && block_data.y_pos < conveyor_drones[d].range_max)
            {
                conveyor_drones[d].hand_y = block_data.y_pos;
                conveyor_drones[d].hand_x = conveyor_x_start;
                conveyor_drones[d].active = true;
            }
            else {
                conveyor_drones[d].active = false;
            }
        }
    }
    
        for (var k = 0; k < array_length(y_positions); k++) {
            var block_list = grouped_blocks[k];
            var block_count = array_length(block_list);
    
            var max_block_width = 8//conveyor_width * 0.9;  
            var block_spacing = max_block_width / block_count;
            var block_size = clamp(block_spacing * 0.8, 16, 64);  
            var start_x = x - (block_spacing * (block_count - 1)) * 0.5;
    
            for (var j = 0; j < block_count; j++) {
                var index = block_list[j];
                var block_data = conveyor_blocks[| index];
                
                if !(block_data) continue;
                
                var block_type = block_data.block_type;
                var block_sprite = block_sprites[? block_type];
    
                if (block_sprite == noone) {
                    block_sprite = sprite_for_block(BLOCK.RANDOM);
                }
    
                var block_x = start_x + (j * block_spacing);
            }
    }
}

// Process the queue whenever called
process_block_queue();

// Pulsing animation for highlight effects
pulsing_alpha = 0.3 + 0.2 * sin(current_time * 0.003);
