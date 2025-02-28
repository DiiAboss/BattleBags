/// @description Draw Conveyor Belt and Attacks

// Draw conveyor background
draw_set_alpha(0.5);
draw_rectangle_color(
    x - conveyor_width/2, conveyor_activation_y,
    x + conveyor_width/2, conveyor_start_y,
    c_navy, c_navy, c_navy, c_navy, false
);
draw_set_alpha(1.0);

// Draw lane separators
if (show_grid_overlay) {
    var lane_width = conveyor_width / lane_count;
    for (var i = 0; i <= lane_count; i++) {
        var lane_x = x - conveyor_width/2 + (i * lane_width);
        draw_line_color(
            lane_x, conveyor_activation_y,
            lane_x, conveyor_start_y,
            c_dkgray, c_dkgray
        );
    }
}

// Draw activation line
draw_line_width_color(
    x - conveyor_width/2, conveyor_activation_y,
    x + conveyor_width/2, conveyor_activation_y,
    3, c_red, c_red
);

// Draw all attacks on the conveyor
for (var i = 0; i < ds_list_size(conveyor_attacks); i++) {
    var attack_data = conveyor_attacks[| i];
    
    // Calculate lane position
    var lane_width = conveyor_width / lane_count;
    var lane_x = x - conveyor_width/2 + (attack_data.lane * lane_width) + (lane_width/2);
    
    // Draw attack preview
    draw_attack_on_conveyor(lane_x, attack_data.y_pos, attack_data);
}

// Draw attack queue stats
draw_set_color(c_white);
draw_text(x + conveyor_width/2 + 10, conveyor_activation_y, 
        "Queue Size: " + string(ds_list_size(global.enemy_attack_queue)));
draw_text(x + conveyor_width/2 + 10, conveyor_activation_y + 20, 
        "Conveyor Attacks: " + string(ds_list_size(conveyor_attacks)));
