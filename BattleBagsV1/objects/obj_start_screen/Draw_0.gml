/// @description
// Draw Event
for (var i = 0; i < array_length(buttons); i++) {
    var btn = buttons[i];
    var bx = btn.x;
    var by = button_y;
    
    // Hover effect
    var is_hovered = (mouse_x > bx && mouse_x < bx + button_width && mouse_y > by && mouse_y < by + button_height);
    draw_set_color(is_hovered ? c_gray : c_white);
    draw_rectangle(bx, by, bx + button_width, by + button_height, false);
    
    // Text
    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(bx + button_width / 2, by + button_height / 2, btn.label);
    
    // Cross out EXPLORE
    if (btn.action == "explore") {
        draw_set_color(c_red);
        draw_line(bx, by + button_height / 2, bx + button_width, by + button_height / 2);
    }
}