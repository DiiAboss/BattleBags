// Step Event in obj_intown_shop
/// @description Handle input and menu navigation
var input = obj_game_manager.input;
input.Update(self, mouse_x, mouse_y);

// Handle back/escape navigation
if ((input.Back) || input.Escape || input.AltPress) && !show_buy_confirm
{
    if (current_menu == "main")
    {
        room_goto(rm_pre_game_screen);
    }
    else if (current_submenu != "")
    {
        // Return from upgrade screen to submenu
        current_submenu = "";
    }
    else {
        // Return from submenu to main menu
        current_menu = "main";
    }
}

// Close confirmation dialog if open
if (show_buy_confirm && ((input.Escape || input.AltPress))) {
    show_buy_confirm = false;
}

// Mouse wheel scrolling
if (mouse_wheel_up())
{
    scroll_offset = max(0, scroll_offset - 1);
}
else if (mouse_wheel_down())
{
    var menu_items = 0;
    
    if (current_menu == "main")
    {
        menu_items = array_length(main_menu);
    }
    else if (current_submenu == "")
    {
        var submenu_array = get_current_submenu();
        menu_items = array_length(submenu_array);
    }
    else if (current_submenu == "drone_list")
    {
        menu_items = array_length(unlocked_drones);
    }
    
    var max_visible = floor((room_height - menu_y - 50) / (button_height + button_spacing));
    scroll_offset = min(max(0, menu_items - max_visible), scroll_offset + 1);
}

// Handle hover effect for buttons
hover_button_index = -1;
hover_alpha_pulse += 0.05;
if (hover_alpha_pulse > 2 * pi) hover_alpha_pulse = 0;

// If confirmation dialog is open, handle its buttons
if (show_buy_confirm) {
    // Buy button
    var buy_button_x = room_width / 2 - 100;
    var buy_button_y = room_height / 2 + 30;
    var buy_button_width = 80;
    var buy_button_height = 40;
    
    var buy_hover = point_in_rectangle(mouse_x, mouse_y, 
                                      buy_button_x, buy_button_y, 
                                      buy_button_x + buy_button_width, buy_button_y + buy_button_height);
    
    // Cancel button
    var cancel_button_x = room_width / 2 + 20;
    var cancel_button_y = room_height / 2 + 30;
    var cancel_button_width = 80;
    var cancel_button_height = 40;
    
    var cancel_hover = point_in_rectangle(mouse_x, mouse_y, 
                                         cancel_button_x, cancel_button_y, 
                                         cancel_button_x + cancel_button_width, cancel_button_y + cancel_button_height);
    
    if (mouse_check_button_pressed(mb_left)) {
        if (buy_hover) {
            // Purchase the upgrade
            var upgrade_data = upgrades[$ confirm_upgrade];
            if (player_currency >= confirm_cost) {
                player_currency -= confirm_cost;
                upgrade_data.level++;
                apply_upgrade_effects(confirm_upgrade, upgrade_data.level);
                ////audio_play_sound(snd_purchase, 1, false);
            } else {
                ////audio_play_sound(snd_error, 1, false);
            }
            show_buy_confirm = false;
        } else if (cancel_hover) {
            // Cancel purchase
            show_buy_confirm = false;
            ////audio_play_sound(snd_button_click, 1, false);
        }
    }
    
    return; // Skip the rest of the step event while confirmation is showing
}

