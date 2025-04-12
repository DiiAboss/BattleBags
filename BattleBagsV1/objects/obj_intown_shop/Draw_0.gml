// Draw Event in obj_intown_shop
/// @description Draw shop interface
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
// draw_set_font(font_title);

// Draw background panel
draw_set_color(c_black);
draw_set_alpha(0.8);
draw_rectangle(menu_x - 20, menu_y - 60, menu_x + menu_width + 250, room_height - 50, false);
draw_set_alpha(1);

// Draw title
draw_set_color(c_title);
var title_text = string_upper(current_menu);
if (current_submenu != "") 
{
    if (current_submenu == "drone_list") 
    {
        title_text += " > UNLOCKED DRONES";
    }
    else if (string_pos("drone_", current_submenu) == 1)
    {
        var drone_index = real(string_delete(current_submenu, 1, 6));
        if (drone_index < array_length(unlocked_drones))
        {
            title_text += " > " + string_upper(unlocked_drones[drone_index].name);
        }
    }
    else
    {
        // Find the label for this submenu
        var submenu_array = get_current_submenu();
        for (var i = 0; i < array_length(submenu_array); i++)
        {
            if (submenu_array[i].action == current_submenu)
            {
                title_text += " > " + submenu_array[i].label;
                break;
            }
        }
    }
}
draw_text(menu_x, menu_y - 30, title_text);

// Draw currency
draw_set_halign(fa_right);
draw_text(menu_x + menu_width + 150, menu_y - 30, "$" + string(player_currency));
draw_set_halign(fa_left);

// Draw "BACK" button
draw_set_color(c_button);
draw_rectangle(menu_x - 10, room_height - 40, menu_x + 60, room_height - 10, false);
draw_set_color(c_button_text);
draw_text(menu_x, room_height - 25, "BACK");

