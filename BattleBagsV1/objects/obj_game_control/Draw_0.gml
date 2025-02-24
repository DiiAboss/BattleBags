/// @description Draw the grid, fade bottom row, and highlight hovered gem
input = obj_game_manager.input;

if (keyboard_check_pressed(vk_tab))
{
    if (effect < 3)
    {
        effect++;
    }
    else {
        effect = 0;
    }
}


//// Horizontal pass

if (game_over_state) || (victory_state && victory_countdown != victory_max_countdown) { 
    
    if (game_over_state)
    {
        // ✅ Draw Left Panel
        draw_set_alpha(0.85);
        draw_set_color(c_black);
        draw_rectangle(game_over_ui_x, game_over_ui_y, game_over_ui_x + game_over_ui_width, game_over_ui_y + game_over_ui_height, false);
        draw_set_alpha(1);
    
        // ✅ Draw "You Lose" Title
        var you_lose_x = game_over_ui_x + game_over_ui_width / 2;
        var you_lose_y = game_over_ui_y + 600;
        var you_lose_str = "YOU LOSE";
        
        draw_text_heading_font(you_lose_x, you_lose_y, you_lose_str);
    
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

            
            // ✅ Highlight button on hover
            if (game_over_option_selected == 0) draw_set_color(c_white);
            else draw_set_color(c_grey); 
                
            var rest_x = restart_x + button_width / 2;
            var rest_y = restart_y + button_height / 2;
            var restart_str = "RESTART";
            
            draw_text_text_font(rest_x, rest_y, restart_str);
                
            if (game_over_option_selected == 1) draw_set_color(c_white);
            else draw_set_color(c_grey);
                
            var mmenu_x = menu_x + button_width / 2;
            var mmenu_y = menu_y + button_height / 2;
            var mmenu_str = "MAIN MENU";
            
            //draw_rectangle(menu_x, menu_y, menu_x + button_width, menu_y + button_height, false);
            draw_text_text_font(mmenu_x, mmenu_y, mmenu_str);
        }
    }
    
    draw_set_color(c_white);
    if (victory_state)
    {
        // ✅ Draw Left Panel
        draw_set_alpha(victory_alpha);
        draw_set_color(c_black);
        draw_rectangle(game_over_ui_x, game_over_ui_y, game_over_ui_x + game_over_ui_width, game_over_ui_y + game_over_ui_height, false);
        draw_set_color(c_white);
        
        var game_over_text_x = game_over_ui_x + game_over_ui_width / 2;
        var game_over_text_y = game_over_ui_y + 600;
        var victory_string = "VICTORY";
        
        // ✅ Draw "You Lose" Title
        draw_text_heading_font(game_over_text_x, game_over_text_y, victory_string);
        
 
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
    
    if (number_of_rows_spawned >= victory_number_of_rows)
    {
        if !any_blocks_above(self, board_height - (number_of_rows_spawned - victory_number_of_rows))
        {
            victory_state = true;
        } 
    }
    
    
        // Thickness of the outline
    var thickness = 5; 
    
    // Calculate grid dimensions
    var grid_width = width * gem_size;
    var grid_height = camera_get_view_height(view_get_camera(view_current));
    var view_diff = room_height - grid_height;

    draw_set_alpha(0.4);
    draw_rectangle_color(board_x_offset, view_diff - thickness, 
                            board_x_offset + grid_width + thickness, view_diff +  grid_height - thickness, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);
    
    surface_set_target(surBase);
        draw_clear(c_black);
        
    
    
    
        for (var i = 0; i < width; i++)
        {
            // 🔹 Now loop through grid to draw blocks
            for (var j = top_playable_row; j <= bottom_playable_row; j++) {
                var gem = grid[i, j]; // Retrieve the gem object
                if (gem.type != BLOCK.NONE) {
                    var draw_x = board_x_offset + (i * gem_size) + offset + gem.offset_x;
                    var draw_y = (j * gem_size) + global_y_offset + gem.offset_y + offset + gem.draw_y;
    
                    draw_sprite_ext(sprite_for_block(gem.type), gem.img_number, draw_x, draw_y, 1, 1, 0, gem.color, 1);
                }
            }
        }
        
    
    //----------------------------------------------------------------
    // DRAW GLOWING BLOCKS
    //----------------------------------------------------------------
        surface_reset_target();
        
        // Make it glow horizontally
        surface_set_target(surPass);
        draw_clear_alpha(c_black, 0);
        
        shader_set(shd_blur_horizontal);
        shader_set_uniform_f(shader_get_uniform(shd_blur_horizontal, "u_glowProperties"), uOuterIntensity, uInnerIntensity, uInnerLengthMultiplier);
        shader_set_uniform_f(shader_get_uniform(shd_blur_horizontal, "u_time"), current_time);
        
        gpu_set_blendenable(false);
        draw_surface(surBase, 0, 0);
        gpu_set_blendenable(true);
        
        shader_reset();
        surface_reset_target();
        
        //// Vertical pass + final adjustments, add on top
        gpu_set_blendmode(bm_add);
        
        shader_set(shd_blur_vertical);
        shader_set_uniform_f(shader_get_uniform(shd_blur_vertical, "u_glowProperties"), uOuterIntensity, uInnerIntensity, uInnerLengthMultiplier);
        shader_set_uniform_f(shader_get_uniform(shd_blur_vertical, "u_time"), current_time);
        draw_surface(surPass, 0, 0);
        shader_reset();
        
        gpu_set_blendmode(bm_normal); 
    
    draw_set_alpha(0.75);
    draw_rectangle_color(board_x_offset, view_diff - thickness, 
                            board_x_offset + grid_width + thickness, view_diff +  grid_height - thickness, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);
    
    
        draw_set_color(c_lime);
    geogrid.geogrid_draw(self);
    draw_set_color(c_white);

    
    //----------------------------------------------------------------
    // DRAW COLUMN SHAKE
    //----------------------------------------------------------------
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

	//-------------------------------------------------------
    //  SHAKE INTENSITY
    //-------------------------------------------------------
    // 🔥 **If blocks are above row 1, apply max shake**
    if (danger_row <= top_playable_row) {
        shake_intensity = max_shake;
    }
	
    // **Otherwise, scale shake based on progress to row 0**
    else if (grid[i, top_playable_row].type != BLOCK.NONE && !grid[i, top_playable_row].falling) {
        var block_y      = (1 * gem_size) + global_y_offset;
        var progress     = 1 - clamp(block_y / gem_size, 0, 1); // 0 = row 1, 1 = row 0
        shake_intensity  = lerp(0, max_shake, progress);
    }

    // 🔹 Now loop through grid to draw blocks
    for (var j = top_playable_row; j <= bottom_playable_row; j++) {
        var gem = grid[i, j]; // Retrieve the gem object
        
        var distance_before_meteor = 8;
        var before_meteor_x_scale  = 0.9;
        var before_meteor_y_scale  = 1.1;
        
        var after_meteor_x_scale   = 0.75;
        var after_meteor_y_scale   = 1.25;
        
        var meteor_fall_rate_increase = 0.25;
        
        
        if (gem.dist_without_touching < distance_before_meteor)
        {
            gem.x_scale = gem.falling ? before_meteor_x_scale : 1;
            gem.y_scale = gem.falling ? before_meteor_y_scale : 1; 
        }
        else {
            gem.x_scale    = after_meteor_x_scale;
            gem.y_scale    = after_meteor_y_scale;
            gem.fall_delay += meteor_fall_rate_increase;
            
            var draw_x = board_x_offset + (i * gem_size) + offset + gem.offset_x;
            var draw_y = (j * gem_size) + global_y_offset + gem.offset_y + offset + gem.draw_y;
            effect_create_depth(depth + 1, ef_smokeup, draw_x, draw_y, 1, c_red);
        }

        
        if (gem.falling)
        {
            var percent =  clamp(gem.fall_delay / gem.max_fall_delay, 0, 1);
            gem.draw_y  = 64 * percent;
        }
        else {
            gem.draw_y  = 0;
        }
        
        if (gem.type != BLOCK.NONE) {
            var draw_x = board_x_offset + (i * gem_size) + offset + gem.offset_x;
            var draw_y = (j * gem_size) + global_y_offset + gem.offset_y + offset + gem.draw_y;

            //  Apply shaking effect
            if (shake_intensity > 0) && (i <= top_playable_row){
                draw_x += irandom_range(-shake_intensity, shake_intensity);
                draw_y += irandom_range(-shake_intensity, shake_intensity);
            }
			
			var draw_x_with_global_shake = draw_x + shake_x;
			var draw_y_with_global_shake = draw_y + shake_y;
			
			if (gem.is_big) {
				if (gem.type == BLOCK.MEGA)
				{ 
                    var parent_x = gem.big_parent[0];
			        var parent_y = gem.big_parent[1];

			        // ✅ Only process once per **Mega Block Parent**
			        if (i == parent_x && j == parent_y) {
			            var _width = self.grid[parent_x, parent_y].mega_width;
			            var _height = self.grid[parent_x, parent_y].mega_height;
                        
                        var draw_x_min = draw_x - (gem_size * 0.5);
                        var draw_y_min = draw_y - (gem_size * 0.5);
                        var draw_x_max = draw_x_min + (_width * gem_size);
                        var draw_y_max = draw_y_min + (_height * gem_size);
                        
                        //  Draw the Mega Block Piece with Correct Rotation
                        draw_set_color(c_black);
                        draw_rectangle(
                            draw_x_min, 
                            draw_y_min, 
                            draw_x_max, 
                            draw_y_max, false);
                        
                        draw_rectangle_color(
                            draw_x_min, 
                            draw_y_min, 
                            draw_x_max, 
                            draw_y_max, c_red, c_red, c_red, c_red, true);
                        
                        var inside_rect_offset = 4;
                        draw_rectangle_color(
                            draw_x_min + inside_rect_offset, 
                            draw_y_min + inside_rect_offset, 
                            draw_x_max - inside_rect_offset, 
                            draw_y_max - inside_rect_offset, c_red, c_red, c_red, c_red, true);
                        
                        draw_roundrect_color(
                            draw_x_min, 
                            draw_y_min, 
                            draw_x_max, 
                            draw_y_max, c_red, c_red, true);
                        
                        draw_set_color(c_white);
                        
                        var spr_draw_x = draw_x_min + (draw_x_max - draw_x_min) * 0.5;
                        var spr_draw_y = draw_y_min + (draw_y_max - draw_y_min) * 0.5;
                        draw_sprite(spr_mega_enemy_overlay, 0, spr_draw_x, spr_draw_y);
                        
			            // ✅ Iterate over the whole Mega Block
			            for (var bx = 0; bx < _width; bx++) {
			                for (var by = 0; by < _height; by++) {
			                    var block_x = parent_x + bx;
			                    var block_y = parent_y + by;
								
								if (grid[block_x, block_y].type == BLOCK.NONE) continue;
			                    //  Determine correct sprite variation
			                    var _sprite_index = 0;
			                    var rotation = 0;
			                }
			            }
			        }
				}
				else
				{
				    // Only draw if this is the top-left (actual) parent
				    if (gem.big_parent[0] == i && gem.big_parent[1] == j) {
				        draw_sprite_ext(sprite_for_block(gem.type), gem.img_number, draw_x_with_global_shake + 32, draw_y_with_global_shake + 32, 2, 2, 0, c_white, 1);
					}
					 
			    }
			} 
			else {
                
				if (j >= bottom_playable_row)
				{
				        var _draw_x = board_x_offset + (i * gem_size) + offset + gem.offset_x;
				        var _draw_y = ((bottom_playable_row) * gem_size) + global_y_offset + gem.offset_y + offset + gem.draw_y;
					       
						if (j == bottom_playable_row)
						{		
					        // ✅ Draw Normally but with Transparency
					        draw_sprite_ext(sprite_for_block(gem.type), gem.img_number, _draw_x, _draw_y, gem.x_scale, gem.y_scale, 0 ,c_white, darken_alpha);
						}
				}
				else
				{
                    draw_sprite_ext(sprite_for_block(gem.type), gem.img_number, draw_x_with_global_shake, draw_y_with_global_shake, gem.x_scale, gem.y_scale, 0, c_white, 1);
				}
			}

                //--------------------------------------------------------------------------------------
                //  DRAW SPECIAL OVERLAYS
                //--------------------------------------------------------------------------------------
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
				     var _draw_y = ((bottom_playable_row) * gem_size) + global_y_offset + gem.offset_y + offset + gem.draw_y;
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
    		
            if (hover_gem.type != BLOCK.NONE && !(hover_gem.is_big)) {
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
   // DRAW POPPING GEMS (from global.pop_list)
   // ----------------------------------------------------------------------
   for (var idx = 0; idx < ds_list_size(global.pop_list); idx++) {
       var pop_data = ds_list_find_value(global.pop_list, idx);
   
       // Base coords
       var draw_x = board_x_offset + (pop_data.x * gem_size) + offset;
       var draw_y = (pop_data.y * gem_size) + offset + global_y_offset + gem.draw_y;
   	
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

    //------------------------------------------------------------
    // DFAW BOMB OVERLAY ON POP
    //------------------------------------------------------------
    for (var idx = 0; idx < ds_list_size(global.pop_list); idx++) {
        var pop_data = ds_list_find_value(global.pop_list, idx);
    	
    		if (pop_data.bomb_tracker)
    		{
    			    // Base coords
    		    var draw_x = board_x_offset + (pop_data.x * gem_size) + offset;
    		    var draw_y = (pop_data.y * gem_size) + offset + global_y_offset + gem.draw_y;
    			
    			var img_number = sprite_get_number(spr_bomb_overlay_wick);
    			var progress = img_number - (img_number * (grid[pop_data.x, pop_data.y].shake_timer / max_shake_timer));
    			
    			draw_sprite_ext(spr_bomb_overlay_wick, 0, draw_x, draw_y, 1.2, 1.2, 0, c_white, 1);
    			
    		}	
    }

    //---------------------------------------------------------
    // DRAW COMBO COUNTER
    //---------------------------------------------------------
    if (combo > 1) { // Only show if combo is at 2 or higher
    	var px = (combo_x * gem_size) + board_x_offset + (gem_size / 2);
    	var py = (combo_y * gem_size) + global_y_offset + (gem_size / 2);
        var background_text_offset = 2;
        
        var px_bg = px + background_text_offset + irandom_range(-1, 1);
        var py_bg = py + background_text_offset + irandom_range(-1, 1);
        
        var px_fg = px + irandom_range(-1, 1);
        var py_fg = py + irandom_range(-1, 1);
        
        var combo_string = string(combo) + "x!";
        var c_bg = c_black;
        var c_fg1 = c_yellow;
        var c_fg2 = c_white;
        
        draw_text_heading_font(px_bg, py_bg, combo_string, 1, c_bg, c_bg, c_bg, c_bg);
        draw_text_heading_font(px_fg, py_fg, combo_string, 1, c_fg1, c_fg1, c_fg2, c_fg2);

    }
    
    //---------------------------------------------------------
    // DRAW STATS
    //---------------------------------------------------------
    draw_text_stats(self, 10, draw_y_start, true);

    
    //---------------------------------------------------------
    // DRAW EXPERIENCE BAR
    //---------------------------------------------------------
    var y_start = draw_y_start + 128;
    var y_end   = draw_y_start + camera_get_view_height(view_get_camera(view_current)) - 128; 
    var draw_exp_y = (y_end - y_start) * (experience_points / max_experience_points);
    
    draw_rectangle_color(board_x_offset * 0.5, y_start, board_x_offset * 0.9, y_end,              c_white,   c_white,  c_white,  c_white,  true);
    draw_rectangle_color(board_x_offset * 0.5, y_end,   board_x_offset * 0.9, y_end - draw_exp_y, c_fuchsia, c_purple, c_purple, c_purple, false);
    
    
    //---------------------------------------------------------
    // DRAW BOARDER AROUND THE GRID
    //---------------------------------------------------------
    // Thickness of the outline
    var thickness = 5; 
    
    // Calculate grid dimensions
    var grid_width = width * gem_size;
    var grid_height = camera_get_view_height(view_get_camera(view_current));
    var view_diff = room_height - grid_height;
    
        // Set outline color
    draw_set_color(c_white);
    
    // Draw thick outline around the grid
    draw_rectangle(board_x_offset - thickness, view_diff - thickness, 
                    board_x_offset + grid_width + thickness, view_diff + thickness, false); // Top
    draw_rectangle(board_x_offset - thickness,view_diff - thickness, 
                    board_x_offset + 1, view_diff + grid_height + thickness, false); // Left
    draw_rectangle(board_x_offset + grid_width, view_diff - thickness, 
                    board_x_offset + grid_width + thickness, view_diff + grid_height - thickness, false); // Right
    draw_rectangle(board_x_offset - thickness, view_diff + grid_height, 
                    board_x_offset + grid_width + thickness, view_diff +  grid_height - thickness, false); // Bottom
    

    //---------------------------------------------------------
    // DRAW SPAWN RATES
    //---------------------------------------------------------
    //draw_spawn_rates(self);
    
        
    //--------------------------------------
    // DRAW HEARTS
    //--------------------------------------
    var heart_sprite = spr_health_new;
    var hearts_y_pos = draw_y_start + grid_height - 34;
    draw_player_hearts(self, 
                        player_health, 
                        max_player_health, 
                        board_x_offset, 
                        hearts_y_pos, 
                        width, 
                        heart_sprite, 
                        gem_size);
    
    
    
    
    
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
    

if (global.paused) || (after_menu_counter != after_menu_counter_max) && !instance_exists(obj_upgrade_menu) {


	draw_set_color(c_black);
    draw_set_alpha(0.9 * (1 - (after_menu_counter / (after_menu_counter_max + 10))));
    draw_rectangle(0, draw_y_start, room_width, room_height, false);
	draw_set_color(c_white);
    
    if (after_menu_counter < after_menu_counter_max) {
        // ✅ Calculate remaining countdown time
        var countdown_value = ceil((after_menu_counter_max - after_menu_counter) / _FPS);
        
        var after_menu_counter_x = (room_width / 2) - (after_menu_counter * 2);
        var after_menu_counter_y = room_height / 2;
        var shadow_x = after_menu_counter_x + 4;
        var shadow_y = after_menu_counter_y + 4;
        var size = 5;
        
        draw_text_heading_font( shadow_x, 
                                shadow_y, 
                                string(countdown_value), 
                                size);
        
        draw_text_heading_font(after_menu_counter_x, 
                                after_menu_counter_y, 
                                string(countdown_value), 
                                size,
                                c_yellow,
                                c_green,
                                c_blue,
                                c_red);
        
 } else {

        var pause_x = room_width / 2;
        var pause_y = room_height / 2;
        var pause_string = "PAUSED\nPress P to Resume";
        
        draw_text_text_font(pause_x, pause_y, pause_string);
    } 
}
    
    if (number_of_rows_spawned >= victory_number_of_rows)
    {
        
        var draw_victory_row_y = board_height - (number_of_rows_spawned - victory_number_of_rows);
        var scale = sin(degtorad(current_time * 1)) * 1; // Oscillates slightly (-5° to +5°)
        
        for (var _v = 0; _v < board_width; _v++)
        {
            var draw_x = board_x_offset + (_v * gem_size) + offset;
            var draw_y = (draw_victory_row_y * gem_size) + global_y_offset + offset;
            draw_sprite_ext(spr_checker, 0, draw_x, draw_y, 1, 1 - (0.05 * scale), -scale, c_black, 1);
            draw_sprite_ext(spr_checker, 0, draw_x, draw_y, 1, 1 + (0.025 * scale), scale, c_white, 1);
        }
        
    }
    
}

