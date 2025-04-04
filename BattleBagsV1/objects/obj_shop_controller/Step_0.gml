// STEP EVENT
/// @description
var input = obj_game_manager.input;

// Exit shop
if (input.Escape) || keyboard_check_pressed(ord("U")) {
    instance_destroy();
}

// Mouse position
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Handle horizontal scrolling with buttons
left_btn_hover = point_in_circle(mx, my, left_scroll_btn_x, scroll_btn_y, scroll_btn_size);
right_btn_hover = point_in_circle(mx, my, right_scroll_btn_x, scroll_btn_y, scroll_btn_size);

if (input.ActionPress) {
    if (left_btn_hover && horizontal_scroll > 0) {
        target_scroll = max(0, horizontal_scroll - (item_width + item_padding));
    }
    
    if (right_btn_hover && horizontal_scroll < max_scroll) {
        target_scroll = min(max_scroll, horizontal_scroll + (item_width + item_padding));
    }
}

// Smooth scrolling
horizontal_scroll = lerp(horizontal_scroll, target_scroll, scroll_speed);

// Check item hover
var item_hovered = false;
var item_start_x = display_area_x - horizontal_scroll;

for (var i = 0; i < array_length(shop_items); i++) {
    var item_x = item_start_x + (i * (item_width + item_padding));
    
    // Only process items that would be visible on screen
    if (item_x + item_width >= display_area_x && item_x <= display_area_x + (max_items_visible * (item_width + item_padding))) {
        var is_hovering = point_in_rectangle(mx, my, 
                                            item_x, display_area_y, 
                                            item_x + item_width, display_area_y + item_height);
        
        shop_items[i].hovered = is_hovering;
        
        if (is_hovering) {
            hover_index = i;
            item_hovered = true;
            
            if (input.ActionPress) {
                selected_item = i;
                var item = shop_items[i];
                dialogue_text = "\"" + item.desc + "\" " + item.shopkeeper_comment;
                are_you_sure = false;
            }
        }
    } else {
        shop_items[i].hovered = false;
    }
}

// Reset hover index if no item is being hovered
if (!item_hovered && input.ActionPress) {
    // Check if clicked on buy button
    buy_button_hover = point_in_rectangle(mx, my, buy_button_x, buy_button_y, 
                                        buy_button_x + buy_button_width, buy_button_y + buy_button_height);
    
    if (buy_button_hover && selected_item != -1) {
        var item = shop_items[selected_item];
        
        if (!are_you_sure) {
            dialogue_text = "Are you sure you want to buy " + item.name + " for " + string(item.price) + " gold?";
            are_you_sure = true;
        } else {
            if (!item.purchased && player_currency >= item.price) {
                // Check if requirement is met
                var req_met = true;
                if (item.req != "none") {
                    // TODO: Add code to check if requirement is met
                    // For now, we'll assume all requirements are met
                    // Example code:
                    // req_met = global.unlocked_features[$ item.req] ?? false;
                }
                
                if (req_met) {
                    player_currency -= item.price;
                    item.purchased = true;
                    
                    // Apply effects based on type
                    switch (item.type) {
                        case "consumable":
                            // Add to inventory instead of applying immediately
                            dialogue_text = "Excellent! I've added " + item.name + " to your inventory. Use it wisely!";
                            // TODO: Add to player's inventory
                            break;
                            
                        case "drone":
                            dialogue_text = "Your drones will appreciate this upgrade! They'll perform much better now.";
                            // TODO: Apply drone upgrade effect
                            break;
                            
                        case "recycler":
                            dialogue_text = "Your recycler system has been upgraded. You'll see better results right away!";
                            // TODO: Apply recycler upgrade effect
                            break;
                            
                        case "engine":
                            dialogue_text = "I've upgraded your engine components. Your factory will run more efficiently now!";
                            // TODO: Apply engine upgrade effect
                            break;
                            
                        default:
                            dialogue_text = "Excellent choice! You've purchased " + item.name + ". This will greatly boost your factory's performance!";
                            // TODO: Apply generic upgrade effect
                            break;
                    }
                } else {
                    dialogue_text = "I'm afraid you need to unlock " + item.req + " first before you can purchase this upgrade.";
                }
            } else if (item.purchased) {
                dialogue_text = "You've already purchased " + item.name + ". Perhaps you'd like something else from my collection?";
            } else {
                dialogue_text = "I'm afraid you don't have enough gold for that. Come back when you've earned some more!";
            }
            are_you_sure = false;
        }
    }
}



