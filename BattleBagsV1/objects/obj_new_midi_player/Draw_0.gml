/// @description

    // Draw the rhythm game
    rhythm_game.Draw();
midi_player.Draw();

// Draw game instructions
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_text(10, 220, "1-3: Toggle tracks 1-3");
    draw_text(10, 240, "M: Toggle mute for active track");
    draw_text(10, 260, "Space: Play/pause active track");
    draw_text(10, 280, "P: Toggle player visibility");
    draw_text(10, 300, "A: Play all tracks");
    draw_text(10, 320, "S: Stop all tracks");
    draw_text(10, 340, "Left/Right: Change active track");
    
 // Draw game instructions (only if not playing)
    var any_playing = false;
    for (var i = 0; i < array_length(midi_player.midi_files); i++) {
        if (midi_player.midi_files[i].is_playing) {
            any_playing = true;
            break;
        }
    }
    
    if (!any_playing) {
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        draw_text(room_width / 2, room_height - 70, "Press SPACE to play music");
        draw_text(room_width / 2, room_height - 50, "Z, X, C, V to hit notes");
        draw_text(room_width / 2, room_height - 30, "R to restart the game");
    }

