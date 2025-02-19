/// @desc Server Async Network Event
var n_id = ds_map_find_value(async_load, "id");

// ✅ Handle client connection/disconnection
if (n_id == server_socket) {
    var t = ds_map_find_value(async_load, "type");
    var sock;

    switch (t) {
        case network_type_connect:
                    var sock = ds_map_find_value(async_load, "socket");
                    ds_list_add(global.connected_clients, sock);
                    show_debug_message("Client connected: " + string(sock));
                    break;
        
                case network_type_disconnect:
                    var sock = ds_map_find_value(async_load, "socket");
                    ds_list_delete(global.connected_clients, sock);
                    show_debug_message("Client disconnected: " + string(sock));
                    break;

        case network_type_data:
            sock = ds_map_find_value(async_load, "id");

            // ✅ Ensure that the buffer exists before reading
            if (ds_map_exists(async_load, "buffer")) {
                var t_buffer = ds_map_find_value(async_load, "buffer");

                if (buffer_exists(t_buffer)) {
                    var cmd_type = buffer_read(t_buffer, buffer_u16);

                    switch (cmd_type) {
                        case 0:  // CMD: Message
                            var result = buffer_read(t_buffer, buffer_string);
                            message = string(message) + "\n" + string(result);
                            break;

                        case 1:  // CMD: Player Input (example)
                            var _player_id = buffer_read(t_buffer, buffer_u8);
                            var input_data = buffer_read(t_buffer, buffer_u8);
                            // Handle player input here
                            break;
                    }
                }
            }
            break;
    }
}







