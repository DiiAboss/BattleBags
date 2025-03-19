function Drone(_id, _x, _y) constructor {
    x = _x;
    y = _y;
    id = _id;
    my_sprite = spr_drone;
    color = c_white;
    size = 32;
    coll_offset = size * 0.5;
    coll_x_min = x - (coll_offset);
    coll_x_max = x - (coll_offset);
    coll_y_min = y - (coll_offset);
    coll_y_max = y + (coll_offset);
    
    collision = false;
     
    color = c_white;
    // Basic Stats
    stats = {
        move_speed: 2,
        carry_capacity: 8,
        throw_distance: 128,
        experience: 0,
        max_experience: 100,
        level: 1,
        max_level: 10,
        pickup_speed: 15,
        throw_speed: 15,
        max_pickup_timer: 1,
        wait_to_return_max: 60,
        max_throw_timer: 1,
        max_think_timer: 15,
    };
    
    // State and targeting
    state = "idle";
    target = noone;
    blocks_carried = 0;
    carried_blocks = array_create(0); // Stores info about carried blocks
    
    pickup_timer = stats.max_pickup_timer;
    wait_to_return = stats.wait_to_return_max;
    throw_timer = stats.max_throw_timer;
    
    throw_progress = 0;
    throw_duration = 30; // frames it takes to throw
    is_throwing = false;
    
    aim_direction = 0;
    walk_direction = 0;
    selected = false; 
    
    think_timer = 0;
    
    // Modular Functions
    mods = [];
    
    update = function()
    {
        think_timer ++;
        
        coll_x_min = x - (coll_offset);
        coll_x_max = x - (coll_offset);
        coll_y_min = y - (coll_offset);
        coll_y_max = y + (coll_offset);
        
        var game_control = obj_game_control;
        collision = collide_with_other_drones(game_control);
        var deposit_blocks = noone;
        if (deposit_blocks == noone)
        {
            
            deposit_blocks = instance_exists(obj_deposit_block) ? 
                            instance_nearest(x, y, obj_deposit_block) : noone;
        }
        
        var conveyor =  instance_nearest(x, y, obj_conveyor_belt);
        
        if (conveyor == noone) return;
            
            
        // Keep drones at conveyor level
        if (conveyor != noone && y != conveyor.conveyor_start_y) {
            y = conveyor.conveyor_start_y;
        }
        
        if (deposit_blocks != noone)
        {
            if (blocks_carried < stats.carry_capacity)
                    {
                        if (point_distance(x, y, instance_nearest(x, y, obj_deposit_block).x, instance_nearest(x, y, obj_deposit_block).y) < 16)
                        {
                            target = instance_nearest(x, y, obj_deposit_block);
                            state = "collecting";
                        }
                    }
        }
        
        
        switch(state) {
            case "seeking":
                seek_target(conveyor);
                break;
        
            case "collecting":
                collect_blocks(deposit_blocks);
                break;
        
            case "delivering":
                deliver_blocks(conveyor);
                break;
        
            case "throwing":
                throw_blocks(conveyor);
                break;
        
            case "idle":
                idle_behavior(conveyor, deposit_blocks);
                break;
        }
        
        // Keep drone within screen bounds
        x = clamp(x, 0, room_width);
        
        // Update facing direction (0-right, 180-left)
        aim_direction = (walk_direction > 90 && walk_direction < 270) ? 180 : 0;
        
        // Handle selection logic
        if (mouse_check_button_pressed(mb_left)) {
            if (point_distance(mouse_x, mouse_y, x, y) < 32) {
                // Click on this drone, select it
                
                // Deselect all other drones
                var all_drones = instance_number(obj_drone_1);
                for (var i = 0; i < all_drones; i++) {
                    var drone_inst = instance_find(obj_drone_1, i);
                    if (drone_inst.id != id) {
                        drone_inst.drone.selected = false;
                    }
                }
                
                selected = true;
            }
        }
    }
    
    draw = function()
    {
        var _dir = (aim_direction == 0) ? 1 : -1;
        var hover_amount = 8;
        var hover = hover_draw(hover_amount);
        
        if (collision) color = c_red
            else color = c_white;
                
        // Draw drone
        draw_sprite_ext(my_sprite, 0, x, y + hover, _dir, 1, 0, color, 1);
        
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
            x, y - 24, 
            4, indicator_color, indicator_color, 
            false
        );
        
        // Draw carried blocks (regular stacked)
            if (!is_throwing) {
                for (var i = 0; i < blocks_carried; i++) {
                    var block = carried_blocks[i];
                    var block_x = x + block.offset_x;
                    var block_y = y + block.offset_y;
                    var block_sprite = sprite_for_block(block.type);
                    draw_sprite_ext(block_sprite, 0, block_x, block_y + hover, 0.75, 0.75, 0, c_white, 1);
                }
            }
        
            // Draw blocks flying toward conveyor (during throwing)
            else {
                var conveyor = instance_nearest(x, y, obj_conveyor_belt);
                if (conveyor != noone) {
                    var target_x = conveyor.x;
                    var target_y = conveyor.conveyor_start_y;
        
                    for (var i = blocks_carried - 1; i > 0; i--) {
                        throw_duration = ((x - conveyor.x) / 128) * 30;
                        var throw_delay = (i * 5); // delay each block throw
                        
                    
                        //show_debug_message("Thro Duration: " + string(throw_duration));
                        var block_progress = clamp((throw_progress - throw_delay) / (throw_duration - throw_delay), 0, 1);
        
                        if (block_progress < 1) {
                            var start_x = x + carried_blocks[i].offset_x;
                            var start_y = y + carried_blocks[i].offset_y;
        
                            var arc_pos = calculate_arc(start_x, start_y, target_x, target_y, block_progress);
                            var block_sprite = sprite_for_block(carried_blocks[i].type);
                            draw_sprite_ext(block_sprite, 0, arc_pos[0], arc_pos[1], 0.75, 0.75, 0, c_white, 1);
                        }
                    }
                }
            }
        
        // Draw selection indicator if selected
        if (selected) {
            draw_circle(x, y, 36, true);
            draw_circle(x, y, 38, true);
                    
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
                    
                    draw_text(text_x, text_y, "Level: " + string(stats.level) + "/" + string(stats.max_level));
                    draw_text(text_x, text_y + line_height, "Experience: " + string(stats.experience) + "/" + string(stats.max_experience));
                    draw_text(text_x, text_y + line_height*2, "Carry Capacity: " + string(stats.carry_capacity));
                    draw_text(text_x, text_y + line_height*3, "Throw Distance: " + string(stats.throw_distance));
                    draw_text(text_x, text_y + line_height*4, "Speed: " + string(stats.move_speed));
                    draw_text(text_x, text_y + line_height*5, "State: " + string(state));
                    
                    // Reset text alignment
                    draw_set_halign(fa_left);
                    draw_set_valign(fa_top);
        }
        
        // Draw state and timers for debugging
        if (selected) {
            draw_text(x - 20, y - 50, state);
            
            // Draw relevant timer based on state
            if (state == "collecting") {
                draw_healthbar(
                    x - 20, y - 40,
                    x + 20, y - 35,
                    (pickup_timer / stats.max_pickup_timer) * 100,
                    c_black, c_yellow, c_green, 0, true, true
                );
            } else if (state == "throwing") {
                draw_healthbar(
                    x - 20, y - 40,
                    x + 20, y - 35,
                    (throw_timer / stats.max_throw_timer) * 100,
                    c_black, c_yellow, c_green, 0, true, true
                );
            }
        }
    }
    
    
    
    seek_target = function(conveyor) {
        
        var seek_distance = 16;
        throw_progress = 0;
        // Find nearest deposit block or block stack
            if instance_exists(obj_deposit_block){
                deposit_blocks = instance_nearest(x, y, obj_deposit_block);
                
                if deposit_blocks < 0 return; 
                
                if (abs(x - deposit_blocks.x)) <= seek_distance
                {
                    target = deposit_blocks;
                    state = "collecting"; 
                }
            }
        else {
            state = "idle";
            return;
        }
            
        
            if (blocks_carried > ceil(0.5 * stats.carry_capacity) && wait_to_return < stats.wait_to_return_max)
            {
                wait_to_return ++;
            }
            else {
                wait_to_return ++;
                if (wait_to_return >= stats.wait_to_return_max)
                {
                    wait_to_return = 0;
                    if (blocks_carried > 0)
                    {
                        state = "delivering";
                    }
                    else {
                        state = "idle";
                    }
                }
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
                    else {
                        return;
                    }
                }
                
                var target_dir = walk_direction;
                // Move toward target
                if (think_timer >= stats.max_think_timer)
                {
                    think_timer = 0;
                    target_dir = point_direction(x, y, target.x, y);
                }
                        
                
                walk_direction = target_dir;
                
                // Update position with collision avoidance (only with other seeking drones)
                x += lengthdir_x(stats.move_speed, walk_direction);
                if (conveyor != noone) y = conveyor.conveyor_start_y; // Stay on conveyor level
                
                // Check if we've reached the target
                if (point_distance(x, y, target.x, target.y) <= seek_distance) {
                    state = "collecting";
                    pickup_timer = stats.max_pickup_timer;
                }
            }
    }
    
    collect_blocks = function(deposit_blocks) {
        // Collection animation/timer
        var block_size = 32;
        var x_stack_offset = 8;
        
        pickup_timer++;
        wait_to_return = 0;
        if (pickup_timer >= stats.max_pickup_timer && blocks_carried < stats.carry_capacity) {
            if (deposit_blocks != noone) {
                // Get block type based on deposit block's current state
                var block_type = deposit_blocks.get_block_type();
                
                if (block_type != -1) {
                    // Store the block in our carried blocks array
                    array_push(carried_blocks, {
                        type: block_type,
                        offset_x: irandom_range(-x_stack_offset, x_stack_offset),
                        offset_y: -block_size - (blocks_carried * block_size) // Stack blocks visually
                    });
                    
                    // Destroy the deposit block
                    with (deposit_blocks) {
                        instance_destroy();
                    }
                    
                    blocks_carried++;
                    
                    // Reset timer and transition state
                    pickup_timer = 0;
                    
                    // If full, go to delivering, otherwise keep seeking
                    if (blocks_carried >= stats.carry_capacity) {
                        state = "delivering";
                        return;
                    } else {
                        state = "idle";
                        return;
                    }
                } else {
                    // No block available, go back to seeking
                    state = "seeking";
                    return;
                }
            } else {
                // No deposit block found, go back to seeking
                state = "seeking";
                return;
            }
        }
    }
    
    deliver_blocks = function(conveyor) {
        wait_to_return = 0;
        if (blocks_carried <= 0)
                {
                    state = "seeking";
                    wait_to_return = 0;
                    return;
                }
                if (conveyor != noone) {
                    // Move towards conveyor belt with collision avoidance
                    target = conveyor;
                    var target_dir = point_direction(x, y, target.x, y);
                    walk_direction = target_dir;
                    
                    // Update position
                    x += lengthdir_x(stats.move_speed, walk_direction);
                    y = conveyor.conveyor_start_y; // Stay on conveyor level
                    
                    // Check if we're within throwing distance of conveyor belt
                    if (point_distance(x, y, target.x, y) <= stats.throw_distance && blocks_carried > 0 && conveyor.loading_blocks_timer <= 0) {
                        // Start throwing animation
                        conveyor.loading_blocks_timer = throw_duration;
                        state = "throwing";
                    }
                } else {
                    // No conveyor belt found, go to idle
                    state = "idle";
                }
    }
    
    throw_blocks = function(conveyor) {
            if (!is_throwing) {
                is_throwing = true;
                throw_progress = 0;
            }
            
            throw_progress++;
            

            if (throw_progress >= throw_duration) {
                // Actually deliver blocks now
                for (var i = 0; i < blocks_carried; i++) {
                    with (conveyor) {
                     add_block_to_conveyor(other.carried_blocks[i].type);
                    }
                }
        
                // Clear blocks
                blocks_carried = 0;
                carried_blocks = array_create(0);
        
                // Reset state
                is_throwing = false;
                throw_progress = 0;
                state = "idle";
            }
        };

    
    idle_behavior = function(conveyor, deposit_blocks) {
        // Move with collision avoidance
        if (x > room_width - 50) {
            walk_direction = 180; // Move left
        } else if (x < room_width * 0.5) {
            walk_direction = 0; // Move right
        }
        
        // Move slower when idle but still avoid collisions
        x += lengthdir_x(stats.move_speed * 0.5, walk_direction);
        if (conveyor != noone) y = conveyor.conveyor_start_y; // Stay on conveyor level
        
        // Check if deposit blocks exist to resume work
        if (deposit_blocks != noone && blocks_carried < stats.carry_capacity) {
            state = "seeking";
        } else if (blocks_carried > 0 && conveyor != noone) {
            state = "delivering";
        }
    }
    
    
    
    find_untargeted_source = function() {
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
    
    // Update stats based on mods
    recalculate_stats = function() {
        var base_speed = 4;
        var base_capacity = 8;
        
        move_speed = base_speed;
        carry_capacity = base_capacity;

        for (var m = 0; m < array_length(mods); m++) {
            move_speed += mods[m].speed_modifier;
            carry_capacity += mods[m].capacity_modifier;
        }
    }

    // Apply a mod
    apply_mod = function(_mod) {
        array_push(mods, _mod);
        recalculate_stats();
    }

    // Remove a mod
    remove_mod = function(_mod) {
        array_delete(mods, array_index_of(mods, _mod), 1);
        recalculate_stats();
    }
    
    // Collision
    collide_with_other_drones = function(game_control)
    {
        var is_collided = false;
        var number_of_drones = game_control.number_of_drones;
        var _drone_array = game_control.drone_array;
        // Collision Check for objects within the game_control_object.
        
        for (var _i = 0; _i < number_of_drones; _i++)
        {
            var _drone_1 = _drone_array[_i];
            
            var _x = _drone_1.x;
            var _y = _drone_1.y;
            
            var d1_col_x_min = _drone_1.coll_x_min;
            var d1_col_x_max = _drone_1.coll_x_max;
            var d1_col_y_min = _drone_1.coll_y_min;
            var d1_col_y_max = _drone_1.coll_y_max;
            
            for (var _x = 0; _x < number_of_drones; _x++)
            {
                var _drone_2 = _drone_array[_x];
                if (_drone_1.id == _drone_2.id) continue;
                    
                var d2_col_x_min = _drone_2.coll_x_min;
                var d2_col_x_max = _drone_2.coll_x_max;
                var d2_col_y_min = _drone_2.coll_y_min;
                var d2_col_y_max = _drone_2.coll_y_max;
                
                if (d2_col_x_min <= d1_col_x_max && d1_col_x_min <= d2_col_x_min)
                {
                    return true;
                    // Collision Happened, put code here.
                }
            }
            return false;
        }
    }
}


function Mod(_name, _speed_mod, _capacity_mod) constructor {
    name = _name;
    speed_modifier = _speed_mod;
    capacity_modifier = _capacity_mod;
}

function calculate_arc(_start_x, _start_y, _end_x, _end_y, _progress) {
    var height = -abs(_start_x - _end_x); // peak height of arc (negative for upward)
    var px = lerp(_start_x, _end_x, _progress);
    var py = lerp(_start_y, _end_y, _progress) + height * sin(pi * _progress);
    return [px, py];
}