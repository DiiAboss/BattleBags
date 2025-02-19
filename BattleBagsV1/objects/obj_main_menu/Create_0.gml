/// @description Initialize menu options.

menu_options = ["Start Game", "Multiplayer", "Stats", "Quit"];
selected_option = 0;
last_hovered_option = -1; // -1 means no hover yet
menu_spacing = 72; // Spacing between menu items
menu_x = room_width / 2;
menu_y_start = room_height / 2 - (menu_spacing * (array_length(menu_options) / 2));

input_delay = 0;
max_input_delay = 10;