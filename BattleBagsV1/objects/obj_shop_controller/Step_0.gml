/// @description
var input = obj_game_manager.input;

if (input.Escape) || keyboard_check_pressed(ord("U"))
{
    instance_destroy();
}

var t_scroll = -1;

// Mouse scroll (smooth snapping)
if (input.ScrollUp) {
    hover_index = max(hover_index - 1, 0);
    t_scroll = max_scroll_default + (hover_index * (item_height + item_padding));
}
if (input.ScrollDown) {
    hover_index = min(hover_index + 1, array_length(shop_items) - 1);
    t_scroll = max_scroll_default + (hover_index * (item_height + item_padding));
}


scroll_offset = lerp(scroll_offset, target_scroll, scroll_speed);
// Smoothly interpolate toward the target scroll position


// Clamp scroll_offset
scroll_offset = clamp(scroll_offset, max_scroll_default, 880);

// Update hovered item based on hover_index
for (var i = 0; i < array_length(shop_items); i++) {
    shop_items[i].hovered = (i == hover_index);
}


//// Mouse input for direct selection
if (input.InputType == INPUT.KEYBOARD) {
    var mx = mouse_x;
    var my = mouse_y;
    if (point_in_rectangle(mx, my, scroll_area_x, scroll_area_y, scroll_area_x + scroll_area_width, scroll_area_y + scroll_area_height)) {
        var relative_y = my - scroll_area_y + scroll_offset - max_scroll_default;
        var clicked_index = floor(relative_y / (item_height + item_padding));
        if (input.ActionPress)
        {
            if (clicked_index >= 0 && clicked_index < array_length(shop_items)) {
                hover_index = clicked_index;
                t_scroll = hover_index * (item_height + item_padding);
                target_scroll = t_scroll;
            }
        }

    }
}

if (input_delay <= 0)
{
    if (t_scroll != -1)
    {
       target_scroll = t_scroll; 
        if (scroll_offset == target_scroll)
        {
                    input_delay = input_delay_max;
                    are_you_sure = false;
        }

    }
    
}
input_delay--;

// Confirm selection and attempt purchase
if (input.ActionPress) {
    
    if !(are_you_sure)
    {
        are_you_sure = true;
        return;
    }
    
    
    selected_item = hover_index;
    var item = shop_items[selected_item];
    
    dialogue_text = item.desc + " (Cost: " + string(item.price) + " gold)";
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
    are_you_sure = false;
}



