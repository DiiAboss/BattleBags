function process_console_command(cmd)
{
	// Convert input to lowercase for consistency
	cmd = string_lower(cmd);

	// Store in history
	array_insert(console_history, 0, cmd);
	if (array_length(console_history) > max_history) {
	    array_delete(console_history, max_history, 1);
	}

	// 📜 Process Commands
	if (cmd == "clear") {
	    console_history = [];
	} 
	else if (cmd == "showhealth") {
	    array_insert(console_history, 0, "Health: " + string(player_health));
	} 
	else if (string_pos("sethealth ", cmd) == 1) {
	    var value = real(string_delete(cmd, 1, 10)); // Remove "set_health " part
	    if (is_real(value)) {
	        global.player_health = value;
	        array_insert(console_history, 0, "Player health set to: " + string(value));
	    } else {
	        array_insert(console_history, 0, "Invalid value.");
	    }
	} 
	else if (cmd == "showmoney") {
	    array_insert(console_history, 0, "Gold: " + string(global.gold));
	}
	else if (string_pos("setspeed ", cmd) == 1) {
	    var value = real(string_delete(cmd, 1, 10)); 
	    if (is_real(value)) {
	        global.gameSpeed = value;
	        array_insert(console_history, 0, "Game speed set to: " + string(value));
	    }
	}

	else {
	    array_insert(console_history, 0, "Unknown command: " + cmd);
	}
}