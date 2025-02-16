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


function process_console(game_manager, console_active)
{
    if !(console_active) return;

    // Handle Backspace
    if (keyboard_check_pressed(vk_backspace)) {
        if (string_length(game_manager.console_input) > 0) {
            game_manager.console_input = string_copy(game_manager.console_input, 1, string_length(game_manager.console_input) - 1);
        }
    }

    // Handle Enter Key (Execute Command)
    if (keyboard_check_pressed(vk_enter)) {
        process_console_command(game_manager.console_input);
        game_manager.console_input = ""; // Clear after execution
    }
    // 🖊 Handle Typing Input (One Character Per Press)
    for (var i = 32; i <= 126; i++) { // ASCII Range for printable characters
        if (keyboard_check_pressed(i)) {
            if (string_length(game_manager.console_input) < 50) {
                game_manager.console_input += chr(i); // Convert ASCII code to character
            }
        }
    }
}

function draw_console(game_manager, console_active)
{
    if !(console_active) return;
        
    var console_alpha = game_manager.console_alpha;
    var console_x = game_manager.console_x;
    var console_y = game_manager.console_y;
    var console_width = game_manager.console_width;
    var console_height = game_manager.console_height;
    var draw_y_start   = game_manager.draw_y_start;
    var max_history = game_manager.max_history;
    var console_history = game_manager.console_history;
    
    draw_set_alpha(console_alpha);
    draw_set_color(c_white);
    draw_rectangle(console_x, console_y, console_x + console_width, console_y + console_height, false);
    draw_set_alpha(1);

    // Draw Console Text
    draw_set_color(c_black);
    //draw_set_font(console_font);
    draw_text(console_x + 10, draw_y_start + console_y + 10, "> " + game_manager.console_input);

    // Draw Command History
    for (var i = 0; i < min(array_length(console_history), max_history); i++) {
        draw_text(console_x + 10, draw_y_start + console_y + 30 + (i * 20), console_history[i]);
    }
}