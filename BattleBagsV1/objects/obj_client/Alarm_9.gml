/// @description

if (not_host_controlled)
{
    // ✅ Connect to the server
    var connection = network_connect_raw(client_socket, server_ip, server_port);
    
    if (connection >= 0) {
        show_message("Client connected to server!");
    } else {
        show_message("Failed to connect to server!");
        instance_destroy();
    }
}