/// @desc Client Async Network Event
var n_id = ds_map_find_value(async_load, "id");

if (n_id == client_socket) {
    var t = ds_map_find_value(async_load, "type");

    switch (t) {
        case network_type_connect:
            show_message("Connected to server!");
            break;

        case network_type_disconnect:
            show_message("Disconnected from server!");
            break;

        case network_type_data:
            var t_buffer = ds_map_find_value(async_load, "buffer");
            var cmd_type = buffer_read(t_buffer, buffer_u16);
            show_debug_message("Data received: " + string(cmd_type));
            break;
    }
}





