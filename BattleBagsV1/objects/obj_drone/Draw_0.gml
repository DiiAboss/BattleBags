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
    
    
    