
/// @description Draw recycler with visual feedback

// Draw the base sprite
draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, direction, c_white, 1);

// Draw processing indicator if active
if (processing) {
    var progress = process_time / max_process_time;
    var bar_width = 48;
    var bar_height = 8;
    
    // Background
    draw_set_alpha(0.5);
    draw_rectangle_color(
        x - bar_width/2, y - 48,
        x + bar_width/2, y - 48 + bar_height,
        c_black, c_black, c_black, c_black, false
    );
    
    // Progress bar
    draw_set_alpha(1);
    draw_rectangle_color(
        x - bar_width/2, y - 48,
        x - bar_width/2 + (bar_width * progress), y - 48 + bar_height,
        c_lime, c_lime, c_yellow, c_yellow, false
    );
    
    // Processing animation
    var anim_offset = sin(current_time * 0.01) * 5;
    draw_sprite_ext(
        spr_block_recycler, // Assuming you have an active state sprite
        0,
        x, y + anim_offset,
        1, 1, 0, c_white, 0.7
    );
}

// Draw cooldown indicator
if (cooldown > 0) {
    var cooldown_progress = 1 - (cooldown / max_cooldown);
    var radius = 20;
    
    draw_set_alpha(0.6);
    draw_circle_color(
        x, y - 16,
        radius, c_black, c_black, false
    );
    
    draw_set_alpha(1);
    draw_set_color(c_white);
    //draw_(
        //x, y - 16,
        //radius - 2,
        //270, 270 + (360 * cooldown_progress),
        //2, 24
    //);
}

// Reset alpha
draw_set_alpha(1);
draw_rectangle_color(x, y, tar_x, y + 4, c_red, c_white, c_white, c_red, false);
draw_self();
