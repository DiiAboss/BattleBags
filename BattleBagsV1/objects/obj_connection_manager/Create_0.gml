/// @description
// obj_network_manager (Create Event)
enum PLAYER_ROLE {
    NONE,
    CLIENT,
    HOST
}

enum CONNECTION_STATE {
    DISCONNECTED,
    CONNECTING,
    CONNECTED,
    IN_LOBBY,
    IN_GAME
}

// Network properties
player_role = PLAYER_ROLE.NONE;
connection_state = CONNECTION_STATE.DISCONNECTED;
client_socket = undefined;
server_ip = "127.0.0.1";
server_port = 7676;

// Player identification
player_idd = irandom_range(1, 99999);
player_number = -1;
host_number = -1;

// Lobbies and matchmaking
lobby_id = "";
hosts_list = ds_list_create();
connected_players = ds_list_create();

// Heartbeat system
last_heartbeat_time = current_time;
heartbeat_interval = 3000; // Send heartbeat every 3 seconds

// Make this object persistent
persistent = true;


// Initialize connection variables
connection_state = CONNECTION_STATE.DISCONNECTED;
retry_count = 0;
max_retries = 5;
retry_interval = 5000; // 5 seconds

// Initialize player data
player_name = "";
player_rating = 1200; // Default ELO rating

// UI variables
connection_message = "Disconnected";
show_connection_status = true;



