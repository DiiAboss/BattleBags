/// @description Update deposit block state
gravity = 0;

var block_below = collision_rectangle(x - 16, y + 16, x + 16, y + 32, obj_deposit_block, false, true);//instance_position(x, y + 17, obj_deposit_block);


if block_below != noone
{
    if (block_below.falling == false)
    base = block_below.y - 17;
}
else {
    base = obj_conveyor_belt.conveyor_start_y;
}


if (abs(vsp) < 1 && (y >= base - 1))
{
    y = base;
    vsp = 0;
    speed = 0;
    falling = false;
}
else {
    
    if (y < base)
    {
        var grv = 0.2;
        vsp += grv;
    }
    
    if (y >= base)
    {
        y -= 1;
        vsp = -vsp * 0.5;
        speed = 0;
    }
    
    y += vsp;
}


if !(falling)
{
    if (y < base)
    {
        falling = true;
    }
    else {
        y = base;
        grv = 0;
        vsp = 0;
        gravity = 0;
        speed = speed * 0.5;
    }
}

// Conveyor belt movement adjustments
if (x > room_width - 32) {
    x -= 4;
    direction = 180;
}
if (x < room_width * 0.5) {
    x+= 4;
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

;

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
