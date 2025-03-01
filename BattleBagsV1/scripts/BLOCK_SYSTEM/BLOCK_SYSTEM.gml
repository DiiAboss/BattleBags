function Block(_type = BLOCK.RANDOM) constructor {
    // Core properties
    type = (_type == BLOCK.RANDOM) ? weighted_random_block() : _type;
    powerup = weighted_random_powerup();
    
    // Visual properties
    img_number = 0;
    color = get_block_color(type);
    x_scale = 1;
    y_scale = 1;
    offset_x = 0;
    offset_y = 0;
    draw_y = 0;
    
    // State properties
    falling = false;
    popping = false;
    frozen = false;
    slime_hp = -1;
    is_enemy_block = false;
    is_big = false;
    
    // Timers and counters
    fall_delay = 0;
    max_fall_delay = 5;
    freeze_timer = 0;
    shake_timer = 0;
    dist_without_touching = 0;
    
    // Big block properties
    big_parent = [-1, -1];
    mega_width = -1;
    mega_height = -1;
    group_id = -1;
    
    // Animation properties
    bomb_tracker = false;
    bomb_level = 1;
    dir = choose(0, 90, 180, 270);
    
    // Methods for state management
    static is_empty = function() {
        return type == BLOCK.NONE;
    }
    
    static is_special = function() {
        return type == BLOCK.BLACK || type == BLOCK.WILD || type == BLOCK.PUZZLE_1;
    }
    
    static is_match_eligible = function() {
        // Check if this block can participate in matches
        return !is_empty() && !popping && !frozen && !is_enemy_block && 
            type != BLOCK.BLACK && type != BLOCK.PUZZLE_1;
    }
    
    static can_match_with = function(other_block) {
        if (!other_block || !is_match_eligible() || !other_block.is_match_eligible()) {
            return false;
        }
        
        // Handle big blocks - they match with their own group
        if (is_big || other_block.is_big) {
            return is_big && other_block.is_big && 
                group_id == other_block.group_id;
        }
        
        // Regular matching logic
        return type == other_block.type || 
            type == BLOCK.WILD || 
            other_block.type == BLOCK.WILD;
    }
    
    // State change methods
    static freeze = function(duration = 10) {
        frozen = true;
        freeze_timer = 60 * duration;
        return this; // Enable method chaining
    }
    
    static apply_slime = function(amount = 10) {
        slime_hp = amount;
        max_fall_delay = 20;
        return this;
    }
    
    static start_popping = function(delay = 0) {
        popping = true;
        pop_timer = delay;
        return this;
    }
    
    static start_shaking = function(intensity = 30) {
        shake_timer = intensity;
        return this;
    }
    
    static make_big_block = function(_parent_x, _parent_y, _group_id, _width = 2, _height = 2) {
        is_big = true;
        big_parent = [_parent_x, _parent_y];
        group_id = _group_id;
        
        // Only set these on the parent block
        if (_parent_x == x && _parent_y == y) {
            mega_width = _width;
            mega_height = _height;
        }
        
        return this;
    }
    
    // Update method called each frame
    static update = function() {
        // Handle falling state
        if (falling) {
            fall_delay++;
            if (fall_delay >= max_fall_delay) {
                // Ready to actually fall
                fall_delay = 0;
            }
        }
        
        // Handle frozen state
        if (frozen && freeze_timer > 0) {
            freeze_timer--;
            if (freeze_timer <= 0) {
                frozen = false;
            }
        }
        
        // Handle shaking animation
        if (shake_timer > 0) {
            shake_timer--;
            offset_x = irandom_range(-4, 4);
            offset_y = irandom_range(-4, 4);
        } else {
            offset_x = 0;
            offset_y = 0;
        }
        
        // Handle slime degradation
        if (slime_hp > 0 && falling) {
            // Slime degrades when the block falls
            slime_hp = max(0, slime_hp - 1);
            if (slime_hp == 0) {
                max_fall_delay = 5; // Return to normal falling speed
            }
        }
        
        return this; // Enable method chaining
    }
    
    // Drawing method - centralizes all rendering logic for blocks
    static draw = function(_x, _y, _scale = 1) {
        var draw_x = _x + offset_x;
        var draw_y = _y + offset_y + draw_y;
        
        // Apply scale modifications based on state
        var final_x_scale = x_scale * _scale;
        var final_y_scale = y_scale * _scale;
        
        // Adjust scale for falling blocks
        if (falling) {
            final_x_scale *= 0.9;
            final_y_scale *= 1.1;
        }
        
        // Special scaling for blocks falling a long distance
        if (dist_without_touching > 8) {
            final_x_scale *= 0.75;
            final_y_scale *= 1.25;
        }
        
        // Draw the main block sprite
        draw_sprite_ext(
            sprite_for_block(type), 
            img_number, 
            draw_x, 
            draw_y, 
            final_x_scale, 
            final_y_scale, 
            0, 
            color, 
            1
        );
        
        // Draw special state overlays
        if (powerup != -1) {
            draw_sprite_ext(
                powerup.sprite,
                0,
                draw_x,
                draw_y,
                final_x_scale,
                final_y_scale,
                0,
                c_white,
                1
            );
        }
        
        if (frozen) {
            draw_sprite_ext(
                spr_ice_cover,
                0,
                draw_x,
                draw_y,
                final_x_scale,
                final_y_scale,
                0,
                c_white,
                1
            );
        }
        
        if (slime_hp > 0) {
            draw_sprite_ext(
                spr_goo_cover,
                0,
                draw_x,
                draw_y,
                final_x_scale,
                final_y_scale,
                0,
                c_white,
                1
            );
        }
        
        if (is_enemy_block) {
            draw_sprite_ext(
                spr_enemy_gem_overlay,
                0,
                draw_x,
                draw_y,
                final_x_scale,
                final_y_scale,
                0,
                c_white,
                1
            );
        }
        
        // Draw mega block borders for big blocks
        if (is_big && big_parent[0] == x && big_parent[1] == y) {
            // Only the parent block draws the mega block overlay
            var block_size = 64; // Your gem_size value
            var mega_width_px = mega_width * block_size;
            var mega_height_px = mega_height * block_size;
            
            draw_set_color(c_red);
            draw_rectangle(
                draw_x - (block_size/2),
                draw_y - (block_size/2),
                draw_x - (block_size/2) + mega_width_px,
                draw_y - (block_size/2) + mega_height_px,
                true
            );
            
            // Draw inner rectangle
            var padding = 4;
            draw_rectangle(
                draw_x - (block_size/2) + padding,
                draw_y - (block_size/2) + padding,
                draw_x - (block_size/2) + mega_width_px - padding,
                draw_y - (block_size/2) + mega_height_px - padding,
                true
            );
        }
    }
    
    // Debug method for logging/troubleshooting
    static debug_info = function() {
        return {
            type: type,
            position: [x, y],
            state: {
                falling: falling,
                popping: popping,
                frozen: frozen,
                is_big: is_big
            },
            timers: {
                fall_delay: fall_delay,
                max_fall_delay: max_fall_delay,
                freeze_timer: freeze_timer,
                shake_timer: shake_timer
            }
        };
    }
}
