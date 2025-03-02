/// @description
// Connection function
function connect_to_server() {
    connection_state = CONNECTION_STATE.CONNECTING;
    connection_message = "Connecting...";
    
    // Create the client object to handle network communication
    if (!instance_exists(obj_client)) {
        instance_create_layer(0, 0, "Instances", obj_client);
    }
}

// Step Event
// Connection retry logic
if (connection_state == CONNECTION_STATE.CONNECTING) {
    if (!instance_exists(obj_client)) {
        retry_count++;
        
        if (retry_count < max_retries) {
            connection_message = "Connection failed. Retrying... (" + string(retry_count) + "/" + string(max_retries) + ")";
            connect_to_server();
        } else {
            connection_state = CONNECTION_STATE.DISCONNECTED;
            connection_message = "Connection failed after " + string(max_retries) + " attempts.";
        }
    }
}