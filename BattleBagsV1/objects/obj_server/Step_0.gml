/// @desc Server Step Logic

// 🔥 Press ENTER to start the game and notify all clients
if (keyboard_check_pressed(vk_enter)) {
    show_message("Starting Game...");

    // ✅ Notify all players to switch rooms
    for (var i = 0; i < ds_list_size(global.connected_clients); i++) {
        var sock = ds_list_find_value(global.connected_clients, i);

        var buffer = buffer_create(256, buffer_grow, 1);
        buffer_seek(buffer, buffer_seek_start, 0);
        buffer_write(buffer, buffer_u16, 3); // CMD: Start Game
        network_send_packet(sock, buffer, buffer_tell(buffer));
        buffer_delete(buffer);
    }

    // ✅ Move server to the game room
    room_goto(rm_online_game);
}

// 🔥 Press SPACE to broadcast a message to all clients
if (keyboard_check_pressed(vk_space)) {
    var buffer = buffer_create(256, buffer_grow, 1);
    buffer_seek(buffer, buffer_seek_start, 0);
    buffer_write(buffer, buffer_u16, 0);    // CMD: Message
    buffer_write(buffer, buffer_string, "Hello from the server!");

    for (var i = 0; i < ds_list_size(global.connected_clients); ++i) {
        var sock = ds_list_find_value(global.connected_clients, i);
        network_send_packet(sock, buffer, buffer_tell(buffer));
    }
    buffer_delete(buffer);
}
