/// @description
var network_event = async_load[? "type"];

if (network_event == network_type_data) {
    // Only process data if we have a valid size
    if (async_load[? "size"] > 0) {
        var buff = async_load[? "buffer"];
        buffer_seek(buff, buffer_seek_start, 0);
        var msg = buffer_read(buff, buffer_string);
        
        // Process the incoming message
        process_network_message(msg);
    }
}

// Add heartbeat in Step Event
if (connection_state != CONNECTION_STATE.DISCONNECTED) {
    if (current_time - last_heartbeat_time > heartbeat_interval) {
        last_heartbeat_time = current_time;
        
        var data = ds_map_create();
        send_map_over_UDP(self, data, DATA_TYPE.HEARTBEAT);
    }
}