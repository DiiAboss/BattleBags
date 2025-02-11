/// @description Draw Main Menu.

/// @description Draw Main Menu.

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_basic);
draw_set_color(c_white);

for (var i = 0; i < array_length(menu_options); i++) {
    var menu_y = menu_y_start + (i * menu_spacing);

    if (i == selected_option) {
        draw_set_color(c_aqua);
        draw_text(menu_x - 5, menu_y, "> " + menu_options[i] + " <");
    } else {
        draw_set_color(c_white);
        draw_text(menu_x, menu_y, menu_options[i]);
    }
}

