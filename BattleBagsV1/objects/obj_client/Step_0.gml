
/// @desc Assign Control to Player (Keyboard or Gamepad)
var input = obj_game_manager.input; // ✅ Use global input system

if (input.ActionKey) {
    var buffer = buffer_create(256, buffer_fixed, 1);
    buffer_write(buffer, buffer_string, "set_input " + string(my_player_id) + " KEYBOARD");
    network_send_udp(client_socket, server_ip, server_port, buffer, buffer_tell(buffer));
    buffer_delete(buffer);
}

// ✅ Assign gamepad input
var gp_num = gamepad_get_device_count();
for (var i = 0; i < gp_num; i++) {
    if (gamepad_is_connected(i) && gamepad_button_check_pressed(i, gp_start)) {
        var buffer = buffer_create(256, buffer_fixed, 1);
        buffer_write(buffer, buffer_string, "set_input " + string(my_player_id) + " GAMEPAD");
        network_send_udp(client_socket, server_ip, server_port, buffer, buffer_tell(buffer));
        buffer_delete(buffer);
    }
}

// ✅ Send Player Inputs to Server
if (input.ActionKey) { // Instead of player_action_key_pressed
    var buffer = buffer_create(256, buffer_fixed, 1);
    buffer_write(buffer, buffer_string, "input " + string(my_player_id) + " " + 
                string(input.ActionKey) + " " + 
                string(input.hover_x) + " " + 
                string(input.hover_y));
    network_send_udp(client_socket, server_ip, server_port, buffer, buffer_tell(buffer));
    buffer_delete(buffer);
}

