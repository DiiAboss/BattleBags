/// @description Draw Main Menu.


//draw_set_halign(fa_center);
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
        //draw_text_text_font(menu_x - 5, menu_y, "- " + menu_options[i] + " -");
        //draw_text(menu_x - 5, menu_y, "- " + menu_options[i] + " -");
		draw_clay_text_wave( "- " + menu_options[i] + " -", menu_x - 32, menu_y,4,1, 2, 1.1);
    } else {
        //draw_set_color($29c8f0);
        //draw_text_text_font(menu_x, menu_y, menu_options[i]);
		draw_clay_text(menu_options[i], menu_x, menu_y);
        //draw_text(menu_x, menu_y, menu_options[i]);
    }
}

draw_clay_text_wave("The Comboneers", 220, 150, 2, 0.5, 2, 2);

draw_set_color(c_black)
draw_clay_text_wave("The Comboneers", 224, 154, 2, 0.5, 2, 2);
draw_set_color(c_white);
//draw_sprite(spr_gameTitle, -1, room_width/2, 150);

//testing
