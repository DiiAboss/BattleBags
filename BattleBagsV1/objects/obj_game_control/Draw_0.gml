/// @description Draw the grid, fade bottom row, and highlight hovered gem
input = obj_game_manager.input;

if (game_over_state) { 
    // ✅ Draw Left Panel
    draw_set_alpha(0.85);
    draw_set_color(c_black);
    draw_rectangle(game_over_ui_x, game_over_ui_y, game_over_ui_x + game_over_ui_width, game_over_ui_y + game_over_ui_height, false);
    draw_set_alpha(1);

    // ✅ Draw "You Lose" Title
    draw_set_font(fnt_heading1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(game_over_ui_x + game_over_ui_width / 2, game_over_ui_y + 600, "YOU LOSE");

    // ✅ Draw Popping Blocks
    for (var i = 0; i < ds_list_size(game_over_popping); i++) {
        var pop_data = ds_list_find_value(game_over_popping, i);
        var _x = pop_data.x;
        var _y = pop_data.y;

        draw_sprite(spr_gameOver, 0, (_x * gem_size) + board_x_offset, (_y * gem_size));
		draw_sprite(spr_enemy_gem_overlay, 0, (_x * gem_size) + board_x_offset, (_y * gem_size));
    }

    // ✅ Draw Options After Blocks Have Popped
    if (game_over_show_options) {
        var restart_x = game_over_ui_x + 50;
        var restart_y = game_over_ui_y + 350;
        var menu_x = game_over_ui_x + 50;
        var menu_y = game_over_ui_y + 420;
        var button_width = 300;
        var button_height = 50;
		draw_set_font(fnt_textFont);
        // ✅ Highlight button on hover
        if (game_over_option_selected == 0) draw_set_color(c_gray);
        else draw_set_color(c_white);
        //draw_rectangle(restart_x, restart_y, restart_x + button_width, restart_y + button_height, false);
        draw_text(restart_x + button_width / 2, restart_y + button_height / 2, "Restart");

        if (game_over_option_selected == 1) draw_set_color(c_gray);
        else draw_set_color(c_white);
        //draw_rectangle(menu_x, menu_y, menu_x + button_width, menu_y + button_height, false);
        draw_text(menu_x + button_width / 2, menu_y + button_height / 2, "Main Menu");
    }
}

else
{
// ----------------------------------
//  APPLY GRID SHAKE WHEN DAMAGED
// ----------------------------------
var shake_x = irandom_range(-global.grid_shake_amount, global.grid_shake_amount);
var shake_y = irandom_range(-global.grid_shake_amount, global.grid_shake_amount);

var draw_y_start = camera_get_view_y(view_get_camera(view_current));
    
    
    

for (var i = 0; i < width; i++) {
    var max_shake = 2; // Max shake intensity when blocks are above row 1
    var shake_intensity = 0; // Default no shake

    // **Check if column has any blocks above row 1**
    var above_blocks = global.topmost_row <= top_playable_row;

	draw_text(10, draw_y_start + 0, "TOPROW: " + string(global.topmost_row));
	draw_text(10, draw_y_start + 10, "above: " + string(above_blocks));
	
	var danger_row = 99;
	
	if (above_blocks)
	{
		for (var ii = 0; ii <= top_playable_row; ii++) { 
	        if (grid[i, ii].type != BLOCK.NONE) {
	            danger_row = ii;
	            break;
	        }
	    }
	}

	
    // 🔥 **If blocks are above row 1, apply max shake**
    if (danger_row <= top_playable_row) {
        shake_intensity = max_shake;
    }
	
    // **Otherwise, scale shake based on progress to row 0**
    else if (grid[i, top_playable_row].type != BLOCK.NONE && !grid[i, top_playable_row].falling) {
        var block_y = (1 * gem_size) + global_y_offset;
        var progress = 1 - clamp(block_y / gem_size, 0, 1); // 0 = row 1, 1 = row 0
        shake_intensity = lerp(0, max_shake, progress);
    }

    // 🔹 Now loop through grid to draw blocks
    for (var j = top_playable_row; j <= bottom_playable_row; j++) {
        var gem = grid[i, j]; // Retrieve the gem object

		gem.x_scale = gem.falling ? 0.95 : 1;
		gem.y_scale = gem.falling ? 1.05 : 1;
		
        if (gem.type != BLOCK.NONE) {
            var draw_x = board_x_offset + (i * gem_size) + offset + gem.offset_x;
            var draw_y = (j * gem_size) + global_y_offset + gem.offset_y + offset;

            //  Apply shaking effect
            if (shake_intensity > 0) && (i <= top_playable_row){
                draw_x += irandom_range(-shake_intensity, shake_intensity);
                draw_y += irandom_range(-shake_intensity, shake_intensity);
            }
			
			var draw_x_with_global_shake = draw_x + shake_x;
			var draw_y_with_global_shake = draw_y + shake_x;
            // **Draw the gem sprite**
			
			if (gem.is_big) {
				if (gem.type == BLOCK.MEGA)
				{
					 var parent_x = gem.big_parent[0];
			        var parent_y = gem.big_parent[1];

			        // ✅ Only process once per **Mega Block Parent**
			        if (i == parent_x && j == parent_y) {
			            var _width = self.grid[parent_x, parent_y].mega_width;
			            var _height = self.grid[parent_x, parent_y].mega_height;

			            // ✅ Iterate over the whole Mega Block
			            for (var bx = 0; bx < _width; bx++) {
			                for (var by = 0; by < _height; by++) {
			                    var block_x = parent_x + bx;
			                    var block_y = parent_y + by;
								
								if (grid[block_x, block_y].type == BLOCK.NONE) continue; //
								
			                    var draw_x = board_x_offset + (block_x * gem_size);
			                    var draw_y = global_y_offset + (block_y * gem_size);

			                    //  Determine correct sprite variation
			                    var _sprite_index = 0;
			                    var rotation = 0;
								
								 //  Draw the Mega Block Piece with Correct Rotation
			                    draw_sprite_ext(sprite_for_block(BLOCK.MEGA), 0, draw_x + gem_size / 2, draw_y + gem_size / 2, 1, 1, rotation, c_white, 1);
			                }
			            }
			        }
				}
				else
				{
				    // Only draw if this is the top-left (actual) parent
				    if (gem.big_parent[0] == i && gem.big_parent[1] == j) {
				        draw_sprite_ext(sprite_for_block(gem.type), 0, draw_x_with_global_shake + 32, draw_y_with_global_shake + 32, 2, 2, 0, c_white, 1);
					}
					 
			    }
			} 
			else {
				if (j >= bottom_playable_row)
				{
				        var _draw_x = board_x_offset + (i * gem_size) + offset + gem.offset_x;
				        var _draw_y = ((bottom_playable_row) * gem_size) + global_y_offset + gem.offset_y + offset;
					
						if (j == bottom_playable_row)
						{		
							//draw_set_alpha(darken_alpha);
					        // ✅ Draw Normally but with Transparency
					        draw_sprite_ext(sprite_for_block(gem.type), 0, _draw_x, _draw_y, gem.x_scale, gem.y_scale, 0 ,c_white, darken_alpha);
						}

				}
				else
				{
					draw_sprite_ext(sprite_for_block(gem.type), gem.img_number, draw_x_with_global_shake, draw_y_with_global_shake, gem.x_scale, gem.y_scale, 0, c_white, 1);
				}
			}
            
	            // 🔥 **Draw special overlays**
	            if (gem.powerup != -1) {
	                draw_sprite(gem.powerup.sprite, 0, draw_x_with_global_shake, draw_y_with_global_shake);
	            }
	            if (gem.frozen) {
	                draw_sprite(spr_ice_cover, 0, draw_x_with_global_shake, draw_y_with_global_shake);
	            }
				if (gem.slime_hp > 0) {
	                draw_sprite(spr_goo_cover, 0, draw_x_with_global_shake, draw_y_with_global_shake);
	            }
	            if (gem.is_enemy_block) {
	                draw_sprite(spr_enemy_gem_overlay, 0, draw_x_with_global_shake, draw_y_with_global_shake);
	            }
			
				if (gem.is_big) {
					var _draw_x = board_x_offset + (i * gem_size) + offset + gem.offset_x;
				     var _draw_y = ((bottom_playable_row) * gem_size) + global_y_offset + gem.offset_y + offset;
					draw_text(_draw_x, _draw_y, string(gem.mega_width));
				}

        }
    }
}





if (hovered_block[0] >= 0 && hovered_block[1] >= 0) {
    var hover_i = hovered_block[0];
    var hover_j = hovered_block[1];

    if (hover_i >= 0 && hover_i < width && hover_j >= 0 && hover_j < height) {
        var hover_gem = grid[hover_i, hover_j];
		var rect_x1 = board_x_offset + (hover_i * gem_size);
        var rect_y1 = (hover_j * gem_size) + global_y_offset;
        var rect_x2 = rect_x1 + gem_size;
        var rect_y2 = rect_y1 + gem_size;
		var scale = 1.1;
		
		if (swap_in_progress)
		{
			scale = 1;
		}
        
        if (is_targeting_enemy)
        {
            draw_text(hovered_block[0], hovered_block[1], string(combo_points));
        }
		
		if (control_mode == "legacy") {
				if (hover_i + 1 < width)
				{
					var hover_gem2 = grid[hover_i + 1, hover_j];
					draw_sprite_ext(spr_gem_hovered_border, -1, rect_x2 + 32, rect_y2 - 32, scale, scale, 0, c_white, 1);
					
					if (hover_gem2.type != BLOCK.NONE)
					{
						draw_sprite_ext(sprite_for_block(hover_gem2.type), hover_gem2.img_number, rect_x2 + 32, rect_y2 - 32, scale, scale, 0, c_white, 1);
						draw_sprite_ext(hover_gem2.powerup.sprite, 0, rect_x2 + 32, rect_y2 - 32, scale, scale, 0, c_white, 1);
					}
				}
				
				draw_sprite_ext(spr_gem_hovered_border, -1, rect_x2 - 32, rect_y2 - 32, scale, scale, 0, c_white, 1);
		}
		
        if (hover_gem.type != BLOCK.NONE) {
            var rect_x1 = board_x_offset + (hover_i * gem_size);
            var rect_y1 = (hover_j * gem_size) + global_y_offset;
            var rect_x2 = rect_x1 + gem_size;
            var rect_y2 = rect_y1 + gem_size;

            draw_set_alpha(0.3);
            draw_set_color(c_yellow);
            draw_rectangle(rect_x1, rect_y1, rect_x2, rect_y2, false);
			// ✅ Draw Normally but with Transparency
			draw_sprite_ext(sprite_for_block(hover_gem.type), hover_gem.img_number, rect_x2 - 32, rect_y2 - 32, scale, scale, 0, c_white, 1);
			draw_sprite_ext(hover_gem.powerup.sprite, 0, rect_x2 - 32, rect_y2 - 32, scale, scale, 0, c_white, 1);
			
			if (control_mode == "modern") {
			    draw_sprite_ext(spr_gem_hovered_border, -1, rect_x2 - 32, rect_y2 - 32, scale, scale, 0, c_white, 1);
			}
            draw_set_color(c_white);
            draw_set_alpha(1.0);

            // ✅ OPTIONAL: Show gem info in the corner
            draw_text(10, draw_y_start + 10,
                "Hovering: (" + string(hover_i) + ", " + string(hover_j) +
                ") | Type: " + string(hover_gem.type) + 
                " | Powerup: " + string(hover_gem.powerup)
            );
        }
		else
		{
			// ✅ OPTIONAL: Show gem info in the corner
            draw_text(10, draw_y_start + 10,
                "Hovering: (" + string(hover_i) + ", " + string(hover_j) +
                ") | Type: " + string(hover_gem.type) + 
                " | Powerup: " + string(hover_gem.powerup)
            );
		}
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
        sprite_for_block(pop_data.gem_type),
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
			
			draw_sprite_ext(spr_bomb_overlay_wick, 0, draw_x, draw_y, 1.2, 1.2, 0, c_white, 1);
			
		}	
}

// Draw the combo number if a combo is active
if (combo > 1) { // Only show if at least 2 matches have happened
	draw_set_font(fnt_heading1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
    
	var px = (combo_x * gem_size) + board_x_offset + (gem_size / 2);
	var py = (combo_y * gem_size) + global_y_offset + (gem_size / 2);
			
			
	draw_text_color(px+2 + irandom_range(-1, 1), py+2 + irandom_range(-1, 1), string(combo) + "x!", c_black, c_black, c_black, c_black, 1);
	draw_text_color(px + irandom_range(-1, 1), py + irandom_range(-1, 1), string(combo) + "x!", c_yellow, c_yellow, c_white, c_white, 1);
	//draw_text(px, py, string(combo) + "x!");
			
	draw_set_font(fnt_basic);
	draw_set_halign(fa_left);
}
    
    


// Optional: Draw combo count
draw_text(10, draw_y_start + 40, "TIME: " + string(draw_time));
draw_text(10, draw_y_start + 60, "SPEED: " + string(game_speed_default));
draw_text(10, draw_y_start + 80, "alpha: " + string(darken_alpha));
draw_text(10, draw_y_start + 100, "LEVEL: " + string(level));
draw_text(10, draw_y_start + 120, "Combo: " + string(combo));
draw_text(10, draw_y_start + 140, "cTimer: " + string(combo_timer));


var y_start = draw_y_start + 128;
var y_end   = draw_y_start + camera_get_view_height(view_get_camera(view_current)) - 128; 
var draw_exp_y = (y_end - y_start) * (experience_points / max_experience_points);

draw_rectangle_color(board_x_offset * 0.5, y_start,            board_x_offset * 0.9, y_end, c_white, c_white, c_white, c_white, true);
draw_rectangle_color(board_x_offset * 0.5, y_end, board_x_offset * 0.9, y_end - draw_exp_y, c_fuchsia, c_purple, c_purple, c_purple, false);


    
var thickness = 5; // Thickness of the outline

// Calculate grid dimensions

var grid_width = width * gem_size;
var grid_height = camera_get_view_height(view_get_camera(view_current));
var view_diff = room_height - grid_height;
// Set outline color
draw_set_color(c_white);

// Draw thick outline around the grid
draw_rectangle(board_x_offset - thickness, view_diff - thickness, 
               board_x_offset + grid_width + thickness,view_diff + thickness, false); // Top
draw_rectangle(board_x_offset - thickness,view_diff - thickness, 
               board_x_offset + 1, view_diff + grid_height + thickness, false); // Left
draw_rectangle(board_x_offset + grid_width, view_diff - thickness, 
               board_x_offset + grid_width + thickness, view_diff + grid_height - thickness, false); // Right
draw_rectangle(board_x_offset - thickness, view_diff + grid_height, 
               board_x_offset + grid_width + thickness, view_diff +  grid_height - thickness, false); // Bottom

draw_spawn_rates(self);


draw_player_hearts(self, player_health, max_player_health, board_x_offset, draw_y_start + grid_height - 34, width, spr_hearts_old, gem_size);

    if (is_targeting_enemy)
    {
        draw_set_alpha(0.95);
        draw_rectangle_color(0, 0, 800, room_height, c_black, c_black, c_black, c_black, false);
        draw_set_alpha(1);
        
        draw_rectangle_color(850, 300, room_width - 82, room_height - 44, c_white, c_white, c_white, c_white, true);
    }

    if (enemy_target != -1)
        {
            with (enemy_target)
            { 
                var scale = 1.1; // Slightly enlarged
                var rotation = sin(degtorad(current_time * 2)) * 5; // Oscillates slightly (-5° to +5°)
                draw_sprite_ext(my_sprite, 0, x, y, scale, scale, rotation, c_white, 0.9);
                
                draw_sprite_ext(spr_crosshair, 0, x, y, scale, scale, rotation, c_red, 1);
            }
        }
    else {
        if input.InputType == INPUT.KEYBOARD
        {
            draw_sprite(spr_crosshair, 0, mouse_x, mouse_y);
        }
    }
    

if (global.paused) || after_menu_counter != after_menu_counter_max && !instance_exists(obj_upgrade_menu) {


	draw_set_color(c_black);
    draw_set_alpha(0.9 * (1 - (after_menu_counter / (after_menu_counter_max + 10))));
    draw_rectangle(0, draw_y_start, room_width, room_height, false);
	draw_set_color(c_white);
    
	
	
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(1);
    
    if (after_menu_counter < after_menu_counter_max) {
        // ✅ Calculate remaining countdown time
        var countdown_value = ceil((after_menu_counter_max - after_menu_counter) / FPS);
        
        draw_set_font(fnt_heading1); // ✅ Use the specified font
		draw_text_transformed_color((room_width / 2) - (after_menu_counter * 2) + 4,(room_height / 2) + 4, string(countdown_value), 5, 5, 0, c_white, c_white, c_white, c_white, 1);
        draw_text_transformed_color((room_width / 2) - (after_menu_counter * 2),room_height / 2, string(countdown_value), 5, 5, 0, c_yellow, c_green, c_blue, c_red, 1);
    } else {
        draw_set_font(fnt_textFont)
        draw_text(room_width / 2, room_height / 2, "PAUSED\nPress P to Resume");
    }
	 draw_set_font(fnt_basic); // ✅ Use the specified font
    draw_set_halign(fa_left);
}
    
}