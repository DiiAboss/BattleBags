/// @description
// Draw Event
if (current_menu == "main") {
    // Draw main menu
    for (var i = 0; i < array_length(main_menu); i++) {
        var btn = main_menu[i];
        var by = menu_y + i * (button_height + button_spacing);
        draw_rectangle(menu_x, by, menu_x + menu_width, by + button_height, false);
        draw_text_color(menu_x + 64, by + button_height / 2, btn.label, c_black, c_black, c_black, c_black, 1);
    }
} else {
    // Draw submenu
    var menu_index = -1;
    for (var i = 0; i < array_length(main_menu); i++) {
        if (main_menu[i].action == current_menu) {
            menu_index = i;
            break;
        }
    }
    if (menu_index != -1) {
        var submenu = submenus[menu_index];
        for (var i = 0; i < array_length(submenu); i++) {
            var by = menu_y + (i - scroll_offset) * (button_height + button_spacing);
            draw_rectangle(menu_x - 16, by, menu_x + menu_width, by + button_height, false);
            draw_text_color(menu_x + 64, by + button_height / 2, submenu[i].label, c_black, c_black, c_black, c_black, 1);
        }
    }
}

// Draw title
draw_text(menu_x, menu_y - 40, string_upper(current_menu));

// Draw description (if applicable)
if (selected_upgrade != -1) {
    var menu_index = -1;
    for (var i = 0; i < array_length(main_menu); i++) {
        if (main_menu[i].action == current_menu) {
            menu_index = i;
            break;
        }
    }
    if (menu_index != -1 && selected_upgrade < array_length(submenus[menu_index])) {
        draw_text_color(menu_x, room_height - 100, submenus[menu_index][selected_upgrade].desc, c_black, c_black, c_black, c_black, 1);
    }
}