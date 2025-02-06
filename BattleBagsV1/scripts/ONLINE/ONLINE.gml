function generate_lobby_code() {
    var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    var numbers = "0123456789";
    
    var code = "";
    for (var i = 0; i < 3; i++) {
        code += string(letters[irandom(25)]); // Pick a random letter
    }
    for (var i = 0; i < 3; i++) {
        code += string(numbers[irandom(9)]); // Pick a random number
    }
    return code;
}


function generate_player_id()
{
/// @desc Load or Create Player Profile
if (file_exists("player_profile.sav")) {
    var file = file_text_open_read("player_profile.sav");
    global.player_name = file_text_read_string(file);
    global.player_id = file_text_read_string(file);
    file_text_close(file);
}
else {
    global.player_name = get_string("Enter Your Name:", ""); // User enters a name
    global.player_name = string_replace_all(global.player_name, "#", ""); // Remove invalid character
    global.player_id = generate_unique_hashtag(global.player_name);
    
    var file = file_text_open_write("player_profile.sav");
    file_text_write_string(file, global.player_name + "\n");
    file_text_write_string(file, global.player_id);
    file_text_close(file);
}

show_message("Welcome, " + global.player_name + "!");

}


function generate_unique_hashtag(_name) {
    var base_name = _name;
    var unique_id = irandom_range(1000, 9999); // Random 4-digit number
    
    var final_name = base_name + "#" + string(unique_id);
    
    // Ensure uniqueness (this checks a server database in online mode)
    while (is_name_taken(final_name)) {
        unique_id = irandom_range(1000, 9999);
        final_name = base_name + "#" + string(unique_id);
    }
    
    return final_name;
}


function is_name_taken(_full_name) {
    if (server_mode) {
        // Online check: Query existing player database
        var buffer = buffer_create(256, buffer_fixed, 1);
        buffer_write(buffer, buffer_string, "check_name " + _full_name);
        network_send_udp(client_socket, "127.0.0.1", 6500, buffer, buffer_tell(buffer));
        buffer_delete(buffer);
    }
    else {
        // Local check: Simulate always unique in offline mode
        return false;
    }
}

function send_udp_message(_message) {
    var buffer = buffer_create(256, buffer_fixed, 1);
    buffer_write(buffer, buffer_string, _message);
    
    // ✅ Correctly send UDP packet (includes buffer size)
    network_send_udp(global.client_socket, "127.0.0.1", 6500, buffer, buffer_tell(buffer));

    buffer_delete(buffer);
}

function send_udp_response(_client_ip, _client_port, _message) {
    var buffer = buffer_create(256, buffer_fixed, 1);
    buffer_write(buffer, buffer_string, _message);

    // ✅ Corrected UDP syntax with buffer size
    network_send_udp(global.server_socket, _client_ip, _client_port, buffer, buffer_tell(buffer));

    buffer_delete(buffer);
}

function draw_player_id()
{
	/// @desc Draw Player Name (Without Hashtag)
	var display_name = string_copy(global.player_id, 1, string_pos("#", global.player_id) - 1);
	draw_text(x, y - 32, display_name); // Only show "Dillon" instead of "Dillon#3271"
}

function generate_unique_id() {
    var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    var numbers = "0123456789";
    
    var _id = "";
    for (var i = 0; i < 3; i++) {
        _id += string(letters[irandom(25)]);
    }
    for (var i = 0; i < 3; i++) {
        _id += string(numbers[irandom(9)]);
    }
    return _id;
}
