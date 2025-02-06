/// @description

/// @desc Generate Unique Lobby Code
server_code = generate_lobby_code();
server_socket = network_create_socket(network_socket_udp);
server_port = 6500; // Choose a port

if (server_socket < 0) {
    show_message("Failed to create server socket!");
    instance_destroy();
}

global.connected_clients = ds_map_create(); // Stores connected clients
global.lobbies = ds_map_create(); // Store active lobbies

// ✅ Register the lobby with the generated code
ds_map_add(global.lobbies, server_code, server_port);
show_message("Lobby Code: " + server_code);
