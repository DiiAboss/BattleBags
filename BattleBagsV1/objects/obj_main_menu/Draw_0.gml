/// @description Draw Main Menu.

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

font_enable_effects(fnt_textFont,true, {
    outlineEnable: true,
    outlineDistance: 3,
    outlineColour: c_white,
    outlineAlpha: 0.5}
);

for (var i = 0; i < array_length(menu_options); i++) {
    var menu_y = menu_y_start + (i * menu_spacing);

    if (i == selected_option) {
        draw_set_color(c_white);
        draw_text_text_font(menu_x - 5, menu_y, "- " + menu_options[i] + " -");
    } else {
        draw_set_color($29c8f0);
        draw_text_text_font(menu_x, menu_y, menu_options[i]);
    }
}

draw_sprite(spr_gameTitle, -1, room_width/2, 150);

//testing
