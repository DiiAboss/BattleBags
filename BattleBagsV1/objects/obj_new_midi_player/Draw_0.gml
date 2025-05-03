/// @description Draw the game
// Draw the rhythm game
rhythm_game.Draw();

// Draw song selector (this will only draw if it's visible)
song_selector.Draw();

// Draw countdown timer if active
if (midi_player.IsCountdownActive()) {
    // Draw large countdown number
    var remain = ceil(midi_player.GetCountdownTime());
    if (remain > 0) {
        draw_set_font(-1); // Replace with your font for countdown
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_yellow);
        
        // Draw with pulsing effect
        var scale = 2.5 + sin(current_time/100) * 0.5;
        draw_text_transformed(room_width/2, room_height/2, string(remain), scale, scale, 0);
        
        // Draw "GET READY!" text above
        draw_set_color(c_white);
        draw_text_transformed(room_width/2, room_height/2 - 80, "GET READY!", 1.5, 1.5, 0);
    }
}

// Only draw MIDI player UI and instructions if GUI is not visible
if (!gui_state.visible) {
    // Draw the MIDI player UI
    midi_player.Draw();
    
    // Draw game instructions
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text(10, 220, "--- Playback Controls ---");
draw_text(10, 240, "1-4: Toggle tracks 1-4");
draw_text(10, 260, "M: Toggle mute for active track");
draw_text(10, 280, "Space: Play/pause active track");
draw_text(10, 300, "P: Toggle player visibility");
draw_text(10, 320, "A: Play all tracks");
draw_text(10, 340, "S: Stop all tracks");
draw_text(10, 360, "Left/Right: Change active track");

draw_text(10, 380, "--- Game Controls ---");
draw_text(10, 400, "Q-T: Select track to play");
draw_text(10, 420, "F1-F4: Set difficulty");
draw_text(10, 440, "Z, X, C, V: Hit notes");
draw_text(10, 460, "R: Restart game");

// Draw difficulty and active track info in different colors
draw_set_halign(fa_center);
draw_set_color(c_lime);
draw_text(room_width / 2, room_height - 60, "Current Difficulty: " + midi_player.difficulty_names[midi_player.difficulty]);

// Only show "press space" message if not playing
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
    
    draw_text(room_width / 2, room_height - 30, "Press SPACE to play music");
}
	} 

// Always draw the GUI on top (it handles its own visibility)
DrawGUI();



