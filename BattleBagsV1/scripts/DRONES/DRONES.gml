function drone() constructor {
    drone_x = 0;
    drone_y = 0;
    my_sprite = spr_drone;
    experience = 0;
    max_experience = 100;
    level = 1;
    max_level = 10;
    target = noone;
    walk_direction = 0;
    aim_direction = 0;
    color = c_white;
    carry_capacity = 1;
    throw_distance = 128;
    selected = false;
    
    // Block carrying state
    blocks_carried = 0;
    carried_blocks = array_create(0); // Stores info about carried blocks
    
    // Movement properties
    move_speed = 2;
    state = "seeking"; // seeking, collecting, delivering, idle
    
    // Timers and counters
    pickup_timer = 0;
    max_pickup_timer = 15;
    throw_timer = 0;
    max_throw_timer = 15;
    
    update = function(game_control) {
        // Find nearest deposit block and conveyor belt
        var deposit_blocks = instance_exists(obj_deposit_block) ? 
                        instance_nearest(drone_x, drone_y, obj_deposit_block) : noone;
        var conveyor = instance_exists(obj_conveyor_belt) ? 
                    instance_nearest(drone_x, drone_y, obj_conveyor_belt) : noone;
        
        
        if (deposit_blocks != noone && deposit_blocks.y > conveyor.conveyor_start_y) return;
        
        
        if (drone_y != obj_conveyor_belt.conveyor_start_y)
        {
            drone_y = obj_conveyor_belt.conveyor_start_y;
        }
        
        // State machine for drone behavior
        switch(state) {
            case "seeking":
                // If deposit block exists and we're not at max capacity
                if (deposit_blocks != noone && blocks_carried < carry_capacity) {
                    
                    if (deposit_blocks.targetter != noone && deposit_blocks.targetter != self) deposit_blocks = instance_find(obj_deposit_block, irandom(instance_number(obj_deposit_block) - 1));
                     if !(deposit_blocks) return;  
                    if (deposit_blocks.targetter == noone) deposit_blocks.targetter = self;
                    // Go toward nearest deposit block
                    target = deposit_blocks;
                    var target_dir = (point_direction(drone_x, drone_y, target.x, drone_y));
                    walk_direction = target_dir;
                    
                    // Update position
                    drone_x += lengthdir_x(move_speed, walk_direction);
                    drone_y += lengthdir_y(move_speed, walk_direction);
                    
                    // Check if we've reached the deposit block
                    if (point_distance(drone_x, drone_y, target.x, target.y) < 10) {
                        state = "collecting";
                        pickup_timer = 0;
                    }
                } else if (blocks_carried > 0) {
                    // Already carrying blocks, head to conveyor
                    state = "delivering";
                } else {
                    // No blocks to collect or deliver, go to idle
                    state = "idle";
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
                            
                            with deposit_blocks
                            {
                                instance_destroy();
                            }
                            
                            blocks_carried++;
                            
                            // Play pickup sound if you have one
                            // audio_play_sound(snd_block_pickup, 1, false);
                            
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
                    // Move towards conveyor belt
                    target = conveyor;
                    var target_dir = point_direction(drone_x, drone_y, target.x, target.conveyor_start_y);
                    walk_direction = target_dir;
                    
                    // Update position
                    drone_x += lengthdir_x(move_speed, walk_direction);
                    drone_y += lengthdir_y(move_speed, walk_direction);
                    
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
                        
                        // Play throw sound if you have one
                        // audio_play_sound(snd_block_throw, 1, false);
                    }
                    
                    // Go back to seeking
                    state = "seeking";
                    throw_timer = 0;
                }
                break;
                
            case "idle":
                // Move toward right side of screen (or left if too far right)
                if (drone_x > room_width - 50) {
                    walk_direction = 180; // Move left
                } else if (drone_x < room_width * 0.5) {
                    walk_direction = 0; // Move right
                }
                
                // Move slower when idle
                drone_x += lengthdir_x(move_speed * 0.5, walk_direction);
                
                // Check if deposit blocks exist to resume work
                if (deposit_blocks != noone && blocks_carried < carry_capacity) {
                    state = "seeking";
                } else if (blocks_carried > 0 && conveyor != noone) {
                    state = "delivering";
                }
                break;
        }
        
        // Update facing direction (0-right, 180-left)
        aim_direction = (walk_direction > 90 && walk_direction < 270) ? 180 : 0;
        
        // Handle selection logic
        if (mouse_check_button_pressed(mb_left)) {
            if (point_distance(mouse_x, mouse_y, drone_x, drone_y) < 32) {
                // Click on this drone, select it
                selected = true;
                
                // You'll need to implement a way to deselect other drones
                // This could be handled in your game control object
            }
        }
    }
    
    draw = function() {
        var _dir = (aim_direction == 0) ? 1 : -1;
        
        // Draw drone
        draw_sprite_ext(my_sprite, 0, drone_x, drone_y, _dir, 1, 0, color, 1);
        
        // Draw state indicator (optional)
        var state_colors = {
            seeking: c_lime,
            collecting: c_yellow,
            delivering: c_orange,
            throwing: c_red,
            idle: c_gray
        };
        
        var indicator_color = variable_struct_exists(state_colors, state) ? 
                            variable_struct_get(state_colors, state) : c_white;
        
        draw_circle_color(
            drone_x, drone_y - 24, 
            4, indicator_color, indicator_color, 
            false
        );
        
        // Draw carried blocks
        for (var i = 0; i < blocks_carried; i++) {
            var block = carried_blocks[i];
            var block_x = drone_x + block.offset_x;
            var block_y = drone_y + block.offset_y;
            
            // Draw sprite for the block type
            var block_sprite = sprite_for_block(block.type);
            draw_sprite_ext(block_sprite, 0, block_x, block_y, 0.5, 0.5, 0, c_white, 1);
        }
        
        // Draw selection indicator if selected
        if (selected) {
            draw_circle(drone_x, drone_y, 36, true);
            draw_circle(drone_x, drone_y, 38, true);
        }
        
        // Draw state and timers for debugging
        if (selected) {
            draw_text(drone_x - 20, drone_y - 50, state);
            
            // Draw relevant timer based on state
            if (state == "collecting") {
                draw_healthbar(
                    drone_x - 20, drone_y - 40,
                    drone_x + 20, drone_y - 35,
                    (pickup_timer / max_pickup_timer) * 100,
                    c_black, c_yellow, c_green, 0, true, true
                );
            } else if (state == "throwing") {
                draw_healthbar(
                    drone_x - 20, drone_y - 40,
                    drone_x + 20, drone_y - 35,
                    (throw_timer / max_throw_timer) * 100,
                    c_black, c_yellow, c_green, 0, true, true
                );
            }
        }
    }
    
    show_stats = function() {
        // Only show stats if selected
        if (!selected) return;
        
        // Panel position and size
        var panel_x = room_width * 2/3;
        var panel_y = room_height * 2/3;
        var panel_width = 240;
        var panel_height = 180;
        
        // Draw background panel
        draw_set_alpha(0.8);
        draw_roundrect_color(
            panel_x, panel_y,
            panel_x + panel_width, panel_y + panel_height,
            c_navy, c_black, false
        );
        draw_set_alpha(1.0);
        
        // Draw border
        draw_roundrect(
            panel_x, panel_y,
            panel_x + panel_width, panel_y + panel_height,
            true
        );
        
        // Draw title
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_text(panel_x + panel_width/2, panel_y + 10, "Drone Stats");
        
        // Draw stats
        draw_set_halign(fa_left);
        var text_x = panel_x + 20;
        var text_y = panel_y + 40;
        var line_height = 20;
        
        draw_text(text_x, text_y, "Level: " + string(level) + "/" + string(max_level));
        draw_text(text_x, text_y + line_height, "Experience: " + string(experience) + "/" + string(max_experience));
        draw_text(text_x, text_y + line_height*2, "Carry Capacity: " + string(carry_capacity));
        draw_text(text_x, text_y + line_height*3, "Throw Distance: " + string(throw_distance));
        draw_text(text_x, text_y + line_height*4, "Speed: " + string(move_speed));
        draw_text(text_x, text_y + line_height*5, "State: " + string(state));
        
        // Reset text alignment
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}

function create_drone() {
    var _drone = new drone();
    return _drone;
}




