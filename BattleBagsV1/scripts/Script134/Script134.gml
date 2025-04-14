/// @description Create a falling block
/// @param {real} min_speed Minimum falling speed
/// @param {real} max_speed Maximum falling speed
/// @param {real} min_scale Minimum scale of the block (optional)
/// @param {real} max_scale Maximum scale of the block (optional)
/// @param {real} spawn_chance Chance to spawn a block (0-1) (optional)
/// @param {real} max_blocks Maximum blocks on screen (optional)
function create_falling_block(min_speed, max_speed, min_scale = 0.8, max_scale = 1.2, spawn_chance = 0.1, max_blocks = 20) {
    // Check if we should spawn a block this frame
    if (random(1) > spawn_chance) return;
    
    // Check if we've reached the maximum number of blocks
    if (instance_number(obj_falling_block) >= max_blocks) return;
    
    // Create a block
    var block = instance_create_layer(random(room_width), -50, "Instances", obj_falling_block);
    
    // Set properties
    with(block) {
        // Randomize block type
        block_type = irandom(7); // Assuming 8 block types (0-7)
        
        // Set movement speed
        fall_speed = random_range(min_speed, max_speed);
        
        // Set scale
        var block_scale = random_range(min_scale, max_scale);
        image_xscale = block_scale;
        image_yscale = block_scale;
        
        // Randomize rotation
        has_rotation = irandom(1); // 50% chance to have rotation
        if (has_rotation) {
            rotation_speed = random_range(-3, 3);
        } else {
            rotation_speed = 0;
        }
    }
    
    return block;
}

/// @description Generate multiple falling blocks
/// @param {real} count Number of blocks to try spawning
/// @param {real} min_speed Minimum falling speed
/// @param {real} max_speed Maximum falling speed
/// @param {real} min_scale Minimum scale of the block (optional)
/// @param {real} max_scale Maximum scale of the block (optional)
function generate_falling_blocks(count, min_speed, max_speed, min_scale = 0.8, max_scale = 1.2) {
    var blocks_created = 0;
    
    repeat(count) {
        var block = create_falling_block(min_speed, max_speed, min_scale, max_scale, 1, 100);
        if (block != undefined) blocks_created++;
    }
    
    return blocks_created;
}