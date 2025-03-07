var input = obj_game_manager.input;
// ✅ Handle menu selection


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
    return;
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

if (input.ActionPress || input.Enter) {
    if (last_hovered_option == -1 || last_hovered_option == selected_option) {
        switch (selected_option) {
            case 0: // Create Room
                with(obj_connection_manager) {
                    // Initialize as host
                    player_role = PLAYER_ROLE.HOST;
                    connection_state = CONNECTION_STATE.CONNECTING;
                    
                    // Create socket if needed
                    if (client_socket == undefined) {
                        client_socket = network_create_socket(network_socket_udp);
                    }
                    
                    // Connect to server
                    var connection = network_connect_raw(client_socket, server_ip, server_port);
                    
                    if (connection >= 0) {
                        // Send create host request
                        var data = ds_map_create();
                        send_map_over_UDP(self, data, DATA_TYPE.CREATE_HOST);
                    } else {
                        show_message("Failed to connect to server!");
                    }
                }
                room_goto(rm_create_lobby);
                break;

            case 1: // Join Room
                with(obj_connection_manager) {
                    // Initialize as client
                    player_role = PLAYER_ROLE.CLIENT;
                    connection_state = CONNECTION_STATE.CONNECTING;
                    
                    // Create socket if needed
                    if (client_socket == undefined) {
                        client_socket = network_create_socket(network_socket_udp);
                    }
                    
                    // Connect to server
                    var connection = network_connect_raw(client_socket, server_ip, server_port);
                    
                    if (connection >= 0) {
                        // Request list of hosts
                        var data = ds_map_create();
                        send_map_over_UDP(self, data, DATA_TYPE.GET_HOSTS);
                    } else {
                        show_message("Failed to connect to server!");
                    }
                }
                room_goto(rm_join_lobby);
                break;

            case 2: // Back
                room_goto(rm_multiplayer_selection);
                break;
        }
    }
}
