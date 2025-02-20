///// @desc Client Async Network Event
//var n_id = ds_map_find_value(async_load, "id");
//
//if (n_id == client_socket) {
    //var t = ds_map_find_value(async_load, "type");
//
    //switch (t) {
        //case network_type_connect:
            //show_message("Connected to server!");
            //break;
//
        //case network_type_disconnect:
            //show_message("Disconnected from server!");
            //break;
//
        //case network_type_data:
            //var t_buffer = ds_map_find_value(async_load, "buffer");
            //var cmd_type = buffer_read(t_buffer, buffer_u16);
            //show_debug_message("Data received: " + string(cmd_type));
            //break;
    //}
//}

show_debug_message(json_encode(async_load));

// Recieving Data
if (async_load[? "size"] > 0)
{
    var buff = async_load[? "buffer"];
    buffer_seek(buff, buffer_seek_start, 0);
    // Show response string from server
    var response = buffer_read(buff, buffer_string);
    show_debug_message(response);
}



