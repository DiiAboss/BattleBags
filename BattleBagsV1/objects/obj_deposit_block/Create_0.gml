/// @description Initialize deposit block
// Basic properties
sprite_index = spr_preview_blocks;
image_speed = 0;
depth = 10;

// Block generation properties
block_types = [
    BLOCK.RED, 
    BLOCK.YELLOW, 
    BLOCK.GREEN, 
    BLOCK.PINK, 
    BLOCK.PURPLE,
    BLOCK.LIGHTBLUE,
    BLOCK.ORANGE,
    BLOCK.BLUE
];

rand = irandom_range(-99999, 99999);

// Rarity weights for different block types (higher = more common)
block_weights = ds_map_create();
ds_map_add(block_weights, BLOCK.RED, 5);
ds_map_add(block_weights, BLOCK.YELLOW, 5);
ds_map_add(block_weights, BLOCK.GREEN, 5);
ds_map_add(block_weights, BLOCK.PINK, 5);
ds_map_add(block_weights, BLOCK.PURPLE, 5);
ds_map_add(block_weights, BLOCK.LIGHTBLUE, 5);
ds_map_add(block_weights, BLOCK.ORANGE, 5);
ds_map_add(block_weights, BLOCK.BLUE, 5);

// Rare types have lower chance of appearing
ds_map_add(block_weights, BLOCK.BLACK, 25);
ds_map_add(block_weights, BLOCK.WILD, 0);

// Block state management
state = "ready";
regen_timer = 0;
max_regen_time = room_speed * 3; // 3 seconds to regenerate
depletion_chance = 0.1; // 10% chance to become depleted after pickup
depletion_timer = 0;
max_depletion_time = room_speed * 15; // 15 seconds to recover from depletion

// Visual properties
float_offset = 0;
float_speed = 0.01;
float_range = 1;
glow_alpha = 0;
sparkle_timer = 0;
sparkle_interval = 10;
max_height = 99;
max_width = 99;

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

// Interface function for drones to get a block
get_block_type = function() {
    if (state == "ready") {
        // Store the current block type to return
        var block_to_return = current_block_type;
        
        // Transition to cooldown state
        state = "cooldown";
        regen_timer = 0;
        
        // Check if source becomes depleted
        if (random(1) < depletion_chance) {
            state = "depleted";
            depletion_timer = 0;
        } else {
            // Generate the next block type right away
            current_block_type = choose_weighted_block_type();
        }
        
        // Create pickup effect
        effect_create_above(ef_spark, x, y - 8, 0, c_white);
        
        return block_to_return;
    }
    
    // No block available
    return -1;
}

current_block_type = choose_weighted_block_type();

targetter = noone;
falling = true;
vsp = 1;
base = obj_conveyor_belt.conveyor_start_y;