// Mouse click handling
if (mouse_check_button_pressed(mb_left))
{
    var clicked_index = -1;
    
    // Check for clicks on level indicators and buy buttons when in an upgrade submenu
    if (current_submenu != "" && current_submenu != "drone_list") {
        var upgrade_data = upgrades[$ current_submenu];
        if (upgrade_data != undefined) {
            // For boolean upgrades (single level unlocks)
            if (upgrade_data.max_level == 1 && upgrade_data.level == 0) {
                // Check if clicked on the unlock button
                var buy_button_x = menu_x;
                var buy_button_y = menu_y + 140;
                var buy_button_width = 120;
                var buy_button_height = 40;
                
                if (point_in_rectangle(mouse_x, mouse_y,
                                     buy_button_x, buy_button_y,
                                     buy_button_x + buy_button_width, buy_button_y + buy_button_height)) {
                    show_buy_confirm = true;
                    confirm_upgrade = current_submenu;
                    confirm_cost = upgrade_data.base_cost;
                    return; // Exit the step event
                }
            }
            // For leveled upgrades
            else {
                // Check each level indicator
                var level_width = 50;
                var level_spacing = 10;
                var level_x_start = menu_x + 20;
                var level_y = menu_y + 130;
                
                for (var j = 0; j < upgrade_data.max_level; j++) {
                    // Check if we clicked on this level
                    if (point_in_rectangle(mouse_x, mouse_y,
                                         level_x_start + j * (level_width + level_spacing), level_y,
                                         level_x_start + j * (level_width + level_spacing) + level_width, level_y + 40)) {
                        
                        // Can only buy the next available level
                        if (j == upgrade_data.level && upgrade_data.level < upgrade_data.max_level) {
                            var cost = upgrade_data.base_cost * power(upgrade_data.cost_multiplier, upgrade_data.level);
                            show_buy_confirm = true;
                            confirm_upgrade = current_submenu;
                            confirm_cost = cost;
                            return; // Exit the step event
                        }
                    }
                    
                    // Also check if we clicked on the BUY button under a level
                    var buy_button_x = level_x_start + j * (level_width + level_spacing);
                    var buy_button_y = level_y + 80;
                    var buy_button_width = level_width;
                    var buy_button_height = 30;
                    
                    if (point_in_rectangle(mouse_x, mouse_y,
                                         buy_button_x, buy_button_y,
                                         buy_button_x + buy_button_width, buy_button_y + buy_button_height)) {
                        
                        // Can only buy the next available level
                        if (j == upgrade_data.level && upgrade_data.level < upgrade_data.max_level) {
                            var cost = upgrade_data.base_cost * power(upgrade_data.cost_multiplier, upgrade_data.level);
                            show_buy_confirm = true;
                            confirm_upgrade = current_submenu;
                            confirm_cost = cost;
                            return; // Exit the step event
                        }
                    }
                }
            }
        }
    }
    
    // The rest of your existing click handling code (unchanged)
    // Calculate which button was clicked
    for (var i = 0; i < 100; i++) // Arbitrary large number, but we'll break out of the loop
    {
        var by = menu_y + (i - scroll_offset) * (button_height + button_spacing);
        
        // If button is off-screen, skip
        if (by + button_height < menu_y) continue;
        if (by > room_height - 100) break;
        
        if (point_in_rectangle(mouse_x, mouse_y, menu_x, by, menu_x + menu_width, by + button_height))
        {
            clicked_index = i;
            break;
        }
    }
    
    if (clicked_index >= 0)
    {
        //audio_play_sound(snd_button_click, 1, false);
        
        if (current_menu == "main" && clicked_index < array_length(main_menu))
        {
            // Clicked on main menu item
            current_menu = main_menu[clicked_index].action;
            current_submenu = "";
            scroll_offset = 0;
        }
        else if (current_submenu == "")
        {
            // Clicked on submenu item
            var submenu_array = get_current_submenu();
            if (clicked_index < array_length(submenu_array))
            {
                current_submenu = submenu_array[clicked_index].action;
                selected_upgrade = clicked_index;
                scroll_offset = 0;
            }
        }
        else if (current_submenu == "drone_list")
        {
            // Clicked on a drone in the list
            if (clicked_index < array_length(unlocked_drones))
            {
                current_submenu = "drone_" + string(clicked_index);
                selected_upgrade = clicked_index;
                scroll_offset = 0;
            }
        }
    }
}