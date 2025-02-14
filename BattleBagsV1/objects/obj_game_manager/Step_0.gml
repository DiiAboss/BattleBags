/// @description
// Toggle Console On/Off
if (keyboard_check_pressed(vk_f1)) { 
    console_active = !console_active;
}

// If Console is Active, Process Input
if (console_active) {
    // Handle Backspace
    if (keyboard_check_pressed(vk_backspace)) {
        if (string_length(console_input) > 0) {
            console_input = string_copy(console_input, 1, string_length(console_input) - 1);
        }
    }

    // Handle Enter Key (Execute Command)
    if (keyboard_check_pressed(vk_enter)) {
        process_console_command(console_input);
        console_input = ""; // Clear after execution
    }
    // 🖊 Handle Typing Input (One Character Per Press)
    for (var i = 32; i <= 126; i++) { // ASCII Range for printable characters
        if (keyboard_check_pressed(i)) {
            if (string_length(console_input) < 50) {
                console_input += chr(i); // Convert ASCII code to character
            }
        }
    }
}
