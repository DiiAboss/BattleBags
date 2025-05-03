/// @description Draw text using clay alphabet sprites
/// @param {string} text - The text to draw
/// @param {real} x - X position
/// @param {real} y - Y position
/// @param {real} spacing - Spacing between characters (optional)
/// @param {real} scale - Scale factor (optional)
function draw_clay_text(text, x, y, spacing = 2, scale = 1) {
    var str = string_upper(text);
    var len = string_length(str);
    var current_x = x;
    
    for (var i = 0; i < len; i++) {
        var char = string_char_at(str, i + 1);
        var _sprite_index = -1;
        
        // Map character to sprite index
        if (char >= "0" && char <= "9") {
            _sprite_index = real(char); // 0-9 are indices 0-9
        }
        else if (char == "(") _sprite_index = 10;
        else if (char == "+") _sprite_index = 11;
        else if (char == "-") _sprite_index = 12;
        else if (char == "=") _sprite_index = 13;
        else if (char == ")") _sprite_index = 14;
        else if (char >= "A" && char <= "Z") {
            _sprite_index = ord(char) - ord("A") + 15; // A-Z are indices 15-40
        }
        else if (char == ",") _sprite_index = 41;
        else if (char == "!") _sprite_index = 42;
        else if (char == ".") _sprite_index = 43;
        else if (char == "$") _sprite_index = 44;
        
        // Draw the character if we have a valid sprite index
        if (_sprite_index != -1) {
            draw_sprite_ext(spr_clay_alphabet, _sprite_index, current_x, y, scale, scale, 0, c_white, 1);
            current_x += (sprite_get_width(spr_clay_alphabet) * scale) + spacing;
        }
        // Handle spaces
        else if (char == " ") {
            current_x += sprite_get_width(spr_clay_alphabet) * 0.5 * scale;
        }
        // Skip unknown characters
        else {
            current_x += sprite_get_width(spr_clay_alphabet) * 0.3 * scale;
        }
    }
    
    return current_x - x; // Return the width of the text drawn
}

/// @description Draw text with smooth wave effect
/// @param {string} text - The text to draw
/// @param {real} x - X position
/// @param {real} y - Y position
/// @param {real} wave_height - Height of the wave (optional)
/// @param {real} wave_speed - Speed of the wave animation (optional)
/// @param {real} spacing - Spacing between characters (optional)
/// @param {real} scale - Scale factor (optional)

function draw_clay_text_wave(text, x, y, wave_height = 5, wave_speed = 2, spacing = 2, scale = 1) {
    var str = string_upper(text);
    var len = string_length(str);
    var current_x = x;
    
    for (var i = 0; i < len; i++) {
        var char = string_char_at(str, i + 1);
        var char_index = -1;
        
        // Map character to sprite index
        if (char >= "0" && char <= "9") {
            char_index = real(char); // 0-9 are indices 0-9
        }
        else if (char == "(") char_index = 10;
        else if (char == "+") char_index = 11;
        else if (char == "-") char_index = 12;
        else if (char == "=") char_index = 13;
        else if (char == ")") char_index = 14;
        else if (char >= "A" && char <= "Z") {
            char_index = ord(char) - ord("A") + 15; // A-Z are indices 15-40
        }
        else if (char == ",") char_index = 41;
        else if (char == "!") char_index = 42;
        else if (char == ".") char_index = 43;
        else if (char == "$") char_index = 44;
        
        // Calculate wave offset for this character
        // Each character is slightly offset in the wave to create a smooth wave effect
        var wave_offset = sin((current_time / 60 * wave_speed) + (i * 0.3)) * wave_height;
        
        // Draw the character if we have a valid sprite index
        if (char_index != -1) {
            draw_sprite_ext(spr_clay_alphabet, char_index, current_x, y + wave_offset, scale, scale, 0, c_white, 1);
            current_x += (sprite_get_width(spr_clay_alphabet) * scale) + spacing;
        }
        // Handle spaces
        else if (char == " ") {
            current_x += sprite_get_width(spr_clay_alphabet) * 0.5 * scale;
        }
        // Skip unknown characters
        else {
            current_x += sprite_get_width(spr_clay_alphabet) * 0.3 * scale;
        }
    }
    
    return current_x - x; // Return the width of the text drawn
}

/// @description Draw text with random/unhinged wave effect
/// @param {string} text - The text to draw
/// @param {real} x - X position
/// @param {real} y - Y position
/// @param {real} spacing - Spacing between characters (optional)
/// @param {real} scale - Scale factor (optional)
/// @param {real} chaos_level - How unhinged the text should appear (optional)
function draw_clay_text_unhinged(text, x, y, spacing = 2, scale = 1, chaos_level = 3) {
    var str = string_upper(text);
    var len = string_length(str);
    var current_x = x;
    
    // Get current time for animation
    var time = current_time / 60;
    
    for (var i = 0; i < len; i++) {
        var char = string_char_at(str, i + 1);
        var char_index = -1;
        
        // Map character to sprite index
        if (char >= "0" && char <= "9") {
            char_index = real(char); // 0-9 are indices 0-9
        }
        else if (char == "(") char_index = 10;
        else if (char == "+") char_index = 11;
        else if (char == "-") char_index = 12;
        else if (char == "=") char_index = 13;
        else if (char == ")") char_index = 14;
        else if (char >= "A" && char <= "Z") {
            char_index = ord(char) - ord("A") + 15; // A-Z are indices 15-40
        }
        else if (char == ",") char_index = 41;
        else if (char == "!") char_index = 42;
        else if (char == ".") char_index = 43;
        else if (char == "$") char_index = 44;
        
        // Calculate unhinged effects
        // Creates a combination of different oscillations for a chaotic movement
        // Each character has a unique seed based on its position
        var char_seed = i * 100;
        
        // Vertical movement (up/down)
        var y_offset = sin(time * 3 + char_seed) * chaos_level;
        y_offset += cos(time * 1.7 + char_seed * 0.25) * (chaos_level * 0.7);
        
        // Rotation (slight wobble)
        var rotation = sin(time * 2.3 + char_seed * 0.5) * (chaos_level * 2);
        
        // Scale fluctuation (pulsing)
        var scale_mod = 1 + (sin(time * 1.4 + char_seed * 0.33) * 0.1 * chaos_level);
        var final_scale = scale * scale_mod;
        
        // Draw the character if we have a valid sprite index
        if (char_index != -1) {
            draw_sprite_ext(spr_clay_alphabet, char_index, current_x, y + y_offset, 
                           final_scale, final_scale, rotation, c_white, 1);
            current_x += (sprite_get_width(spr_clay_alphabet) * scale) + spacing;
        }
        // Handle spaces
        else if (char == " ") {
            current_x += sprite_get_width(spr_clay_alphabet) * 0.5 * scale;
        }
        // Skip unknown characters
        else {
            current_x += sprite_get_width(spr_clay_alphabet) * 0.3 * scale;
        }
    }
    
    return current_x - x; // Return the width of the text drawn
}

// NOTE: In GameMaker, you'll need to define current_game_time somewhere
// You can use a global variable that increments each step:
// 
// Create Event of a controller object:
// global.current_game_time = 0;
// 
// Step Event:
// global.current_game_time += 1;
//
// Then replace "current_game_time" in the functions above with "global.current_game_time"