// Draw menu items
if (current_menu == "main") 
{
    // Draw main menu
    for (var i = 0; i < array_length(main_menu); i++) 
    {
        var btn = main_menu[i];
        var by = menu_y + (i - scroll_offset) * (button_height + button_spacing);
        
        // Skip if off screen
        if (by + button_height < menu_y) continue;
        if (by > room_height - 100) break;
        
        // Check if mouse is hovering
        var hover = point_in_rectangle(mouse_x, mouse_y, menu_x, by, menu_x + menu_width, by + button_height);
        
        if (hover) {
            hover_button_index = i;
            hover_scale = lerp(hover_scale, hover_target_scale, hover_speed);
        } else if (hover_button_index == i) {
            hover_scale = lerp(hover_scale, 1.0, hover_speed);
            if (abs(hover_scale - 1.0) < 0.01) hover_button_index = -1;
        }
        
        // Apply hover effect
        if (hover || hover_button_index == i) {
            var pulse_effect = 0.5 + 0.5 * sin(hover_alpha_pulse);
            draw_set_color(merge_color(c_button, c_button_hover, pulse_effect));
            
            // Scale and center the button
            var scale = hover_scale;
            var w = menu_width * scale;
            var h = button_height * scale;
            var cx = menu_x + menu_width / 2;
            var cy = by + button_height / 2;
            
            draw_rectangle(
                cx - w/2, 
                cy - h/2, 
                cx + w/2, 
                cy + h/2, 
                false
            );
        } else {
            draw_set_color(c_button);
            draw_rectangle(menu_x, by, menu_x + menu_width, by + button_height, false);
        }
        
        draw_set_color(c_button_text);
        // draw_set_font(font_button);
        draw_text(menu_x + 20, by + button_height / 2, btn.label);
    }
} 
else if (current_submenu == "") 
{
    // Draw submenu
    var submenu_array = get_current_submenu();
    for (var i = 0; i < array_length(submenu_array); i++) 
    {
        var btn = submenu_array[i];
        var by = menu_y + (i - scroll_offset) * (button_height + button_spacing);
        
        // Skip if off screen
        if (by + button_height < menu_y) continue;
        if (by > room_height - 100) break;
        
        // Check if mouse is hovering
        var hover = point_in_rectangle(mouse_x, mouse_y, menu_x, by, menu_x + menu_width, by + button_height);
        
        if (hover) {
            hover_button_index = i;
            hover_scale = lerp(hover_scale, hover_target_scale, hover_speed);
        } else if (hover_button_index == i) {
            hover_scale = lerp(hover_scale, 1.0, hover_speed);
            if (abs(hover_scale - 1.0) < 0.01) hover_button_index = -1;
        }
        
        // Apply hover effect
        if (hover || hover_button_index == i) {
            var pulse_effect = 0.5 + 0.5 * sin(hover_alpha_pulse);
            draw_set_color(merge_color(c_button, c_button_hover, pulse_effect));
            
            // Scale and center the button
            var scale = hover_scale;
            var w = menu_width * scale;
            var h = button_height * scale;
            var cx = menu_x + menu_width / 2;
            var cy = by + button_height / 2;
            
            draw_rectangle(
                cx - w/2, 
                cy - h/2, 
                cx + w/2, 
                cy + h/2, 
                false
            );
        } else {
            draw_set_color(c_button);
            draw_rectangle(menu_x, by, menu_x + menu_width, by + button_height, false);
        }
        
        draw_set_color(c_button_text);
        // draw_set_font(font_button);
        draw_text(menu_x + 20, by + button_height / 2, btn.label);
        
        // Show upgrade level if applicable
        var upgrade_data = upgrades[$ btn.action];
        if (upgrade_data != undefined && upgrade_data.level > 0) {
            if (upgrade_data.max_level == 1) {
                // For boolean upgrades
                draw_set_halign(fa_right);
                draw_set_color(c_green);
                draw_text(menu_x + menu_width - 20, by + button_height / 2, "UNLOCKED");
                draw_set_halign(fa_left);
            } else {
                // For leveled upgrades
                draw_set_halign(fa_right);
                draw_set_color(c_yellow);
                draw_text(menu_x + menu_width - 20, by + button_height / 2, 
                         "LVL " + string(upgrade_data.level) + "/" + string(upgrade_data.max_level));
                draw_set_halign(fa_left);
            }
        }
        
        // Draw description if hovered
        if (hover)
        {
            draw_set_color(c_description);
            // draw_set_font(font_description);
            draw_text(menu_x, room_height - 80, btn.desc);
        }
    }
}
else if (current_submenu == "drone_list")
{
    // Draw drone list
    for (var i = 0; i < array_length(unlocked_drones); i++) 
    {
        var drone = unlocked_drones[i];
        var by = menu_y + (i - scroll_offset) * (button_height + button_spacing);
        
        // Skip if off screen
        if (by + button_height < menu_y) continue;
        if (by > room_height - 100) break;
        
        // Check if mouse is hovering
        var hover = point_in_rectangle(mouse_x, mouse_y, menu_x, by, menu_x + menu_width, by + button_height);
        
        if (hover) {
            hover_button_index = i;
            hover_scale = lerp(hover_scale, hover_target_scale, hover_speed);
        } else if (hover_button_index == i) {
            hover_scale = lerp(hover_scale, 1.0, hover_speed);
            if (abs(hover_scale - 1.0) < 0.01) hover_button_index = -1;
        }
        
        // Apply hover effect
        if (hover || hover_button_index == i) {
            var pulse_effect = 0.5 + 0.5 * sin(hover_alpha_pulse);
            draw_set_color(merge_color(c_button, c_button_hover, pulse_effect));
            
            // Scale and center the button
            var scale = hover_scale;
            var w = menu_width * scale;
            var h = button_height * scale;
            var cx = menu_x + menu_width / 2;
            var cy = by + button_height / 2;
            
            draw_rectangle(
                cx - w/2, 
                cy - h/2, 
                cx + w/2, 
                cy + h/2, 
                false
            );
        } else {
            draw_set_color(c_button);
            draw_rectangle(menu_x, by, menu_x + menu_width, by + button_height, false);
        }
        
        draw_set_color(c_button_text);
        // Draw drone sprite
        draw_sprite(drone.my_sprite, 0, menu_x + 30, by + button_height / 2);
        
        // draw_set_font(font_button);
        draw_text(menu_x + 60, by + button_height / 2, drone.name);
        
        // Draw drone type
        draw_set_halign(fa_right);
        draw_text(menu_x + menu_width - 20, by + button_height / 2, string_upper(drone.priority));
        draw_set_halign(fa_left);
        
        // Draw description if hovered
        if (hover)
        {
            draw_set_color(c_description);
            // draw_set_font(font_description);
            draw_text(menu_x, room_height - 80, "View and manage this drone's capabilities.");
        }
    }
}
else
{
    // Draw upgrade levels screen for regular upgrades
    var upgrade_data = upgrades[$ current_submenu];
    if (upgrade_data != undefined)
    {
        // Find the label and description for this upgrade
        var description = "";
        var submenu_array = get_current_submenu();
        for (var i = 0; i < array_length(submenu_array); i++)
        {
            if (submenu_array[i].action == current_submenu)
            {
                description = submenu_array[i].desc;
                break;
            }
        }
        
        // Draw upgrade description
        draw_set_color(c_description);
        // draw_set_font(font_description);
        draw_text(menu_x, menu_y + 20, description);
        
        // Draw current effect
        if (upgrade_data.level > 0)
        {
            var effect_text = "Current Bonus: ";
            
            // Handle boolean upgrades differently
            if (upgrade_data.max_level == 1) {
                effect_text = "Status: UNLOCKED";
            } else {
                effect_text += string(upgrade_data.effects[upgrade_data.level - 1]);
                
                // Add appropriate units based on upgrade type
                if (current_submenu == "overheat_rate")
                    effect_text += "% reduced overheating";
                else if (current_submenu == "overheat_cooldown")
                    effect_text += "% faster cooling";
                else
                    effect_text += "% increase";
            }
                
            draw_text(menu_x, menu_y + 50, effect_text);
        }
        
        // Show different interfaces for boolean (unlock) vs. leveled upgrades
        if (upgrade_data.max_level == 1) {
            // For boolean upgrades (unlocks)
            if (upgrade_data.level == 0) {
                // Not yet unlocked
                draw_set_color(c_upgrade_available);
                draw_text(menu_x, menu_y + 100, "UNLOCK COST: $" + string(upgrade_data.base_cost));
                
                // Draw buy button
                var buy_button_x = menu_x;
                var buy_button_y = menu_y + 140;
                var buy_button_width = 120;
                var buy_button_height = 40;
                
                var buy_hover = point_in_rectangle(mouse_x, mouse_y, 
                                                 buy_button_x, buy_button_y, 
                                                 buy_button_x + buy_button_width, buy_button_y + buy_button_height);
                
                draw_set_color(buy_hover ? merge_color(c_buy_button, c_white, 0.3) : c_buy_button);
                draw_rectangle(buy_button_x, buy_button_y, 
                              buy_button_x + buy_button_width, buy_button_y + buy_button_height, 
                              false);
                
                draw_set_color(c_white);
                draw_set_halign(fa_center);
                draw_text(buy_button_x + buy_button_width/2, buy_button_y + buy_button_height/2, "UNLOCK");
                draw_set_halign(fa_left);
                
                // Draw sprite for this upgrade if applicable (for drones)
                if (string_pos("drone", current_submenu) == 1 && upgrade_data.sprite != undefined) {
                    var sprite_scale = 2;
                    draw_sprite_ext(upgrade_data.sprite, 0, 
                                  menu_x + menu_width, menu_y + 140, 
                                  sprite_scale, sprite_scale, 0, c_white, 1);
                }
            } else {
                // Already unlocked
                draw_set_color(c_upgrade_maxed);
                draw_text(menu_x, menu_y + 100, "ALREADY UNLOCKED");
                
                // Draw sprite for this upgrade if applicable (for drones)
                if (string_pos("drone", current_submenu) == 1 && upgrade_data.sprite != undefined) {
                    var sprite_scale = 2;
                    draw_sprite_ext(upgrade_data.sprite, 0, 
                                  menu_x + menu_width, menu_y + 140, 
                                  sprite_scale, sprite_scale, 0, c_white, 1);
                }
            }
        } else {
            // For leveled upgrades
            // Draw "UPGRADE LEVEL:" text
            draw_text(menu_x, menu_y + 100, "UPGRADE LEVEL:");
            
            // Draw level indicators [1][2][3][4][5] horizontally as sprites
            var level_width = 50; // Width of the sprite
            var level_spacing = 10; // Space between sprites
            var level_x_start = menu_x + 20;
            var level_y = menu_y + 130;
            
            for (var j = 0; j < upgrade_data.max_level; j++)
            {
                // Choose the appropriate sprite based on upgrade level
                // var sprite_to_draw;
                if (j < upgrade_data.level) {
                    // Already purchased level
                    // sprite_to_draw = spr_upgrade_filled;
                    draw_set_color(c_level_filled);
                } else if (j == upgrade_data.level) {
                    // Next available level to purchase
                    var next_level_cost = upgrade_data.base_cost * power(upgrade_data.cost_multiplier, upgrade_data.level);
                    if (player_currency >= next_level_cost) {
                        // sprite_to_draw = spr_upgrade_available;
                        draw_set_color(c_upgrade_available);
                    } else {
                        // sprite_to_draw = spr_upgrade_empty;
                        draw_set_color(c_level_indicator);
                    }
                } else {
                    // Future levels
                    // sprite_to_draw = spr_upgrade_empty;
                    draw_set_color(c_level_indicator);
                }
                
                // Draw the level indicator (sprite or rectangle placeholder)
                // draw_sprite(sprite_to_draw, 0, level_x_start + j * (level_width + level_spacing), level_y);
                draw_rectangle(
                    level_x_start + j * (level_width + level_spacing), 
                    level_y, 
                    level_x_start + j * (level_width + level_spacing) + level_width, 
                    level_y + 40, 
                    false
                );
                
                // Draw level number
                draw_set_color(c_black);
                draw_set_halign(fa_center);
                draw_text(
                    level_x_start + j * (level_width + level_spacing) + level_width/2, 
                    level_y + 20, 
                    string(j + 1)
                );
                draw_set_halign(fa_left);
                
                // Draw effect text below each level
                draw_set_color(c_white);
                draw_set_halign(fa_center);
                if (j < array_length(upgrade_data.effects))
                {
                    draw_text(
                        level_x_start + j * (level_width + level_spacing) + level_width/2, 
                        level_y + 60, 
                        string(upgrade_data.effects[j]) + "%"
                    );
                }
                draw_set_halign(fa_left);
                
                // Check if this box is hovered
                var hover = point_in_rectangle(
                    mouse_x, mouse_y, 
                    level_x_start + j * (level_width + level_spacing), level_y,
                    level_x_start + j * (level_width + level_spacing) + level_width, level_y + 40
                );
                
                if (hover)
                {
                    if (j < upgrade_data.level)
                    {
                        // Already purchased
                        draw_set_color(c_white);
                        draw_text(menu_x, room_height - 80, "Level " + string(j + 1) + " already purchased");
                    }
                    else if (j == upgrade_data.level)
                    {
                        // Next level - show cost and buy button
                        var next_level_cost = upgrade_data.base_cost * power(upgrade_data.cost_multiplier, upgrade_data.level);
                        draw_set_color(player_currency >= next_level_cost ? c_green : c_red);
                        draw_text(menu_x, room_height - 80, "Upgrade Cost: $" + string(next_level_cost));
                        
                        // Draw buy button for this level
                        var buy_button_x = level_x_start + j * (level_width + level_spacing);
                        var buy_button_y = level_y + 80;
                        var buy_button_width = level_width;
                        var buy_button_height = 30;
                        
                        draw_set_color(player_currency >= next_level_cost ? c_buy_button : c_gray);
                        draw_rectangle(
                            buy_button_x, buy_button_y,
                            buy_button_x + buy_button_width, buy_button_y + buy_button_height,
                            false
                        );
                        
                        draw_set_color(c_white);
                        draw_set_halign(fa_center);
                        draw_text(
                            buy_button_x + buy_button_width/2,
                            buy_button_y + buy_button_height/2,
                            "BUY"
                        );
                        draw_set_halign(fa_left);
                        
                        // Show effect improvement
                        if (j < array_length(upgrade_data.effects))
                        {
                            var prev_effect = (j > 0) ? upgrade_data.effects[j - 1] : 0;
                            var improvement = upgrade_data.effects[j] - prev_effect;
                            draw_set_color(c_white);
                            draw_text(menu_x, room_height - 50, "Improvement: +" + string(improvement) + "%");
                        }
                    }
                    else
                    {
                        // Future level - need to buy previous levels first
                        draw_set_color(c_white);
                        draw_text(menu_x, room_height - 80, "Purchase previous levels first");
                    }
                }
            }
        }
    }
}

