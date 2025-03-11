/// @function add_block_to_conveyor
/// @description Adds a block to the conveyor belt queue
/// @param {enum} block_type The type of block to add
/// @param {real} lane Optional lane number (defaults to 0)
/// @param {real} speed_mult Optional speed multiplier (defaults to 1)
function add_block_to_conveyor(block_type, lane = 0, speed_mult = 1) {
    // Make sure lane is valid
    lane = clamp(lane, 0, lanes_unlocked - 1);
    
    // Create block data structure
    var block_data = {
        block_type: block_type,
        y_pos: conveyor_start_y,
        lane: lane,
        speed_multiplier: speed_mult,
        is_special: false,
        creation_time: current_time
    };
    
    // Determine if this is a special block type
    if (block_type == BLOCK.BLACK || block_type == BLOCK.WILD || 
        block_type == BLOCK.MEGA || block_type == BLOCK.CURSE) {
        block_data.is_special = true;
        
        // Special blocks might move slower on conveyor
        block_data.speed_multiplier = 0.75;
        
        // Create visual effect for special blocks
        var effect_x = x + (lane * (conveyor_width / lane_count));
        var effect_y = conveyor_start_y;
        effect_create_above(ef_star, effect_x, effect_y, 1, c_yellow);
    }
    
    // Add the block to the conveyor queue
    ds_list_add(conveyor_blocks, block_data);
    
    // Create visual effect for block addition
    var effect_x = x + (lane * (conveyor_width / lane_count));
    var effect_y = conveyor_start_y;
    effect_create_above(ef_smoke, effect_x, effect_y, 0, c_white);
    
    // Optionally play a sound
    // audio_play_sound(snd_block_add, 1, false);
    
    // Return the index of the newly added block in the queue
    return ds_list_size(conveyor_blocks) - 1;
}

/// @function activate_block
/// @description Called when a block reaches the activation point
/// @param {enum} block_type The type of block to activate
/// @param {real} lane The lane the block was in
function activate_block(block_type, lane) {
    // Create visual effect
    var effect_x = x - conveyor_width/2 + (lane * (conveyor_width / lane_count)) + (conveyor_width / lane_count / 2);
    var effect_y = conveyor_activation_y;
    effect_create_above(ef_ring, effect_x, effect_y, 0, c_white);
    
    // Add block to the game board
    with (player_obj) {
        // Determine spawn column based on lane position
        var spawn_column = irandom(width - 1);
        
        // Create the block in the top row
        grid[spawn_column, top_playable_row].type = block_type;
        grid[spawn_column, top_playable_row].falling = true;
        
        // Special processing for certain block types
        if (block_type == BLOCK.BLACK) {
            // Black blocks might have special behavior
        }
        else if (block_type == BLOCK.WILD) {
            // Wild blocks might have special behavior
        }
    }
}

/// @function pause_conveyor
/// @description Pauses the conveyor belt
function pause_conveyor() {
    conveyor_active = false;
}

/// @function resume_conveyor
/// @description Resumes the conveyor belt
function resume_conveyor() {
    conveyor_active = true;
}

/// @function upgrade_throughput
/// @description Increases the conveyor throughput rate
/// @param {real} amount The amount to increase the rate by
function upgrade_throughput(amount) {
    throughput_rate += amount;
    // Visual effect for upgrade
    effect_create_above(ef_firework, x, conveyor_start_y, 1, c_lime);
}

/// @function unlock_lane
/// @description Unlocks an additional lane on the conveyor
function unlock_lane() {
    if (lanes_unlocked < lane_count) {
        lanes_unlocked++;
        // Visual effect for lane unlock
        var lane_x = x - conveyor_width/2 + (lanes_unlocked * (conveyor_width / lane_count));
        effect_create_above(ef_firework, lane_x, (conveyor_start_y + conveyor_activation_y) / 2, 1, c_aqua);
        return true;
    }
    return false;
}