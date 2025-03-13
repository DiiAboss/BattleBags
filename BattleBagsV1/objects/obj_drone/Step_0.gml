// Find nearest deposit block and conveyor belt
// Helper function to find untargeted block sources
            function find_untargeted_source() {
                // Check for available deposit blocks
                var block_count = instance_number(obj_deposit_block);
                for (var i = 0; i < block_count; i++) {
                    var block = instance_find(obj_deposit_block, i);
                    if (block != noone && 
                        (!variable_instance_exists(block, "targetter") || 
                        block.targetter == noone)) {
                        return block;
                    }
                }
                
                // Check for available block stacks
                var stack_count = instance_number(obj_block_stack);
                for (var i = 0; i < stack_count; i++) {
                    var stack = instance_find(obj_block_stack, i);
                    if (stack != noone && stack.block_count > 0 && 
                        (!variable_instance_exists(stack, "targetter") || 
                        stack.targetter == noone)) {
                        return stack;
                    }
                }
                
                return noone;
            }


var deposit_blocks = noone;
if (deposit_blocks == noone)
{
    
    deposit_blocks = instance_exists(obj_deposit_block) ? 
                    instance_nearest(x, y, obj_deposit_block) : noone;
}



var conveyor = instance_exists(obj_conveyor_belt) ? 
            instance_nearest(drone_x, drone_y, obj_conveyor_belt) : noone;


// Keep drones at conveyor level
if (conveyor != noone && drone_y != conveyor.conveyor_start_y) {
    drone_y = conveyor.conveyor_start_y;
}

// State machine for drone behavior
switch(state) {
    case "seeking":
        // Find nearest deposit block or block stack
        if (deposit_blocks == noone)
       {
               var deposit_blocks = instance_exists(obj_deposit_block) ? 
                               instance_find(obj_deposit_block, irandom(instance_number(obj_deposit_block) - 1)) : noone;
       }
    
    if instance_exists(obj_deposit_block) && (distance_to_object(obj_deposit_block) <= 16) {
        deposit_blocks = instance_nearest(x, y, obj_deposit_block);
        target = instance_nearest(x, y, obj_deposit_block);
        state = "collecting";
        break;
    }

    if (deposit_blocks != noone) {
            
        if (deposit_blocks.targetter != id)
        {
            deposit_blocks = instance_find(obj_deposit_block, irandom(instance_number(obj_deposit_block) - 1))
        }
        target = deposit_blocks;
        // Check if target is already claimed
        if (target.targetter != noone && 
            target.targetter != id) {
            // Claim the target
                target.targetter = id;
            // Find an untargeted source
            var untargeted_source = find_untargeted_source();
            
            if (untargeted_source != noone) {
                target = untargeted_source;
            }
        }
        
        
        // Move toward target
        var target_dir = point_direction(drone_x, drone_y, target.x, drone_y);
        walk_direction = target_dir;
        
        // Update position with collision avoidance (only with other seeking drones)
        drone_x += lengthdir_x(move_speed, walk_direction);
        if (conveyor != noone) drone_y = conveyor.conveyor_start_y; // Stay on conveyor level
        
        // Check if we've reached the target
        if (point_distance(drone_x, drone_y, target.x, drone_y) <= 16) {
            state = "collecting";
            pickup_timer = max_pickup_timer;
        }
    }
        break;
    
    
    
        
    case "collecting":
        // Collection animation/timer
        pickup_timer++;
        
        if (pickup_timer >= max_pickup_timer && blocks_carried < carry_capacity) {
            if (deposit_blocks != noone) {
                // Get block type based on deposit block's current state
                var block_type = deposit_blocks.get_block_type();
                
                if (block_type != -1) {
                    // Store the block in our carried blocks array
                    array_push(carried_blocks, {
                        type: block_type,
                        offset_x: irandom_range(-8, 8),
                        offset_y: -16 - (blocks_carried * 8) // Stack blocks visually
                    });
                    
                    // Destroy the deposit block
                    with (deposit_blocks) {
                        instance_destroy();
                    }
                    
                    blocks_carried++;
                    
                    // Reset timer and transition state
                    pickup_timer = 0;
                    
                    // If full, go to delivering, otherwise keep seeking
                    if (blocks_carried >= carry_capacity) {
                        state = "delivering";
                    } else {
                        state = "seeking";
                    }
                } else {
                    // No block available, go back to seeking
                    state = "seeking";
                }
            } else {
                // No deposit block found, go back to seeking
                state = "seeking";
            }
        }
        break;
        
    case "delivering":
        if (conveyor != noone) {
            // Move towards conveyor belt with collision avoidance
            target = conveyor;
            var target_dir = point_direction(drone_x, drone_y, target.x, target.conveyor_start_y);
            walk_direction = target_dir;
            
            // Update position
            drone_x += lengthdir_x(move_speed, walk_direction);
            drone_y = conveyor.conveyor_start_y; // Stay on conveyor level
            
            // Check if we're within throwing distance of conveyor belt
            if (point_distance(drone_x, drone_y, target.x, target.conveyor_start_y) <= throw_distance && blocks_carried > 0) {
                // Start throwing animation
                state = "throwing";
                throw_timer = 0;
            }
        } else {
            // No conveyor belt found, go to idle
            state = "idle";
        }
        break;
        
    case "throwing":
        // Throwing animation/timer
        throw_timer = max_throw_timer;
        
        if (throw_timer >= max_throw_timer) {
            // Throw all blocks
            if (blocks_carried > 0 && conveyor != noone) {
                // Add blocks to conveyor
                for (var i = 0; i < blocks_carried; i++) {
                    with (conveyor) {
                        add_block_to_conveyor(other.carried_blocks[i].type);
                    }
                }
                
                // Reset carried blocks
                blocks_carried = 0;
                carried_blocks = array_create(0);
            }
            
            // Go back to seeking
            state = "seeking";
            throw_timer = 0;
        }
        break;
        
    case "idle":
        // Move with collision avoidance
        if (drone_x > room_width - 50) {
            walk_direction = 180; // Move left
        } else if (drone_x < room_width * 0.5) {
            walk_direction = 0; // Move right
        }
        
        // Move slower when idle but still avoid collisions
        drone_x += lengthdir_x(move_speed * 0.5, walk_direction);
        if (conveyor != noone) drone_y = conveyor.conveyor_start_y; // Stay on conveyor level
        
        // Check if deposit blocks exist to resume work
        if (deposit_blocks != noone && blocks_carried < carry_capacity) {
            state = "seeking";
        } else if (blocks_carried > 0 && conveyor != noone) {
            state = "delivering";
        }
        break;
}

// Keep drone within screen bounds
drone_x = clamp(drone_x, 0, room_width);

// Update facing direction (0-right, 180-left)
aim_direction = (walk_direction > 90 && walk_direction < 270) ? 180 : 0;

// Handle selection logic
if (mouse_check_button_pressed(mb_left)) {
    if (point_distance(mouse_x, mouse_y, drone_x, drone_y) < 32) {
        // Click on this drone, select it
        
        // Deselect all other drones
        var all_drones = instance_number(obj_drone);
        for (var i = 0; i < all_drones; i++) {
            var drone_inst = instance_find(obj_drone, i);
            if (drone_inst != id) {
                drone_inst.selected = false;
            }
        }
        
        selected = true;
    }
}
