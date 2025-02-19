/// @desc Handle Server Messages
var _id = async_load[? "id"];
if (_id != client_socket) exit; // Ignore unrelated sockets

var data = buffer_read(async_load[? "buffer"], buffer_string);
var parts = string_split(data, " ");
var command = parts[0];

if (command == "connect") {
    server_port = real(parts[1]);
    my_player_id = real(parts[2]);
    show_message("Connected! Your ID: " + string(my_player_id));
}

// ✅ Process Game State Updates
if (command == "sync") {
    var _player_id = real(parts[1]);
    var new_y_offset = real(parts[2]);

    // ✅ Apply Updates Only for Our Player
    if (_player_id == my_player_id) {
        global_y_offset = new_y_offset;
    }
}

// ✅ Start Game when Server Sends `"start_game"`
if (command == "start_game") {
    show_message("Game Starting...");
    room_goto(rm_online_game);
}


