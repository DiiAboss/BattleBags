/// STEP EVENT
/// @description Update game logic
midi_player.Update();

// Ensure drum tracks stay in sync when playing drums
if (midi_player.game_track == 3) {
    // Check if any drum track is playing but others are not
    var any_drum_playing = false;
    var all_drums_playing = true;
    var drum_tracks = [3, 4, 5];
    
    for (var i = 0; i < array_length(drum_tracks); i++) {
        var drum_track = drum_tracks[i];
        
        // Skip if this track doesn't exist
        if (drum_track >= array_length(midi_player.midi_files)) {
            continue;
        }
        
        if (midi_player.midi_files[drum_track].is_playing) {
            any_drum_playing = true;
        } else {
            all_drums_playing = false;
        }
    }
    
    // If some drums are playing but not all, start all of them
    if (any_drum_playing && !all_drums_playing) {
        PlayAllDrumTracks();
    }
}

// Only update rhythm game if GUI is not visible
if (!gui_state.visible) {
    rhythm_game.Update();
    
    // Handle keyboard shortcuts
    // 1-6: Toggle playback of tracks 1-6
    if (keyboard_check_pressed(ord("1"))) {
        midi_player.TogglePlayback(0);
    }
    if (keyboard_check_pressed(ord("2")) && array_length(midi_player.midi_files) > 1) {
        midi_player.TogglePlayback(1);
    }
    if (keyboard_check_pressed(ord("3")) && array_length(midi_player.midi_files) > 2) {
        midi_player.TogglePlayback(2);
    }
    if (keyboard_check_pressed(ord("4")) && array_length(midi_player.midi_files) > 3) {
        midi_player.TogglePlayback(3);
    }
    if (keyboard_check_pressed(ord("5")) && array_length(midi_player.midi_files) > 4) {
        midi_player.TogglePlayback(4);
    }
    if (keyboard_check_pressed(ord("6")) && array_length(midi_player.midi_files) > 5) {
        midi_player.TogglePlayback(5);
    }

    // Q-U: Set active track for gameplay
    if (keyboard_check_pressed(ord("Q"))) {
        midi_player.SetGameTrack(0); // Bass
        gui_state.selected_instrument = 0;
        RestartGame();
    }
    if (keyboard_check_pressed(ord("W")) && array_length(midi_player.midi_files) > 1) {
        midi_player.SetGameTrack(1); // Vocals
        gui_state.selected_instrument = 1;
        RestartGame();
    }
    if (keyboard_check_pressed(ord("E")) && array_length(midi_player.midi_files) > 2) {
        midi_player.SetGameTrack(2); // Leads
        gui_state.selected_instrument = 2;
        RestartGame();
    }
    if (keyboard_check_pressed(ord("T"))) {
        // For drums, we set the game track to 3 (kick drum) but handle all drum tracks
        midi_player.SetGameTrack(3); // Drums
        gui_state.selected_instrument = 3;
        PlayAllDrumTracks(); // Ensure all drum tracks are playing
        RestartGame();
    }

    // Difficulty settings
    if (keyboard_check_pressed(ord("F1"))) {
        midi_player.SetDifficulty(0); // Easy
        gui_state.selected_difficulty = 0;
        RestartGame();
    }
    if (keyboard_check_pressed(ord("F2"))) {
        midi_player.SetDifficulty(1); // Medium
        gui_state.selected_difficulty = 1;
        RestartGame();
    }
    if (keyboard_check_pressed(ord("F3"))) {
        midi_player.SetDifficulty(2); // Hard
        gui_state.selected_difficulty = 2;
        RestartGame();
    }
    if (keyboard_check_pressed(ord("F4"))) {
        midi_player.SetDifficulty(3); // Expert
        gui_state.selected_difficulty = 3;
        RestartGame();
    }

    // Other controls
    if (keyboard_check_pressed(ord("M"))) {
        midi_player.ToggleMute(midi_player.active_file);
    }

    if (keyboard_check_pressed(vk_space)) {
        midi_player.TogglePlayback(midi_player.active_file);
    }

    if (keyboard_check_pressed(ord("P"))) {
        midi_player.TogglePlayer();
    }

    if (keyboard_check_pressed(ord("A"))) {
        midi_player.PlayAll();
    }

    if (keyboard_check_pressed(ord("S"))) {
        midi_player.StopAll();
    }

    if (keyboard_check_pressed(ord("R"))) {
        RestartGame();
    }

    // Navigate between tracks
    if (keyboard_check_pressed(vk_left) && midi_player.active_file > 0) {
        midi_player.SetActiveFile(midi_player.active_file - 1);
    }

    if (keyboard_check_pressed(vk_right) && midi_player.active_file < array_length(midi_player.midi_files) - 1) {
        midi_player.SetActiveFile(midi_player.active_file + 1);
    }
} else {
    // If GUI is visible, we still update animations but not gameplay
    rhythm_game.UpdateEffects();
}

// Always check for ESC to toggle GUI
if (keyboard_check_pressed(vk_escape)) {
    ToggleGUI();
}