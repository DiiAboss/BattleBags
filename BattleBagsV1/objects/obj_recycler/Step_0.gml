
/// @description Process recycling and block generation

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
        part_emitter_burst(particles, emitter, smoke_particle, 1);
    }
    
    // If processing is complete, potentially spawn a block
    if (process_time >= max_process_time) {
        processing = false;
        process_time = 0;
        cooldown = max_cooldown;
        
        // Determine if a block is created
        if (random(1) < success_chance) {
            // Choose a block type
            var block_type = choose_weighted_block_type();
            
            // Create deposit block
            var new_block = instance_create_depth(
                x + lengthdir_x(96, 270 + irandom_range(-2, 2)), 
                y + lengthdir_y(96, 270 + irandom_range(-2, 2)), 
                depth - 5, 
                obj_deposit_block
            );
            
            new_block.get_block_type();
            
            // Set the block type and physics properties
            with (new_block) {
                current_block_type = choose_weighted_block_type();
                state = "ready";
                // Apply physics
                //vspeed = 0;
                speed = random_range(other.eject_speed_min, other.eject_speed_max);
                hspeed = random_range(-2, 2);
                direction = 270;//random_range(other.eject_angle_min, other.eject_angle_max);
                gravity = 0.2;
                rotation_speed = random_range(-5, 5);
                
                // Set state
                //state = "falling";
            }
            
            // Create effect at ejection point
            part_emitter_burst(particles, emitter, sparkle_particle, 10);
            
            // Play sound
            // audio_play_sound(snd_block_eject, 1, false);
        } else {
            // Failed to create block - just emit some smoke
            part_emitter_burst(particles, emitter, smoke_particle, 5);
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
    
    // Create effect
    part_emitter_burst(particles, emitter, smoke_particle, 5);
    
    // Play sound
    // audio_play_sound(snd_recycler_process, 1, false);
}