/// @description Draw deposit block with visual state indicators

// Draw base sprite
//draw_sprite(sprite_index, 0, x, y);

if (y > obj_conveyor_belt.conveyor_start_y)
{
    y = obj_conveyor_belt.conveyor_start_y;
}

// Draw based on current state
switch(state) {
    case "ready":
        // Draw the current block hovering above the deposit
        var block_sprite = sprite_for_block(current_block_type);
        var block_y = y - 24 + float_offset;
        
        // Draw glow effect
        draw_set_alpha(glow_alpha);
        draw_circle_color(
            x, block_y, 
            20, c_white, c_yellow, 
            false
        );
        draw_set_alpha(1);
        
        // Draw the block
        draw_sprite_ext(
            block_sprite, 0, 
            x, block_y, 
            0.5, 0.5, 0, c_white, 1
        );
        break;
        
    case "cooldown":
        // Draw regeneration progress bar
        var progress = (regen_timer / max_regen_time);
        var bar_width = 32;
        var bar_height = 6;
        
        draw_healthbar(
            x - bar_width/2, y - 32,
            x + bar_width/2, y - 32 + bar_height,
            progress * 100,
            c_gray, c_blue, c_lime,
            0, true, true
        );
        break;
        
    case "depleted":
        // Draw depletion indicator
        draw_set_color(c_red);
        draw_set_alpha(0.7);
        draw_sprite_ext(
            sprite_index, 0,
            x, y,
            1, 1, 0, c_gray, 0.5
        );
        
        // Draw "X" to indicate depletion
        var cross_size = 16;
        draw_line_width(
            x - cross_size, y - 16 - cross_size,
            x + cross_size, y - 16 + cross_size,
            3
        );
        draw_line_width(
            x + cross_size, y - 16 - cross_size,
            x - cross_size, y - 16 + cross_size,
            3
        );
        
        // Draw recovery progress
        var recovery_progress = (depletion_timer / max_depletion_time);
        var bar_width = 32;
        var bar_height = 6;
        
        draw_healthbar(
            x - bar_width/2, y - 42,
            x + bar_width/2, y - 42 + bar_height,
            recovery_progress * 100,
            c_maroon, c_red, c_yellow,
            0, true, true
        );
        
        draw_set_alpha(1);
        break;
}

// Draw debug info
if (keyboard_check(vk_tab)) {
    draw_set_color(c_white);
    draw_text(x - 40, y + 20, state);
    draw_text(x - 40, y + 35, "Type: " + string(current_block_type));
}