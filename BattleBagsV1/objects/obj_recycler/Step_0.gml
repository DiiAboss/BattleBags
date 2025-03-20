
/// @description Process recycling and block generation

if (global.paused) return;

//// Function to select a block type based on weights
//function choose_weighted_block_type(_type) {
    //// Create a weighted list
    //var weighted_list = ds_list_create();
    //
    //if (_type == DEPOSIT_BLOCK.BLOCK)
        //{
            //// Add block types according to their weights
            //var keys = ds_map_find_first(block_weights);
            //while (!is_undefined(keys)) {
                //var weight = ds_map_find_value(block_weights, keys);
                //repeat(weight) {
                    //ds_list_add(weighted_list, keys);
                //}
                //keys = ds_map_find_next(block_weights, keys);
            //}
        //}
        //
        //if (_type == DEPOSIT_BLOCK.UPGRADE)
        //{
            //// Add block types according to their weights
            //var keys = ds_map_find_first(upgrade_weights);
            //while (!is_undefined(keys)) {
                //var weight = ds_map_find_value(upgrade_weights, keys);
//
                //repeat(weight) {
                    //ds_list_add(weighted_list, keys);
                //}
                //keys = ds_map_find_next(upgrade_weights, keys);
            //}
        //}
    //
    //// Select a random block type from the weighted list
    //var selected_type = ds_list_find_value(weighted_list, irandom(ds_list_size(weighted_list) - 1));
    //
    //
    //
    //// Clean up
    //ds_list_destroy(weighted_list);
    //
    //return selected_type;
//}
function choose_weighted_block_type(deposit_blocks, _type = DEPOSIT_BLOCK.RANDOM) {

    var weighted_list = [];
    
    var __type = _type;
    if (_type) == DEPOSIT_BLOCK.RANDOM
    {
        __type = choose(DEPOSIT_BLOCK.BLOCK, DEPOSIT_BLOCK.UPGRADE);
    }
    
    // Loop through each block in deposit_blocks
    var keys = variable_struct_get_names(deposit_blocks);
    var len = array_length(keys);

    // Build weighted list based on type
    for (var i = 0; i < len; i++) {
        var block = deposit_blocks[$ keys[i]];
        var __type = _type;
        if (_type) == DEPOSIT_BLOCK.RANDOM
        {
            __type = choose(DEPOSIT_BLOCK.BLOCK, DEPOSIT_BLOCK.UPGRADE);
        }
        if (block.type == __type && block.weight > 0) {
            repeat(block.weight) {
                array_push(weighted_list, keys[i]);
            }
        }
    }

    // Safety check if no weighted items exist
    if (array_length(weighted_list) == 0) {
        show_debug_message("No available blocks for type: " + string(__type));
        return undefined;
    }

    // Choose a random block from the weighted list
    var chosen_key = weighted_list[irandom(array_length(weighted_list) - 1)];
    return deposit_blocks[$ chosen_key];
}


if (rotation < max_rotation)
{
    rotation_direction = 1;
}

if (rotation > 0)
{
    rotation_direction = -1;
}



rotation = 0;
direction = rotation;


// Update cooldown
if (cooldown > 0) {
    cooldown--;
}

// Process animation if processing
if (processing) {
    process_time++;
    
    // Emit particles during processing
    if (process_time mod 5 == 0) {
        //part_emitter_burst(particles, emitter, smoke_particle, 1);
    }
    
    // If processing is complete, potentially spawn a block
    if (process_time >= max_process_time) {
        processing = false;
        process_time = 0;
        cooldown = max_cooldown;
        
        // Determine if a block is created
        if (random(1) < success_chance) {
            
            // Choose a block type
            var block_type = choose_weighted_block_type(deposit_blocks);
            
            if !(block_type) return;
            
            // Create deposit block
            var new_block = instance_create_depth(
                x + lengthdir_x(96, 270 + irandom_range(-2, 2)), 
                y + lengthdir_y(96, 270 + irandom_range(-2, 2)), 
                depth - 5, 
                obj_deposit_block, block_type
            );
            
            // Set the block type and physics properties
            with (new_block) {
                type = block_type.type;
                current_block_type = block_type.value;
                state = "ready";
                sprite = block_type.sprite;
                speed = random_range(other.eject_speed_min, other.eject_speed_max);
                hspeed = random_range(-2, 1);
                direction = 270;
                gravity = 0.2;
                rotation_speed = random_range(-1, 5);
            }
        }
    }
}

// Check for collision with transfer block
var transfer_block = instance_place(x, y, obj_block_transfer);
if (transfer_block != noone && cooldown <= 0 && !processing) {
    // Start processing
    processing = true;
    process_time = 0;
    
    // Destroy the transfer block
    with (transfer_block) {
        instance_destroy();
    }
}