/// @description Draw Conveyor Belt and Attacks

//// Draw conveyor background
//draw_set_alpha(0.5);
//draw_rectangle_color(
    //conveyor_x_start - conveyor_width/2, conveyor_activation_y,
    //conveyor_x_start + conveyor_width/2, conveyor_start_y,
    //c_navy, c_navy, c_navy, c_navy, false
//);
//draw_set_alpha(1.0);
//
//// Draw lane separators
//if (show_grid_overlay) {
    //var lane_width = conveyor_width / lane_count;
    //for (var i = 0; i <= lane_count; i++) {
        //var lane_x = conveyor_x_start - conveyor_width/2 + (i * lane_width);
        //draw_line_color(
            //lane_x, conveyor_activation_y,
            //lane_x, conveyor_start_y,
            //c_dkgray, c_dkgray
        //);
    //}
//}
//
//// Draw activation line
//draw_line_width_color(
    //conveyor_x_start - conveyor_width/2, conveyor_activation_y,
    //conveyor_x_start + conveyor_width/2, conveyor_activation_y,
    //3, c_red, c_red
//);
//
//// Draw all attacks on the conveyor
//for (var i = 0; i < ds_list_size(conveyor_attacks); i++) {
    //var attack_data = conveyor_attacks[| i];
    //
    //// Calculate lane position
    //var lane_width = conveyor_width / lane_count;
    //var lane_x = conveyor_x_start - conveyor_width/2 + (attack_data.lane * lane_width) + (lane_width/2);
    //
    //// Draw attack preview
    //draw_attack_on_conveyor(lane_x, attack_data.y_pos, attack_data);
//}
//
//// Draw attack queue stats
//draw_set_color(c_white);
//draw_text(conveyor_x_start + conveyor_width/2 + 10, conveyor_activation_y, 
        //"Queue Size: " + string(ds_list_size(global.enemy_attack_queue)));
//draw_text(conveyor_x_start + conveyor_width/2 + 10, conveyor_activation_y + 20, 
        //"Conveyor Attacks: " + string(ds_list_size(conveyor_attacks)));





/// @description Draw Conveyor Belt with enhanced visuals
draw_set_alpha(0.7);
draw_rectangle_color(
    x - conveyor_width/2, conveyor_activation_y,
    x + conveyor_width/2, conveyor_start_y,
    c_navy, c_navy, c_black, c_black, false
);
draw_set_alpha(1.0);

// Draw conveyor belt lines
var belt_segments = 20;
var segment_height = (conveyor_start_y - conveyor_activation_y) / belt_segments;

for (var i = 0; i <= belt_segments; i++) {
    var y_pos = conveyor_activation_y + (i * segment_height);
    var line_alpha = 0.5 + (0.5 * (i mod 2)); // Alternate opacity for visual interest
    
    draw_set_alpha(line_alpha);
    draw_line_width_color(
        x - conveyor_width/2, y_pos,
        x + conveyor_width/2, y_pos,
        1, c_gray, c_gray
    );
}
draw_set_alpha(1.0);

// Draw lane separators
if (show_grid_overlay) {
    var lane_width = conveyor_width / lane_count;
    for (var i = 0; i <= lane_count; i++) {
        var lane_x = x - conveyor_width/2 + (i * lane_width);
        draw_line_width_color(
            lane_x, conveyor_activation_y,
            lane_x, conveyor_start_y,
            1, c_dkgray, c_dkgray
        );
    }
}

// Draw activation line with animated effect
var time_offset = (current_time / 300) mod 360;
var line_width = 3 + sin(degtorad(time_offset)) * 1.5; // Pulsing effect

draw_line_width_color(
    x - conveyor_width/2, conveyor_activation_y,
    x + conveyor_width/2, conveyor_activation_y,
    line_width, c_red, c_red
);

// Draw activation zone highlight
draw_set_alpha(0.2 + 0.1 * sin(degtorad(time_offset * 2))); // Pulsing opacity
draw_rectangle_color(
    x - conveyor_width/2, conveyor_activation_y - 15,
    x + conveyor_width/2, conveyor_activation_y + 5,
    c_red, c_red, c_red, c_red, false
);
draw_set_alpha(1.0);
