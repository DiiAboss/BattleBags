
/// @description Process recycling and block generation

if (global.paused) return;

// Check for collision with transfer block
var transfer_block = instance_place(x, y, obj_block_transfer);
if (transfer_block != noone) {
    // Start processing
    recycler_queue += 1;
    // Destroy the transfer block
    with (transfer_block) {
        instance_destroy();
    }
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

if (recycler_queue > 0)
{
    processing = true;
}
else
{
    processing = false;
}

// Process animation if processing
if (processing) {
    process_time++;
    
    // If processing is complete, potentially spawn a block
    if (process_time >= max_process_time) {
        process_time = 0;
        cooldown = max_cooldown;
        
        // Determine if a block is created
        if (random(1) < success_chance) { // TODO: 50/50 chance to creat block, this can be modifiable.
            var spawn_x = x + lengthdir_x(96, 270 + irandom_range(-2, 2));
            var spawn_y = y + lengthdir_y(96, 270 + irandom_range(-2, 2));
            
            var new_deposit_block = create_deposit_block(self, spawn_x, spawn_y, deposit_blocks);
            
            if (new_deposit_block == noone) return;
                
            new_deposit_block.speed = random_range(eject_speed_min, eject_speed_max);
            new_deposit_block.direction = 270;
            new_deposit_block.hspeed = random_range(-2, 1);
            new_deposit_block.gravity = 0.2;
            
        }
        
        recycler_queue -= 1;
    }
}






 