/// @description
midi_player.Clean();

/// @function RestartGame()
/// @description Restart the rhythm game
function RestartGame() {
    // Stop all playback
    midi_player.StopAll();
    
    // Create a new rhythm game instance (resets all scores and effects)
    rhythm_game = new Rhythm_Game(midi_player);
    
    // Optionally seek all files to the beginning
    for (var i = 0; i < array_length(midi_player.midi_files); i++) {
        midi_player.SeekFile(i, 0);
    }
}
RestartGame();