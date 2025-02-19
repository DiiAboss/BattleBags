var input = obj_game_manager.input;

/// @desc Host Presses Start Game
if (keyboard_check_pressed(vk_enter)) {
    show_message("Starting Game...");

    // ✅ Notify all players to switch rooms
    for (var i = 0; i < ds_map_size(global.connected_clients); i++) {
        var player = ds_map_find_value(global.connected_clients, i);

        var buffer = buffer_create(256, buffer_fixed, 1);
        buffer_write(buffer, buffer_string, "start_game");
        network_send_udp(server_socket, player.ip, player.port, buffer, buffer_tell(buffer));
        buffer_delete(buffer);
    }

    // ✅ Move server to the game room
    room_goto(rm_online_game);
}