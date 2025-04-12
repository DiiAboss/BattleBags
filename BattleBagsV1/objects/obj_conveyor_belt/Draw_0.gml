
/// @description Draw Conveyor Belt with enhanced visuals

//// Draw conveyor background
//draw_set_alpha(0.7);
////draw_rectangle_color(
    ////x - conveyor_width/2, conveyor_activation_y,
    ////x + conveyor_width/2, conveyor_start_y,
    ////c_navy, c_navy, c_black, c_black, false
////);
//draw_set_alpha(1.0);

//// Draw lane separators
//if (show_grid_overlay) {
    //var lane_width = conveyor_width / lane_count;
    //for (var i = 0; i <= lane_count; i++) {
        //var lane_x = x - conveyor_width/2 + (i * lane_width);
        //
        //// Highlight unlocked lanes
        //var line_color = (i <= lanes_unlocked) ? c_white : c_dkgray;
        //
        //draw_line_width_color(
            //lane_x, conveyor_activation_y,
            //lane_x, conveyor_start_y,
            //1, line_color, line_color
        //);
    //}
//}

// Draw activation line with animated effect
var time_offset = (current_time / 300) mod 360;
var line_width = 3 + sin(degtorad(time_offset)) * 1.5; // Pulsing effect

draw_line_width_color(
    x - conveyor_width/2, conveyor_activation_y,
    x + conveyor_width/2, conveyor_activation_y,
    line_width, c_red, c_red
);

// Draw activation zone highlight
draw_set_alpha(pulsing_alpha);
draw_rectangle_color(
    x - conveyor_width/2, conveyor_activation_y - 15,
    x + conveyor_width/2, conveyor_activation_y + 5,
    c_red, c_red, c_red, c_red, false
);
draw_set_alpha(1.0);


draw_grouped_blocks(self, conveyor_blocks, conveyor_width, x);

for (var i = 0; i < conveyor_sprite_height; i++)
{
    draw_sprite(spr_conveyor_tube, 0, x, conveyor_start_y - (i * 64));
}

// Draw stats if debug mode is on
if (keyboard_check(vk_tab)) {
    draw_set_color(c_white);
    draw_text(x + conveyor_width/2 + 10, conveyor_activation_y, 
            "Blocks in queue: " + string(ds_list_size(conveyor_blocks)));
    draw_text(x + conveyor_width/2 + 10, conveyor_activation_y + 20, 
            "Blocks processed: " + string(blocks_processed));
    draw_text(x + conveyor_width/2 + 10, conveyor_activation_y + 40, 
            "Special blocks: " + string(special_blocks_processed));
}

draw_sprite(spr_clay_sorter, image_index, x, conveyor_start_y);
