/// @desc Initialize Server
server_port = 7676;  // Port to listen on
max_clients = 4;     // Maximum number of clients allowed

// ✅ Create the server socket
server_socket = network_create_server(network_socket_udp, server_port, max_clients);

// ✅ Validate server creation
if (server_socket >= 0) {
    show_message("Server started! Listening on port: " + string(server_port));
} else {
    show_message("Server could not be started!");
    instance_destroy();
}

// ✅ Initialize global data
global.connected_clients = ds_list_create(); // Store connected player sockets
message = "";
