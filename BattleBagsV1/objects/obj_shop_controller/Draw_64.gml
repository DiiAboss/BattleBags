// DRAW GUI EVENT
/// @description

draw_set_font(fnt_basic);
draw_set_color(c_white);

// Draw background panel
draw_set_alpha(0.9);
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);

// Draw title
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(room_width * 0.5, room_height * 0.1, "Factory Shop");

// Draw player currency
draw_set_halign(fa_right);
draw_set_valign(fa_top);
draw_text(room_width - 20, 20, "Gold: " + string(player_currency));

// Draw upgrade items
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Calculate visible item range
var item_start_x = display_area_x - horizontal_scroll;
var visible_start = floor(horizontal_scroll / (item_width + item_padding));
var visible_end = min(array_length(shop_items) - 1, visible_start + max_items_visible + 1);

// Draw scroll buttons if needed
if (array_length(shop_items) > max_items_visible) {
    // Left scroll button
    var left_btn_color = (left_btn_hover) ? c_yellow : c_white;
    draw_set_color(left_btn_color);
    draw_circle(left_scroll_btn_x, scroll_btn_y, scroll_btn_size, false);
    draw_set_color(c_black);
    draw_text(left_scroll_btn_x, scroll_btn_y, "<");
    
    // Right scroll button
    var right_btn_color = (right_btn_hover) ? c_yellow : c_white;
    draw_set_color(right_btn_color);
    draw_circle(right_scroll_btn_x, scroll_btn_y, scroll_btn_size, false);
    draw_set_color(c_black);
    draw_text(right_scroll_btn_x, scroll_btn_y, ">");
}

// Draw items
draw_set_color(c_white);
for (var i = visible_start; i <= visible_end; i++) {
    if (i >= 0 && i < array_length(shop_items)) {
        var item = shop_items[i];
        var item_x = item_start_x + (i * (item_width + item_padding));
        
        // Only draw if item would be visible on screen
        if (item_x + item_width >= display_area_x && item_x <= display_area_x + (max_items_visible * (item_width + item_padding))) {
            // Background color based on status
            var bg_color;
            var border_color;
            
            if (item.purchased) {
                bg_color = c_dkgray;
                border_color = c_gray;
            } else if (i == selected_item) {
                bg_color = c_navy;
                border_color = c_aqua;
            } else if (item.hovered) {
                bg_color = c_gray;
                border_color = c_lime;
            } else {
                bg_color = c_gray;
                border_color = c_white;
            }
            
            // Draw item background
            draw_rectangle_color(item_x, display_area_y, 
                            item_x + item_width, display_area_y + item_height, 
                            bg_color, bg_color, bg_color, bg_color, false);
            
            // Draw border
            draw_rectangle_color(item_x, display_area_y, 
                            item_x + item_width, display_area_y + item_height, 
                            border_color, border_color, border_color, border_color, true);
            
            // Draw sprite placeholder (centered in the box)
            draw_sprite(item.sprite, 0, item_x + (item_width / 2), display_area_y + (item_height / 2));
            
            // Draw item name below the box
            draw_set_color(c_white);
            draw_set_valign(fa_top);
            draw_text(item_x + (item_width / 2), display_area_y + item_height + 10, item.name);
            
            // Draw price below name
            draw_set_color(c_yellow);
            draw_text(item_x + (item_width / 2), display_area_y + item_height + 30, string(item.price) + "g");
        }
    }
}

// Draw text box
draw_set_color(c_black);
draw_rectangle_color(text_box_x, text_box_y, 
                text_box_x + text_box_width, text_box_y + text_box_height, 
                c_black, c_black, c_black, c_black, false);
draw_set_color(c_gray);
draw_rectangle_color(text_box_x, text_box_y, 
                text_box_x + text_box_width, text_box_y + text_box_height, 
                c_gray, c_gray, c_gray, c_gray, true);

// Draw shop owner image box
draw_rectangle_color(shop_owner_box_x, shop_owner_box_y, 
                shop_owner_box_x + shop_owner_box_width, shop_owner_box_y + shop_owner_box_height, 
                c_black, c_black, c_black, c_black, false);
draw_rectangle_color(shop_owner_box_x, shop_owner_box_y, 
                shop_owner_box_x + shop_owner_box_width, shop_owner_box_y + shop_owner_box_height, 
                c_white, c_white, c_white, c_white, true);
// Placeholder for shop owner sprite
// draw_sprite(spr_shop_owner, 0, shop_owner_box_x + shop_owner_box_width/2, shop_owner_box_y + shop_owner_box_height/2);

// Draw dialogue text
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var text_x = shop_owner_box_x + shop_owner_box_width + 20;
var text_width = text_box_width - shop_owner_box_width - buy_button_width - 60;
draw_text_ext(text_x, shop_owner_box_y + 10, dialogue_text, 20, text_width);

// Draw buy button if an item is selected
if (selected_item != -1) {
    var btn_color = buy_button_hover ? c_lime : c_green;
    draw_rectangle_color(buy_button_x, buy_button_y, 
                    buy_button_x + buy_button_width, buy_button_y + buy_button_height, 
                    btn_color, btn_color, btn_color, btn_color, false);
    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(buy_button_x + buy_button_width/2, buy_button_y + buy_button_height/2, are_you_sure ? "CONFIRM" : "BUY");
}
