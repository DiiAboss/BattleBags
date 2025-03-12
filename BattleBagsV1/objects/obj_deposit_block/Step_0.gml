/// @description Update deposit block state

if (y + speed > obj_floor.y - 64)
{
    if (speed <= 0)
    {
        speed = 0;
        y = obj_floor.y - 64;
        return;
    }
    
    direction =- direction;
    speed = speed * 0.5;
    
}

if (x > room_width - 32)
{
    direction = 180;
}

if  (x < room_width * 0.5)
{
    direction = 0;
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
        effect_create_above(ef_star, sparkle_x, sparkle_y, 0, c_white);
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
            effect_create_above(ef_ring, x, y - 16, 0, c_white);
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
