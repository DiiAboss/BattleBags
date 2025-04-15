/// @description
midi_player.Update();

rhythm_game.Update();

// Handle keyboard shortcuts
    if (keyboard_check_pressed(ord("1"))) {
        midi_player.TogglePlayback(0);
    }
    
    if (keyboard_check_pressed(ord("2")) && array_length(midi_player.midi_files) > 1) {
        midi_player.TogglePlayback(1);
    }
    
    if (keyboard_check_pressed(ord("3")) && array_length(midi_player.midi_files) > 2) {
        midi_player.TogglePlayback(2);
    }
    
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
    
