/// @desc Receive Server Info & Connect
var _id = network_receive(client_socket);
if (_id > 0) {
    var server_info = buffer_read(async_load[? "buffer"], buffer_string);
    
    if (string_length(server_info) > 0) {
        server_port = real(server_info);
        show_message("Connecting to server on port: " + string(server_port));
        
        var buffer = buffer_create(256, buffer_fixed, 1);
        buffer_write(buffer, buffer_string, "connect");
        network_send_udp(client_socket, "127.0.0.1", server_port, buffer, buffer_tell(buffer));
        buffer_delete(buffer);
    }
}

