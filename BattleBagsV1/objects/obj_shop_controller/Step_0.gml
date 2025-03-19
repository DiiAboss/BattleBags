/// @description
var input = obj_game_manager.input;

if (input.Escape) || keyboard_check_pressed(ord("U"))
{
    instance_destroy();
}

// Scrolling control
if (input.ScrollUp) {
    scroll_offset = max(scroll_offset - scroll_speed, 0);
}
if (input.ScrollDown) {
    var total_height = array_length(shop_items) * (item_height + item_padding);
    max_scroll = max(0, total_height - scroll_area_height);
    scroll_offset = min(scroll_offset + scroll_speed, max_scroll);
}

// Item selection
if (input.ActionPress) {
    var mx = mouse_x;
    var my = mouse_y;

    if (point_in_rectangle(mx, my, scroll_area_x, scroll_area_y, scroll_area_x + scroll_area_width, scroll_area_y + scroll_area_height)) {
        var relative_y = my - scroll_area_y + scroll_offset;
        var clicked_index = floor(relative_y / (item_height + item_padding));

        if (clicked_index >= 0 && clicked_index < array_length(shop_items)) {
            selected_item = clicked_index;
            dialogue_text = shop_items[selected_item].desc + " (Cost: " + string(shop_items[selected_item].price) + " gold)";
        }
    } else if (selected_item != -1 && mouse_y > room_height - dialogue_box_height) {
        // Attempt to buy selected item when clicking dialogue box
        var item = shop_items[selected_item];
        if (!item.purchased && player_currency >= item.price) {
            player_currency -= item.price;
            item.purchased = true;
            dialogue_text = "Purchased: " + item.name;
            
            // TODO: Apply upgrade or give drone to player here
        } else if (item.purchased) {
            dialogue_text = "You already purchased " + item.name + ".";
        } else {
            dialogue_text = "You don't have enough gold!";
        }
    }
}

