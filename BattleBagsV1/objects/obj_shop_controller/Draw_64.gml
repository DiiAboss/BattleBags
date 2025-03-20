/// @description

draw_set_font(fnt_basic);
draw_set_color(c_white);

// Draw background panel
draw_set_alpha(0.9);
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);



// Draw scrollable items
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var item_y = scroll_area_y - scroll_offset;

var border_color = c_green;

for (var i = 0; i < array_length(shop_items); i++) {
    var item = shop_items[i];

    // Draw item background
    var hv_color = item.hovered ? c_green : c_white;
    var bg_color = item.purchased ? c_dkgray : (selected_item == i ? c_navy : c_gray);
    
    
    if !(item.hovered)
    {
        draw_rectangle_color(scroll_area_x - 90, item_y, scroll_area_x + scroll_area_width, item_y + item_height, bg_color, bg_color, bg_color, bg_color, false);
        draw_rectangle_color(scroll_area_x - 90, item_y, scroll_area_x + scroll_area_width, item_y + item_height, hv_color, hv_color, hv_color, hv_color, true);
        // Draw item name and price
        draw_set_color(c_white);
        draw_text(scroll_area_x - 88, item_y + 20, item.name);
        //draw_set_color(c_yellow);
        //draw_text(scroll_area_x - 88, item_y + 45, "Price: " + string(item.price));
    }
    
    // Draw item sprite placeholder
    draw_sprite(item.sprite, 0, scroll_area_x + 40, item_y + item_height / 2);
    

    
    item_y += item_height + item_padding;
}

var current_item = shop_items[hover_index];
if (current_item)
{
    var bg_color2 = current_item.purchased ? c_dkgray : c_ltgray;
    item_y = scroll_area_y - scroll_offset + (item_height + item_padding) * hover_index;
    draw_rectangle_color(scroll_area_x, item_y, scroll_area_x + scroll_area_width, item_y + (item_height * 3), bg_color2, bg_color2, bg_color2, bg_color2, false);
    draw_rectangle_color(scroll_area_x, item_y, scroll_area_x + scroll_area_width, item_y + (item_height * 3), border_color, border_color, border_color, border_color, true);
    // Draw item name and price
        draw_set_color(c_white);
        draw_text(scroll_area_x + 80, item_y + 20, current_item.name);
        draw_set_color(c_yellow);
        draw_text(scroll_area_x + 80, item_y + 45, "Price: " + string(current_item.price));
}

draw_set_color(c_black);
// Draw shop borders
var _border_y = (item_height + item_padding + scroll_area_y) + 64;
var _border_length = 400 + scroll_area_height;
draw_rectangle_color(scroll_area_x, _border_y, scroll_area_x + scroll_area_width, _border_y + _border_length, c_black, c_black, c_black, c_black, false);
draw_rectangle_color(scroll_area_x, _border_y, scroll_area_x + scroll_area_width, _border_y + _border_length, c_grey, c_grey, c_grey, c_grey, true);
//draw_rectangle_color(scroll_area_x, room_height - dialogue_box_height, room_width - 32, room_height  - dialogue_box_height + 224, c_grey, c_grey, c_grey, c_grey, true);

draw_rectangle_color(scroll_area_x, 0, scroll_area_x + scroll_area_width, dialogue_box_height - 244, c_black, c_black, c_black, c_black, false);
draw_rectangle_color(scroll_area_x, 0, scroll_area_x + scroll_area_width, dialogue_box_height - 244, c_grey, c_grey, c_grey, c_grey, true);


// Draw Dialogue Box
draw_set_color(c_black);
draw_rectangle_color(32, room_height - dialogue_box_height, room_width - 32, room_height  - dialogue_box_height + 250, c_black, c_black, c_black, c_black, false);
draw_rectangle_color(32, room_height - dialogue_box_height, room_width - 32, room_height  - dialogue_box_height + 250, c_grey, c_grey, c_grey, c_grey, true);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_ext(room_width / 2, room_height - dialogue_box_height / 4, dialogue_text, -1, room_width - 40);

// Title
//draw_set_halign(fa_center);
draw_text((scroll_area_x + (scroll_area_width * 0.5)), 40, "Factory Shop");

// Draw player currency
draw_set_halign(fa_right);

draw_text(room_width - 20, 20, "Gold: " + string(player_currency));
 