/// @description Initialize multiplayer menu options.
menu_options = ["Local Multiplayer", "Online Multiplayer", "Back"];
selected_option = -1;
last_hovered_option = -1; 
menu_spacing = 64;
menu_x = room_width / 2;
menu_y_start = room_height / 2 - (menu_spacing * (array_length(menu_options) / 2));

input_delay = 10;
max_input_delay = 10;
