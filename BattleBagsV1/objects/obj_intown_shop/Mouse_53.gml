if (current_menu == "main") {
        for (var i = 0; i < array_length(main_menu); i++) {
            var by = menu_y + i * (button_height + button_spacing);
            if (mouse_y > by && mouse_y < by + button_height) {
                current_menu = main_menu[i].action;
                scroll_offset = 0;
            }
        }
    } else {
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
                if (mouse_y > by && mouse_y < by + button_height) {
                    selected_upgrade = i;
                }
            }
        }
    }