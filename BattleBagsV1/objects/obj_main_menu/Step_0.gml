/// @description Handle menu navigation and selection.
var input = obj_game_manager.input;

input.Update(self, x, y);

var mouse_x_pos = device_mouse_x(0);
var mouse_y_pos = device_mouse_y(0);

y = menu_y_start + (selected_option * menu_spacing);

// ✅ Mouse hover detection
for (var i = 0; i < array_length(menu_options); i++) {
    var menu_y = menu_y_start + (i * menu_spacing);
    
    if (point_in_rectangle(mouse_x_pos, mouse_y_pos, menu_x - 100, menu_y - 20, menu_x + 100, menu_y + 20)) {
        selected_option = i;
        last_hovered_option = i; // Store the last hovered item
    }
}
if (input_delay > 0)
    {
        input_delay--;
    }
    
    if (input.Up)
    {
        if (input_delay <= 0)
        {
            selected_option = (selected_option - 1 + array_length(menu_options)) mod array_length(menu_options);
            last_hovered_option = -1; // Reset hover when using keys
            input_delay = max_input_delay;
        }
    }
    
    if (input.Down)
    {
        if (input_delay <= 0)
        {
            selected_option = (selected_option + 1) mod array_length(menu_options);
            last_hovered_option = -1;
            input_delay = max_input_delay;
        }
    }


// ✅ Handle menu selection (keyboard OR mouse click)
if (input.ActionPress || input.Enter) {
    if (last_hovered_option == -1 || last_hovered_option == selected_option) {
        switch (selected_option) {
            case 0: // Start Game
                room_goto(rm_gameRoom);
                break;

            case 1: // Multiplayer Mode
                room_goto(rm_multiplayer_selection);
                break;

            case 2: // Stats Screen
                room_goto(rm_stats);
                break;

            case 3: // Quit Game
                game_end();
                break;
        }
    }
}


if (keyboard_check_pressed(vk_alt))
{
    room_goto(rm_local_multiplayer_lobby);
}