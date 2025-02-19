/// @description Initialize online multiplayer options.
menu_options = ["Create Room", "Join Room", "Back"];
selected_option = 0;
last_hovered_option = -1; 
menu_spacing = 64;
menu_x = room_width / 2;
menu_y_start = room_height / 2 - (menu_spacing * (array_length(menu_options) / 2));

input_delay = 0;
max_input_delay = 10;