/// @desc Handle Lobby Code Requests
var _id = network_receive(server_socket);
if (_id > 0) {
    var client_ip = async_load[? "ip"];
    var client_port = async_load[? "port"];
    var data = buffer_read(async_load[? "buffer"], buffer_string);
    
    var parts = string_split(data, " ");
    var command = parts[0];
    
    if (command == "join") {
        var code = parts[1];
        
        if (ds_map_exists(global.lobbies, code)) {
            var found_port = ds_map_find_value(global.lobbies, code);
            
            // ✅ Send back server info
            var response = buffer_create(256, buffer_fixed, 1);
            buffer_write(response, buffer_string, string(found_port));
            network_send_udp(server_socket, client_ip, client_port, response, buffer_tell(response));
            buffer_delete(response);
            
            
        }
    }
}
