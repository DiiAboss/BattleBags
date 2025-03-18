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
        //effect_create_above(ef_star, effect_x, effect_y, 1, c_yellow);
    }
    
    // Add the block to the conveyor queue
    ds_list_add(conveyor_blocks, block_data);
    
    // Create visual effect for block addition
    var effect_x = x + (lane * (conveyor_width / lane_count));
    var effect_y = conveyor_start_y;
    //effect_create_above(ef_smoke, effect_x, effect_y, 0, c_white);
    
    // Optionally play a sound
    // audio_play_sound(snd_block_add, 1, false);
    
    // Return the index of the newly added block in the queue
    return ds_list_size(conveyor_blocks) - 1;
}

/// @function activate_block
/// @description Called when a block reaches activation point
/// @param {enum} block_type The type of block to activate
/// @param {real} lane The lane the block was in

function activate_block(block_type, lane) {

    // Queue the incoming block
    array_push(block_queue, block_type);
}



/// Process the queued blocks and place them onto the board properly
function process_block_queue() {
    var total_blocks = array_length(block_queue);
    var board_width = obj_game_control.width;
    var blocks_processed = 0;
    var current_row = 0;
    
    while (blocks_processed < total_blocks) {
        var blocks_this_row = min(board_width, total_blocks - blocks_processed);
        
        for (var i = current_row; i > 0; i--)
        {
            // Determine number of blocks for this row
            push_rows_down(i);
        }
        
        place_blocks_in_row(0, blocks_this_row);
        
        blocks_processed += blocks_this_row;
        current_row ++;
    }

    // Clear the queue after processing
    block_queue = array_create(0);
}

function place_blocks_in_row(row_index, blocks_to_place) {
    var board_width = obj_game_control.width;
    
    if (array_length(block_queue) < board_width)
    {
        var diff = board_width - blocks_to_place;
        for (var i = 0; i < diff; i++)
        {
            array_push(block_queue, -1);
        }
    }
    
    // Shuffle available columns to randomize placement
    block_queue = array_shuffle(block_queue);
    
    // Place blocks
    for (var i = 0; i < board_width; i++) {
        
            var type_to_spawn = array_pop(block_queue);
        if type_to_spawn != -1
            {
        obj_game_control.grid[i, row_index].type = type_to_spawn;
        obj_game_control.grid[i, row_index].falling = true; 
    }
    }
}

/// Helper function to push all rows down by one
function push_rows_down(current_row) {
    var board_width = obj_game_control.width;
    var height = obj_game_control.top_playable_row;

    // Move blocks from top downwards, starting at the top
    
    if (current_row > 0)
    {
        for (var col = 0; col < board_width; col++) {
            obj_game_control.grid[col, current_row].type = obj_game_control.grid[col, current_row - 1].type;
            obj_game_control.grid[col, current_row].falling = obj_game_control.grid[col, current_row - 1].falling;
        }
        
        // Clear the top row after pushing down
        for (var col = 0; col < board_width; col++) {
            obj_game_control.grid[col, current_row - 1].type = BLOCK.NONE;
            obj_game_control.grid[col, current_row - 1].falling = false;
        }
    }




    

}

/// Check if any block exists in specified row
function row_is_full(row_index) {
    var board_width = obj_game_control.width;
    var full = false;
    for (var col = 0; col < board_width; col++) {
        if (obj_game_control.grid[col, row_index].type == BLOCK.NONE) {
            return false;
        }
    }
    return true;
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
    //effect_create_above(ef_firework, x, conveyor_start_y, 1, c_lime);
}

/// @function unlock_lane
/// @description Unlocks an additional lane on the conveyor
function unlock_lane() {
    if (lanes_unlocked < lane_count) {
        lanes_unlocked++;
        // Visual effect for lane unlock
        var lane_x = x - conveyor_width/2 + (lanes_unlocked * (conveyor_width / lane_count));
        //effect_create_above(ef_firework, lane_x, (conveyor_start_y + conveyor_activation_y) / 2, 1, c_aqua);
        return true;
    }
    return false;
}