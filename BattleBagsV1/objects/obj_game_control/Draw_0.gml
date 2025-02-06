/// @description Draw the grid, fade bottom row, and highlight hovered gem
// ----------------------------------
// 💥 APPLY GRID SHAKE WHEN DAMAGED
// ----------------------------------
var shake_x = irandom_range(-global.grid_shake_amount, global.grid_shake_amount);
var shake_y = irandom_range(-global.grid_shake_amount, global.grid_shake_amount);


for (var i = 0; i < width; i++) {
    var max_shake = 2; // Max shake intensity when blocks are above row 1
    var shake_intensity = 0; // Default no shake

    // 🔹 **Check if column has any blocks above row 1**
    var above_blocks = false;
    for (var j = 0; j >= -3; j--) { // Check rows 0, -1, -2, -3
        if (i >= 0 && i < width && j >= 0 && grid[i, j].type != BLOCK.NONE && !grid[i, j].falling ) {
            above_blocks = true;
            break; // Stop checking if we find any block
        }
    }
	
	

    // 🔥 **If blocks are above row 1, apply max shake**
    if (above_blocks) {
        shake_intensity = max_shake;
    } 
    // 🔥 **Otherwise, scale shake based on progress to row 0**
    else if (grid[i, 1].type != BLOCK.NONE && !grid[i, 1].falling) {
        var block_y = (1 * gem_size) + global_y_offset;
        var progress = 1 - clamp(block_y / gem_size, 0, 1); // 0 = row 1, 1 = row 0
        shake_intensity = lerp(0, max_shake, progress);
    }

    // 🔹 Now loop through grid to draw blocks
    for (var j = 0; j < height; j++) {
        var gem = grid[i, j]; // Retrieve the gem object

        if (gem.type != BLOCK.NONE) {
            var draw_x = board_x_offset + (i * gem_size) + offset + gem.offset_x;
            var draw_y = (j * gem_size) + global_y_offset + gem.offset_y + offset;

            // 🔥 Apply shaking effect
            if (shake_intensity > 0) {
                draw_x += irandom_range(-shake_intensity, shake_intensity);
                draw_y += irandom_range(-shake_intensity, shake_intensity);
            }
			
			var draw_x_with_global_shake = draw_x + shake_x;
			var draw_y_with_global_shake = draw_y + shake_x;
            // **Draw the gem sprite**
			
			if (gem.is_big) {
		    // Only draw if this is the top-left (actual) parent
		    if (gem.big_parent[0] == i && gem.big_parent[1] == j) {
		        draw_sprite_ext(sprite_for_gem(gem.type), 0, draw_x_with_global_shake + 32, draw_y_with_global_shake + 32, 2, 2, 0, c_white, 1);
		    }
		} else {
			if (j >= height -1)
			{
			        var draw_x = board_x_offset + (i * gem_size) + offset + gem.offset_x;
			        var draw_y = ((height - 1) * gem_size) + global_y_offset + gem.offset_y + offset;

			        // 🔥 Apply Darken Alpha Effect
			        draw_set_alpha(darken_alpha);

			        // ✅ Draw Normally but with Transparency
			        draw_sprite(sprite_for_gem(gem.type), 0, draw_x, draw_y);

			        // ✅ Reset Alpha After Drawing
			        draw_set_alpha(1);
			}
			else
			{
				draw_sprite(sprite_for_gem(gem.type), gem.img_number, draw_x_with_global_shake, draw_y_with_global_shake);
			}
		}
            

            // 🔥 **Draw special overlays**
            if (gem.powerup != -1) {
                draw_sprite(gem.powerup.sprite, 0, draw_x_with_global_shake, draw_y_with_global_shake);
            }
            if (gem.frozen) {
                draw_sprite(spr_ice_cover, 0, draw_x_with_global_shake, draw_y_with_global_shake);
            }
            if (gem.is_enemy_block) {
                draw_sprite(spr_enemy_gem_overlay, 0, draw_x_with_global_shake, draw_y_with_global_shake);
            }
			
			if (gem.is_big) {
				draw_sprite(spr_enemy_gem_overlay, 0, draw_x_with_global_shake, draw_y_with_global_shake);
    
		    if (gem.big_parent[0] == i && gem.big_parent[1] == j) {
		        draw_text(draw_x, draw_y, "PARENT");
				draw_text(draw_x+16, draw_y+16, string(gem.big_parent[1]) + "/" + string(height));
		        // 🔥 **Draw a box around the 2x2 block**
		        draw_rectangle(draw_x - 32, draw_y - 32, draw_x + gem_size * 2 - 32, draw_y + gem_size * 2 - 32, true);
		    }
			else
			{

				draw_text(draw_x, draw_y, "CHILD"); // 🔥 Draw "CHILD" for the other parts
    
			}
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
        pop_data.img_number,
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
			
			

		draw_text(draw_x, draw_y, string(grid[pop_data.x, pop_data.y].shake_timer))
		draw_text(draw_x + 12, draw_y, string(pop_data.scale))
	
}

for (var idx = 0; idx < ds_list_size(global.pop_list); idx++) {
    var pop_data = ds_list_find_value(global.pop_list, idx);
	
		if (pop_data.bomb_tracker)
		{
			    // Base coords
		    var draw_x = board_x_offset + (pop_data.x * gem_size) + offset;
		    var draw_y = (pop_data.y * gem_size) + offset + global_y_offset;
			
			var img_number = sprite_get_number(spr_bomb_overlay_wick);
			var progress = img_number - (img_number * (grid[pop_data.x, pop_data.y].shake_timer / max_shake_timer));
			
			draw_sprite_ext(spr_bomb_level_1_overlay, -1, draw_x + irandom_range(1, -1), draw_y + irandom_range(1, -1), 1.1, 1.1, 0, c_white, 1);
		}
		
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

// Optional: Draw combo count
draw_text(10, 40, "TIME: " + string(draw_time));
draw_text(10, 60, "SPEED: " + string(game_speed_default));
draw_text(10, 80, "BLOCKS: " + string(total_blocks_destroyed));
draw_text(10, 100, "LEVEL: " + string(level));
draw_text(10, 120, "llt: " + string(lose_life_timer));
draw_text(10, 140, "mCOMBO: " + string(highest_max_combo));


var y_start = 128;
var y_end   = room_height - 128; 
var draw_exp_y = (y_end - y_start) * (experience_points / max_experience_points);

draw_rectangle_color(board_x_offset * 0.5, 128, board_x_offset * 0.9, room_height - 128, c_white, c_white, c_white, c_white, true);
draw_rectangle_color(board_x_offset * 0.5, y_end - draw_exp_y, board_x_offset * 0.9, room_height - 128, c_fuchsia, c_purple, c_purple, c_purple, false);

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


draw_player_hearts(self, player_health, max_player_health, board_x_offset, room_height - 34, width, spr_hearts, gem_size);
// ----------------------
//   DRAW DANGER WARNING (Glowing Columns)
// ----------------------

for (var i = 0; i < width; i++) {
    var is_danger = false;
    var flash_alpha = 0;
    var flash_speed = 0;
	
	for (var j = 0; j <= 1; j++)
	{
	    // 🚨 Check if a block is in row 1
	    if (grid[i, j].type != -1) && (!grid[i, j].falling) { 
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



// 🛑 Always Draw the Preview Box (Even if No Attack is Queued)
var preview_x = board_x_offset + (width * gem_size) + 16;
var preview_y = 64;
var preview_size = 256; // Preview box size
var grid_size = 32;     // Size of each grid cell
var grid_spacing = 4;   // Spacing between blocks


// 🛑 Always Draw the Preview Box Outlines for Upcoming Attacks
var max_attacks_shown = 5; // 🔥 Show up to 5 upcoming attacks
var queue_size = min(ds_list_size(global.enemy_attack_queue), max_attacks_shown);

for (var i = 0; i < queue_size; i++) {
    var attack_offset_y = preview_y + (i * (preview_size + 8)); // 🔥 Properly stack attacks with spacing
    draw_rectangle(preview_x, attack_offset_y, preview_x + preview_size, attack_offset_y + preview_size, true);
}

//  Only draw attack preview if an attack is queued
var queue_size = ds_list_size(global.enemy_attack_queue);
if (queue_size > 0) {
    //  Loop through the next `max_attacks_shown` attacks
    for (var attack_index = 0; attack_index < min(queue_size, max_attacks_shown); attack_index++) {
        var next_attack = ds_list_find_value(global.enemy_attack_queue, attack_index);
        var attack_offset_y = preview_y + (attack_index * (preview_size + 8)); // Space out previews

        //  Draw Attack Timer Progress Overlay for first attack
        if (attack_index == 0) {
            var attack_progress = obj_enemy_parent.attack_timer / obj_enemy_parent.max_attack_timer;
            var bar_height = preview_size * attack_progress;
            draw_set_alpha(0.5);
            draw_rectangle(preview_x, attack_offset_y, preview_x + preview_size, attack_offset_y + bar_height, false);
            draw_set_alpha(1);
        }

        // 🔳 Draw Attack Grid or Display "FREEZE"
        if (next_attack == "FREEZE") {
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(preview_x + preview_size / 2, attack_offset_y + preview_size / 2, "FREEZE");
        } else {
            // 🔳 Draw the Grid & Attack Blocks
            if (ds_map_exists(global.shape_templates, next_attack)) {
                var attack_shape = ds_map_find_value(global.shape_templates, next_attack);
                var shape_width = array_length(attack_shape[0]);
                var shape_height = array_length(attack_shape);

                // 🔥 Centering Calculation
                var total_width = (shape_width * grid_size) + ((shape_width - 1) * grid_spacing);
                var total_height = (shape_height * grid_size) + ((shape_height - 1) * grid_spacing);
                var offset_x = preview_x + (preview_size - total_width) / 2;
                var offset_y = attack_offset_y + (preview_size - total_height) / 2;

                for (var j = 0; j < shape_height; j++) {
                    for (var i = 0; i < shape_width; i++) {
                        var grid_x = offset_x + (i * (grid_size + grid_spacing));
                        var grid_y = offset_y + (j * (grid_size + grid_spacing));

                        // 🟥 Draw the Attack Blocks
                        if (attack_shape[j][i] != BLOCK.NONE) {
                            draw_rectangle(grid_x + 2, grid_y + 2, grid_x + grid_size - 2, grid_y + grid_size - 2, false);
                        }
                    }
                }
            }
        }
    }
}

if (global.paused) || after_menu_counter != after_menu_counter_max && !instance_exists(obj_upgrade_menu) {
	
	//draw_set_color(c_white);
	//draw_set_alpha(0.3*(1 - (after_menu_counter / after_menu_counter_max)));
    //draw_rectangle(0, 0, room_width, room_height, false);
	
	draw_set_color(c_black);
    draw_set_alpha(0.9 * (1 - (after_menu_counter / (after_menu_counter_max + 10))));
    draw_rectangle(0, 0, room_width, room_height, false);
	draw_set_color(c_white);
    
	
	
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(1);
    
    if (after_menu_counter < after_menu_counter_max) {
        // ✅ Calculate remaining countdown time
        var countdown_value = ceil((after_menu_counter_max - after_menu_counter) / room_speed);
        
        draw_set_font(f_b_font); // ✅ Use the specified font
        draw_text_transformed_color((room_width / 2) - (after_menu_counter * 2), room_height / 2, string(countdown_value), 5, 5, 0, c_yellow, c_green, c_blue, c_red, 1);
    } else {
        draw_text(room_width / 2, room_height / 2, "PAUSED\nPress P to Resume");
    }
	 draw_set_font(fnt_basic); // ✅ Use the specified font
    draw_set_halign(fa_left);
}


if (console_active) {
    draw_set_alpha(console_alpha);
    draw_set_color(c_white);
    draw_rectangle(console_x, console_y, console_x + console_width, console_y + console_height, false);
    draw_set_alpha(1);

    // Draw Console Text
    draw_set_color(c_black);
    //draw_set_font(console_font);
    draw_text(console_x + 10, console_y + 10, "> " + console_input);

    // Draw Command History
    for (var i = 0; i < min(array_length(console_history), max_history); i++) {
        draw_text(console_x + 10, console_y + 30 + (i * 20), console_history[i]);
    }
}