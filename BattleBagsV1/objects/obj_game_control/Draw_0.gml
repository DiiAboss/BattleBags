/// @description Draw the grid, fade bottom row, and highlight hovered gem
// ----------------------------------
// 💥 APPLY GRID SHAKE WHEN DAMAGED
// ----------------------------------
var shake_x = irandom_range(-global.grid_shake_amount, global.grid_shake_amount);
var shake_y = irandom_range(-global.grid_shake_amount, global.grid_shake_amount);

for (var i = 0; i < width; i++) {
    for (var j = 0; j < height; j++) {
        var gem = grid[i, j]; // Retrieve the gem object

        // Ensure the cell contains a valid gem object
		if (gem.type != -1) {
            var draw_x = board_x_offset + (i * gem_size) + offset + gem.offset_x  + shake_x;
            var draw_y = (j * gem_size) + global_y_offset + gem.offset_y + offset + shake_y;
			
					
			if (grid[i, 1].type != -1 && !grid[i, 1].falling) { // 🚨 Column in danger
                var block_y = (1 * gem_size) + global_y_offset; // Actual Y position
                var progress = 1 - clamp(block_y / gem_size, 0, 1); // 0 = row 1, 1 = row 0
				
                var shake_intensity = lerp(0, 3, progress); // Shake increases as it gets closer
                draw_x += irandom_range(-shake_intensity, shake_intensity);
                draw_y += irandom_range(-shake_intensity, shake_intensity);
            }

			
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

            if (gem.type == BLOCK.WILD) {
                draw_sprite(spr_wild_gem, 0, draw_x, draw_y);
            }
			
			if (gem.powerup != -1) {
                draw_sprite(gem.powerup.sprite, 0, draw_x, draw_y);
            }
					 // 🧊 If frozen, draw ice overlay
	        if (gem.frozen) {
				var _scale = 1;
			
				if (gem.freeze_timer > 120)
				{
					draw_sprite(spr_ice_cover, 0, draw_x, draw_y);
				}
				else
				{
					var _shake_x = draw_x + irandom_range(-3, 3);
					var _shake_y = draw_y + irandom_range(-3, 3);
					draw_sprite_ext(spr_ice_cover, 0, shake_x, shake_y, _scale, _scale, 0, c_white, 1);
				}
	        }
		
			if (gem.is_enemy_block)
			{
				draw_sprite(spr_enemy_gem_overlay, 0, draw_x, draw_y);
			}
			
			// Loop through all popping gems in global.pop_list

	
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
			
			if (pop_data.bomb_tracker)
			{
				draw_sprite(spr_bomb_overlay, 0, draw_x, draw_y);
			}
			
			// Draw the combo number if a combo is active
		if (combo > 1) { // Only show if at least 2 matches have happened
		    draw_set_font(f_b_font);
		    draw_set_halign(fa_center);
		    draw_set_valign(fa_middle);
    
		    var px = (global.combo_x * gem_size) + board_x_offset + (gem_size / 2);
		    var py = (global.combo_y * gem_size) + global_y_offset + (gem_size / 2);
			
			
			draw_text_color(px+2 + irandom_range(-1, 1), py+2 + irandom_range(-1, 1), string(combo) + "x!", c_black, c_black, c_black, c_black, 1);
			draw_text_color(px + irandom_range(-1, 1), py + irandom_range(-1, 1), string(combo) + "x!", c_yellow, c_yellow, c_white, c_white, 1);
		    //draw_text(px, py, string(combo) + "x!");
			
			draw_set_font(fnt_basic);
			draw_set_halign(fa_left);
		}
	
}

// Optional: Draw combo count
draw_text(10, 40, "TIME: " + string(time_in_seconds));
draw_text(10, 60, "SPEED: " + string(game_speed_default));
draw_text(10, 80, "EXP: " + string(experience_points) + " / " + string(max_experience_points));
draw_text(10, 100, "LEVEL: " + string(level));
draw_text(10, 100, "MULTINEXT: " + string(total_multiplier_next) );

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

draw_spawn_rates(self);


// ----------------------
//  🔴 DRAW PLAYER HEALTH BAR
// ----------------------
var max_health = max_player_health; // Set max health (Adjust as needed)
var bar_width = width * gem_size; // Full grid width
var bar_height = 64; // Bar height
var bar_x = board_x_offset; // X Position
var bar_y = -10; // Slightly above the grid

// Calculate health percentage
var health_percent = clamp(player_health / max_health, 0, 1);
var health_bar_width = bar_width * health_percent;

// Draw background (gray full bar)
draw_set_color(c_black);
draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);

// Draw actual health bar (Red)
draw_set_color(c_red);
draw_rectangle(bar_x, bar_y, bar_x + health_bar_width, bar_y + bar_height, false);

// Draw Text (Health Number)
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(bar_x + (bar_width / 2), bar_y + (bar_height / 2), "HP: " + string(player_health) + "/" + string(max_health));

// Reset Alignment
draw_set_halign(fa_left);

// ----------------------
//  🔥 DRAW DANGER WARNING (Glowing Columns)
// ----------------------

for (var i = 0; i < width; i++) {
    var is_danger = false;
    var flash_alpha = 0;
    var flash_speed = 0;

    // 🚨 Check if a block is in row 1
    if (grid[i, 1].type != -1) && (!grid[i, 1].falling) { 
        is_danger = true;

        // 🔥 Calculate progression from row 1 to row 0
        var block_y = (1 * gem_size) + global_y_offset;  // Actual Y position of block
        var progress = 0.75 * (1 - clamp(block_y / gem_size, 0, 0.75)); // Normalize to range 0 - 1

        // ✅ **Flashing starts slow & soft, increases as it moves up**
        flash_speed = lerp(1, 5, progress);  // Starts at speed 1, max at 20
        flash_alpha = lerp(0.2, 0.5, progress);  // Starts at alpha 0.2, max at 0.5

        // ✅ Use sine wave to control smooth flashing
        var sine_wave = 0.25 + 0.25 * sin(degtorad(current_time * flash_speed));
        flash_alpha *= progress;
    }

    // 🔴 Apply red flashing effect if danger detected
    if (is_danger) {
        var col_x = board_x_offset + (i * gem_size);
        var col_y = 0;
        var col_width = gem_size;
        var col_height = room_height;

        draw_set_alpha(flash_alpha);
        draw_rectangle_color(col_x, col_y, col_x + col_width, col_y + col_height, c_red, c_red, c_red, c_red, false);
        draw_set_alpha(1); // Reset alpha
    }
}


// ----------------------
//  🏆 DRAW TOTAL POINTS (Top Right Corner)
// ----------------------

// Set text properties
draw_set_font(f_b_font);
draw_set_halign(fa_right);
draw_set_color(c_white);

// Define position (top-right of the screen)
var points_x = (room_width * 0.5) + 128;
var points_y = 20;

// Draw background box (optional for visibility)
var box_width = 150;
var box_height = 40;
draw_set_color(c_black);
draw_rectangle(points_x - box_width, points_y - 10, points_x, points_y + box_height, false);

// Draw the total points
draw_set_color(c_white);
draw_text(points_x - 10, points_y + 10, "Score: " + string(total_points));

// Reset alignment
draw_set_halign(fa_left);
draw_set_font(fnt_basic);
