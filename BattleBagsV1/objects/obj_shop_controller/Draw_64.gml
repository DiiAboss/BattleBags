/// @description

draw_set_font(fnt_basic);
draw_set_color(c_white);

// Draw background panel
draw_set_alpha(0.9);
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);

// Title
draw_set_halign(fa_center);
draw_text(room_width / 2, 40, "Factory Shop");

// Draw scrollable items
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var item_y = scroll_area_y - scroll_offset;

for (var i = 0; i < array_length(shop_items); i++) {
    var item = shop_items[i];

    // Draw item background
    var bg_color = item.purchased ? c_dkgray : (selected_item == i ? c_navy : c_gray);
    draw_rectangle_color(scroll_area_x, item_y, scroll_area_x + scroll_area_width, item_y + item_height, bg_color, bg_color, bg_color, bg_color, false);
    
    // Draw item sprite placeholder
    draw_sprite(item.sprite, 0, scroll_area_x + 40, item_y + item_height / 2);
    
    // Draw item name and price
    draw_set_color(c_white);
    draw_text(scroll_area_x + 80, item_y + 20, item.name);
    draw_set_color(c_yellow);
    draw_text(scroll_area_x + 80, item_y + 45, "Price: " + string(item.price));
    
    item_y += item_height + item_padding;
}

// Draw Dialogue Box
draw_set_color(c_black);
draw_rectangle_color(0, room_height - dialogue_box_height, room_width, room_height, c_black, c_black, c_black, c_black, false);

draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_ext(room_width / 2, room_height - dialogue_box_height / 2, dialogue_text, -1, room_width - 40);

// Draw player currency
draw_set_halign(fa_right);
draw_text(room_width - 20, 20, "Gold: " + string(player_currency));
