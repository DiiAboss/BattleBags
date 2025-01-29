/// @description Draw the grid, fade bottom row, and highlight hovered gem

for (var i = 0; i < width; i++) {
    for (var j = 0; j < height; j++) {
        var gem = grid[i, j]; // Retrieve the gem object

        // Ensure the cell contains a valid gem object
        if (gem.type != -1) {
            var draw_x = board_x_offset + (i * gem_size) + offset + gem.offset_x;
            var draw_y = (j * gem_size) + global_y_offset + gem.offset_y + offset;

            // Fade bottom row
            if (j == height - 1) {
                draw_sprite_ext(
                    sprite_for_gem(gem.type), 
                    0, draw_x, draw_y, 
                    1, 1, 0, c_white, darken_alpha
                );
            } else {
                draw_sprite(sprite_for_gem(gem.type), 0, draw_x, draw_y);
            }

            if (gem.type == WILD_BLOCK) {
                draw_sprite(spr_wild_gem, 0, draw_x, draw_y);
            }
			
			if (gem.powerup != -1) {
                draw_sprite(gem.powerup.sprite, 0, draw_x, draw_y);
            }
        }
    }
}

// ----------------------------------------------------------------------
// 2) HIGHLIGHT HOVERED GEM
//    Convert mouse coords to grid coords, subtracting offset for X
//    and offset + global_y_offset for Y.
// ----------------------------------------------------------------------
var hover_i = floor((mouse_x - board_x_offset) / gem_size);
var hover_j = floor((mouse_y - global_y_offset) / gem_size);

if (hover_i >= 0 && hover_i < width && hover_j >= 0 && hover_j < height) {
    var hover_gem = grid[hover_i, hover_j]; // Get the hovered gem

    if (hover_gem.type != -1) {
        var rect_x1 = board_x_offset + (hover_i * gem_size);
        var rect_y1 = (hover_j * gem_size) + global_y_offset;
        var rect_x2 = rect_x1 + gem_size;
        var rect_y2 = rect_y1 + gem_size;

        draw_set_alpha(0.3);
        draw_set_color(c_yellow);
        draw_rectangle(rect_x1, rect_y1, rect_x2, rect_y2, false);

        draw_set_color(c_white);
        draw_set_alpha(1.0);

        // OPTIONAL: Show gem info in the corner
        draw_text(10, 10,
            "Hovering: (" + string(hover_i) + ", " + string(hover_j) +
            ") | Type: " + string(hover_gem.type) + 
            " | Powerup: " + string(hover_gem.powerup)
        );
    }
}

// ----------------------------------------------------------------------
// 3) DRAW POPPING GEMS (from global.pop_list)
// ----------------------------------------------------------------------
for (var idx = 0; idx < ds_list_size(global.pop_list); idx++) {
    var pop_data = ds_list_find_value(global.pop_list, idx);

    // Base coords
    var draw_x = board_x_offset + (pop_data.x * gem_size) + offset;
    var draw_y = (pop_data.y * gem_size) + offset + global_y_offset;

    // Because you want the gem to expand around its true center,
    // apply an extra center calculation using half the gem size.
    var center_offset = 0; 
    var scaled_offset = center_offset * pop_data.scale;

    var final_x = draw_x + center_offset - scaled_offset;
    var final_y = draw_y + center_offset - scaled_offset;

    draw_sprite_ext(
        sprite_for_gem(pop_data.gem_type),
        0,
        final_x + pop_data.offset_x,
        final_y + pop_data.offset_y,
        pop_data.scale * 1.2, 
        pop_data.scale * 1.2,
        0,
        c_white,
        1.0
    );
	
		if (pop_data.powerup != -1) {
        draw_sprite_ext(pop_data.powerup.sprite,
		0,
		final_x,
		final_y,
        pop_data.scale, 
        pop_data.scale,
        0,
        c_white,
        1.0
    );
            }
	
	
}

// Optional: Draw combo count
draw_text(10, 40, "Combo: " + string(combo));

//var gem_size = 64; // Size of each cell
var thickness = 5; // Thickness of the outline

// Calculate grid dimensions
var grid_width = width * gem_size;
var grid_height = room_height;

// Set outline color
draw_set_color(c_white);

// Draw thick outline around the grid
draw_rectangle(board_x_offset - thickness, - thickness, 
               board_x_offset + grid_width + thickness, thickness, false); // Top
draw_rectangle(board_x_offset - thickness, - thickness, 
               board_x_offset + 1, grid_height + thickness, false); // Left
draw_rectangle(board_x_offset + grid_width, - thickness, 
               board_x_offset + grid_width + thickness, grid_height + thickness, false); // Right
draw_rectangle(board_x_offset - thickness, grid_height, 
               board_x_offset + grid_width + thickness, grid_height + thickness, false); // Bottom

//// Draw a thick border around the grid
//draw_set_color(c_white);
//var line_width = 5;
//draw_rectangle_color(board_x_offset, 0, 
//                       board_x_offset + width * 64, room_height, c_white, c_white, c_white, c_white, true);
