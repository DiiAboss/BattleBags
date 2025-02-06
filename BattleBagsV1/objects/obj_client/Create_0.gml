/// @desc Enter a Lobby Code & Connect
if (keyboard_check_pressed(vk_enter)) {
    lobby_code = get_string("Enter Lobby Code:", ""); // User input
    
    var buffer = buffer_create(256, buffer_fixed, 1);
    buffer_write(buffer, buffer_string, "join " + lobby_code);
    
    // Send request to **lobby server** (acts as a simple lookup server)
    network_send_udp(client_socket, "127.0.0.1", 6500, buffer, buffer_tell(buffer));
    buffer_delete(buffer);
}
