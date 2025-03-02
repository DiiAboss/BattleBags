//function send_map_over_UDP(sender, data_map, data_type, size = 100)
//{
    //var ip     = sender.server_ip;
    //var port   = sender.server_port;
    //var client = sender.client_socket;
    //
    //network_connect_raw(client, ip, port);
    //var buffer = buffer_create(size, buffer_fixed, size);
    //
    //ds_map_add(data_map, "type", data_type)
    //var data_json = json_encode(data_map);
    //show_debug_message("> " + string(data_json));
    //ds_map_destroy(data_map);
    //
    //buffer_seek(client, buffer_seek_start, 0);
    //buffer_write(client, buffer_text, data_json);
    //network_send_udp_raw(client, ip, port, client, buffer_tell(client));
//}

/// @function send_map_over_UDP
/// @param {id} sender - The sender object (usually self)
/// @param {ds_map} data_map - The data to send
/// @param {constant} message_type - The message type (from DATA_TYPE enum)
/// @param {real} retry_count - Number of retry attempts if sending fails
function send_map_over_UDP(sender, data_map, message_type, retry_count = 3) {
    ds_map_add(data_map, "type", message_type);
    ds_map_add(data_map, "player_id", obj_connection_manager.player_idd);
    
    if (obj_connection_manager.lobby_id != "") {
        ds_map_add(data_map, "lobbyId", obj_connection_manager.lobby_id);
    }
    
    var buffer = buffer_create(1024, buffer_fixed, 1);
    var json_string = json_encode(data_map);
    buffer_write(buffer, buffer_string, json_string);
    
    // Send message to server
    var success = network_send_udp_raw(
        obj_connection_manager.client_socket,
        obj_connection_manager.server_ip,
        obj_connection_manager.server_port,
        buffer_get_address(buffer),
        buffer_tell(buffer)
    );
    
    buffer_delete(buffer);
    ds_map_destroy(data_map);
    
    return success;
}

/// @function process_network_message
/// @param {string} message - JSON message string from server
/// @desc Processes an incoming network message
function process_network_message(message) {
    var json_resp = json_decode(message);
    
    if (json_resp == -1) {
        show_debug_message("Failed to decode JSON message");
        return;
    }
    
    var data_type = ds_map_find_value(json_resp, "type");
    
    switch(data_type) {
        case DATA_TYPE.CREATE_HOST:
            // Host created successfully
            obj_connection_manager.host_number = ds_map_find_value(json_resp, "host_number");
            obj_connection_manager.player_number = ds_map_find_value(json_resp, "player_number");
            obj_connection_manager.connection_state = CONNECTION_STATE.IN_LOBBY;
            show_debug_message("Created host #" + string(obj_connection_manager.host_number));
            break;
            
        case DATA_TYPE.GET_HOSTS:
            // Received list of available hosts
            var hosts = ds_map_find_value(json_resp, "hosts");
            ds_list_copy(obj_connection_manager.hosts_list, hosts);
            show_debug_message("Received " + string(ds_list_size(obj_connection_manager.hosts_list)) + " hosts");
            break;
            
        // Add cases for all other message types...
    }
}