/// @description
midi_player = new Midi_Player(snd_piano_note, 10, 10, 400, 200);
file1 = midi_player.AddMidiFile("simplified_midi_data.json");

midi_player.SetActiveFile(0);

// Create the rhythm game instance
rhythm_game = new Rhythm_Game(midi_player);

// Add keyboard shortcuts
// 1-3: Toggle playback of tracks 1-3
// M: Toggle mute of active track
// Space: Play/pause active track
// P: Toggle player visibility
// A: Play all tracks
// S: Stop all tracks
// R: Restart the game