// Draw buy confirmation dialog if active
if (show_buy_confirm) {
    // Dim background
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1.0);
    
    // Draw confirmation dialog
    var dialog_width = 300;
    var dialog_height = 150;
    var dialog_x = room_width / 2 - dialog_width / 2;
    var dialog_y = room_height / 2 - dialog_height / 2;
    
    draw_set_color(c_dkgray);
    draw_rectangle(dialog_x, dialog_y, dialog_x + dialog_width, dialog_y + dialog_height, false);
    
    draw_set_color(c_white);
    draw_line(dialog_x, dialog_y + 30, dialog_x + dialog_width, dialog_y + 30);
    
    // Draw title
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_text(room_width / 2, dialog_y + 15, "CONFIRM PURCHASE");
    
    // Draw message
    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text(room_width / 2, dialog_y + 55, "Purchase this upgrade for");
    draw_set_color(c_yellow);
    draw_text(room_width / 2, dialog_y + 80, "$" + string(confirm_cost) + "?");
    
    // Draw buttons
    // Buy button
    var buy_button_x = room_width / 2 - 100;
    var buy_button_y = dialog_y + 110;
    var buy_button_width = 80;
    var buy_button_height = 30;
    
    var buy_hover = point_in_rectangle(mouse_x, mouse_y, 
                                      buy_button_x, buy_button_y, 
                                      buy_button_x + buy_button_width, buy_button_y + buy_button_height);
    
    draw_set_color(buy_hover ? merge_color(c_buy_button, c_white, 0.3) : c_buy_button);
    draw_rectangle(buy_button_x, buy_button_y, buy_button_x + buy_button_width, buy_button_y + buy_button_height, false);
    
    draw_set_color(c_white);
    draw_text(buy_button_x + buy_button_width / 2, buy_button_y + buy_button_height / 2, "YES");
    
    // Cancel button
    var cancel_button_x = room_width / 2 + 20;
    var cancel_button_y = dialog_y + 110;
    var cancel_button_width = 80;
    var cancel_button_height = 30;
    
    var cancel_hover = point_in_rectangle(mouse_x, mouse_y, 
                                         cancel_button_x, cancel_button_y, 
                                         cancel_button_x + cancel_button_width, cancel_button_y + cancel_button_height);
    
    draw_set_color(cancel_hover ? merge_color(c_cancel_button, c_white, 0.3) : c_cancel_button);
    draw_rectangle(cancel_button_x, cancel_button_y, cancel_button_x + cancel_button_width, cancel_button_y + cancel_button_height, false);
    
    draw_set_color(c_white);
    draw_text(cancel_button_x + cancel_button_width / 2, cancel_button_y + cancel_button_height / 2, "NO");
    
    // Reset alignment
    draw_set_halign(fa_left);
}