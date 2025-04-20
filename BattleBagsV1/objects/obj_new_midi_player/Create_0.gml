/// CREATE EVENT
/// @description Initialize MIDI player and rhythm game
// Create array of sounds for different tracks
var sounds = [
    snd_ta_note_C,  // Bass sound
    snd_ta_note_C,  // Vocals sound
    snd_hiC, // Leads sound 
    snd_low_bow,     // Drums_Kick
    snd_snare_1,    // Drums_Snare
    snd_hihat_2    // Drums_Cymbal
];

// Create enhanced MIDI player with multiple sounds
midi_player = new Midi_Player(sounds, 10, 10, 400, 200);

// Add MIDI files with track type parameter
file1 = midi_player.AddMidiFile("My Generated Music_BASS_game.json", 0);    // Bass - track type 0
file2 = midi_player.AddMidiFile("My Generated Music_CHORDS_game.json", 1);  // Vocals - track type 1
file3 = midi_player.AddMidiFile("My Generated Music_LEADS_game.json", 2);   // Leads - track type 2
file4 = midi_player.AddMidiFile("mario.json", 3);   // Drums Kick - track type 3
file5 = midi_player.AddMidiFile("mario.json", 4);  // Drums Snare - track type 4
file6 = midi_player.AddMidiFile("mario.json", 5); // Drums Cymbals - track type 5

	midi_player.SetTrackPitchShift(3, false); // Kick
	midi_player.SetTrackPitchShift(4, false); // Snare
	midi_player.SetTrackPitchShift(5, false); // Cymbals
	midi_player.SetTrackPitchShift(6, true);  // Other (allow pitch modulation)

// Set default active file
midi_player.SetActiveFile(0);

// Set game track (which track the player needs to play)
midi_player.SetGameTrack(3); // Default to drums track (kick drum)

// Set difficulty (0=Easy, 1=Medium, 2=Hard, 3=Expert)
midi_player.SetDifficulty(1); // Default to Medium


// ----- SETUP SONG MANAGER -----
// Create song manager
song_manager = new Song_Manager();

// Create Mario song collection
var mario_song = new Song_Collection("Bossa", {
    artist: "",
    genre: "",
    bpm: 120
});

// Set file paths for each instrument track
mario_song.SetFilePath("bass", "Bossa_Bass.json", 1); // Medium difficulty
mario_song.SetFilePath("leads", "Bossa_Instro.json", 1); // Medium difficulty
mario_song.SetFilePath("vocals", "Bossa_Vocals.json", 1); // Medium difficulty
// Add more tracks if available

// Add the song to the manager
song_manager.AddSong(mario_song);


// Create Country song collection
var country_song = new Song_Collection("Country Jam", {
    artist: "Country Band",
    genre: "Country",
    bpm: 100
});

// Set file paths for each instrument track
country_song.SetFilePath("bass", "Country_Bass.json", 1);       // Medium difficulty
country_song.SetFilePath("leads", "Country_Instro.json", 2);    // Hard difficulty
country_song.SetFilePath("drums_kick", "Country_Kick.json", 1); // Medium difficulty
country_song.SetFilePath("drums_snare", "Country_Snare.json", 1); // Medium difficulty
country_song.SetFilePath("drums_cymbals", "Country_Cymbals.json", 2); // Hard difficulty

// Add the song to the manager
song_manager.AddSong(country_song);




LoadAndAddSongsFromSingleJSON(song_manager, "datafiles/songs.json");

// Create the rhythm game instance
rhythm_game = new Rhythm_Game(midi_player);

// Create song selector
song_selector = new Song_Selector(song_manager, midi_player, rhythm_game);

/// @function LoadSongsFromSingleJSON(file_path)
/// @description Loads all song collections from a single JSON file
/// @param {string} file_path - Path to the songs JSON file
/// @returns {array<struct>} Array of loaded Song_Collection objects
function LoadSongsFromSingleJSON(file_path) {
    var songs = [];
    
    if (!file_exists(file_path)) {
        show_debug_message("Songs JSON file not found: " + file_path);
        return songs;
    }
    
    // Read the JSON file
    var file = file_text_open_read(file_path);
    var json_string = "";
    
    while (!file_text_eof(file)) {
        json_string += file_text_read_string(file);
        file_text_readln(file);
    }
    
    file_text_close(file);
    
    // Parse the JSON
    var json_data = json_parse(json_string);
    
    // Check if it has the songs array
    if (!variable_struct_exists(json_data, "songs")) {
        show_debug_message("Invalid songs JSON format: missing 'songs' array");
        return songs;
    }
    
    // Process each song in the array
    var song_array = json_data.songs;
    for (var i = 0; i < array_length(song_array); i++) {
        var song_data = song_array[i];
        
        // Create a new song collection
        var song = new Song_Collection(song_data.name, song_data.metadata);
        
        // Set file paths for each track
        var tracks = song_data.tracks;
        
        struct_foreach(tracks, function(track_name, track_data) {
            if (track_data.file != "") {
                self.SetFilePath(track_name, track_data.file, track_data.difficulty);
            }
        });
        
        // Add to our collection
        array_push(songs, song);
        show_debug_message("Loaded song: " + song.name);
    }
    
    return songs;
}

/// @function LoadAndAddSongsFromSingleJSON(song_manager, file_path)
/// @description Loads songs from a single JSON file and adds them to the song manager
/// @param {struct} song_manager - The song manager to add songs to
/// @param {string} file_path - Path to the songs JSON file
/// @returns {real} Number of songs loaded
function LoadAndAddSongsFromSingleJSON(song_manager, file_path) {
    var songs = LoadSongsFromSingleJSON(file_path);
    var count = 0;
    
    for (var i = 0; i < array_length(songs); i++) {
        song_manager.AddSong(songs[i]);
        count++;
    }
    
    show_debug_message("Loaded " + string(count) + " songs from " + file_path);
    return count;
}

// Start all tracks playing by default
//PlayAllTracksOnStart();


// GUI State variables
gui_state = {
    visible: false,             // Whether the GUI is currently visible
    selected_instrument: 3,     // Default selected instrument (3 = Drums)
    selected_difficulty: 1,     // Default difficulty (1 = Medium)
    button_width: 180,
    button_height: 40,
    padding: 10,
    animation: 0,               // Animation value for smooth transitions
    hover_button: -1,           // Currently hovered button
    was_playing: false          // Track if music was playing when GUI opened
};
// Instrument options (simplified to combine the drums)
instruments = [
    { name: "Bass", track: 0 },
    { name: "Vocals", track: 1 },
    { name: "Leads", track: 2 },
    { name: "Drums", track: 3 }  // All drums tracks combined as one instrument
];

// Difficulty options
difficulties = [
    { name: "Easy", level: 0 },
    { name: "Medium", level: 1 },
    { name: "Hard", level: 2 },
    { name: "Expert", level: 3 }
];



/// @function ToggleGUI()
/// @description Show or hide the settings GUI
function ToggleGUI() {
    gui_state.visible = !gui_state.visible;
    
    // Store current playback state when opening GUI
    if (gui_state.visible) {
        // Instead of pausing, we'll store the current state
        gui_state.was_playing = false;
        
        // Check if any tracks are playing
        for (var i = 0; i < array_length(midi_player.midi_files); i++) {
            if (midi_player.midi_files[i].is_playing) {
                gui_state.was_playing = true;
                break;
            }
        }
        
        // Stop all tracks when opening menu
        if (gui_state.was_playing) {
            midi_player.StopAll();
        }
    } else {
        // Resume playback if it was playing before
        if (gui_state.was_playing) {
            midi_player.PlayAll();
			RestartGame();
        }
    }
}

/// @function PlayAllDrumTracks()
/// @description Ensure all drum tracks are playing when in drum mode
function PlayAllDrumTracks() {
    var current_song = song_manager.GetCurrentSong();
    if (current_song == undefined) return;
    
    // Unmute and play all drum tracks
    if (current_song.track_indices.drums_kick >= 0) {
        midi_player.muted_files[current_song.track_indices.drums_kick] = false;
        midi_player.PlayFile(current_song.track_indices.drums_kick);
    }
    
    if (current_song.track_indices.drums_snare >= 0) {
        midi_player.muted_files[current_song.track_indices.drums_snare] = false;
        midi_player.PlayFile(current_song.track_indices.drums_snare);
    }
    
    if (current_song.track_indices.drums_cymbals >= 0) {
        midi_player.muted_files[current_song.track_indices.drums_cymbals] = false;
        midi_player.PlayFile(current_song.track_indices.drums_cymbals);
    }
    
    if (current_song.track_indices.drums_other >= 0) {
        midi_player.muted_files[current_song.track_indices.drums_other] = false;
        midi_player.PlayFile(current_song.track_indices.drums_other);
    }
}

/// Updated SetInstrument function that ensures ALL drum tracks play
function SetInstrument(instrument_index) {
    if (instrument_index >= 0 && instrument_index < array_length(instruments)) {
        // Update selected instrument
        gui_state.selected_instrument = instrument_index;
        
        // Get the track for this instrument
        var track = instruments[instrument_index].track;
        
        // Set the game track
        midi_player.SetGameTrack(track);
        
        // Special handling for drums - make sure ALL drum tracks are playing
        if (track == 3) { // If drums selected
            PlayAllDrumTracks();
        }
        
        // Reinitialize the rhythm game with the new settings
        rhythm_game.Initialize();
    }
}

/// Updated PlayAllTracksOnStart function
// Called when restarting the game
function RestartGame() {
    // Stop all playback
    midi_player.StopAll();
    
    // Create a new rhythm game instance
    rhythm_game = new Rhythm_Game(midi_player);
    
    // Reset all files to beginning
    for (var i = 0; i < array_length(midi_player.midi_files); i++) {
        midi_player.SeekFile(i, 0);
    }
    
    // Start a countdown before playing
    midi_player.StartCountdown(4, function() {
        midi_player.PlayAll();
        
        // Special handling for drums - make sure ALL drum tracks are playing
        if (midi_player.game_track == 3) {
            PlayAllDrumTracks();
        }
    });
}

/// @function SetDifficulty(difficulty_level)
/// @description Change the difficulty level
/// @param {real} difficulty_level - The difficulty level to set
function SetDifficulty(difficulty_level) {
    if (difficulty_level >= 0 && difficulty_level < array_length(difficulties)) {
        // Update selected difficulty
        gui_state.selected_difficulty = difficulty_level;
        
        // Set the difficulty
        midi_player.SetDifficulty(difficulty_level);
        
        // Reinitialize the rhythm game with the new settings
        rhythm_game.Initialize();
    }
}

/// @function DrawGUI()
/// @description Draw the settings GUI
function DrawGUI() {
    // Always draw the settings button
    var settings_button_x = room_width - 60;
    var settings_button_y = 20;
    
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_circle(settings_button_x, settings_button_y, 25, false);
    draw_set_alpha(1.0);
    
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(settings_button_x, settings_button_y, "ESC");
    
    // Check for mouse click on settings button
    if (mouse_check_button_pressed(mb_left)) {
        if (point_distance(mouse_x, mouse_y, settings_button_x, settings_button_y) < 25) {
            ToggleGUI();
        }
    }
    
    // Draw the main GUI if visible
    if (gui_state.visible) {
        // Update animation
        gui_state.animation = min(1.0, gui_state.animation + 0.1);
    } else {
        gui_state.animation = max(0.0, gui_state.animation - 0.1);
    }
    
    // Skip drawing if animation is 0
    if (gui_state.animation <= 0) return;
    
    // Calculate GUI dimensions
    var gui_width = 400;
    var gui_height = 400;
    var gui_x = (room_width - gui_width) / 2;
    var gui_y = (room_height - gui_height) / 2;
    
    // Apply animation scale
    var scaled_width = gui_width * gui_state.animation;
    var scaled_height = gui_height * gui_state.animation;
    var scaled_x = (room_width - scaled_width) / 2;
    var scaled_y = (room_height - scaled_height) / 2;
    
    // Draw GUI background
    draw_set_color(c_black);
    draw_set_alpha(0.8 * gui_state.animation);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(0.9 * gui_state.animation);
    draw_roundrect(scaled_x, scaled_y, scaled_x + scaled_width, scaled_y + scaled_height, false);
    draw_set_alpha(1.0);
    
    // If animation is not complete, don't draw the rest
    if (gui_state.animation < 0.9) return;
    
    // Reset hover button
    gui_state.hover_button = -1;
    
    // Draw GUI title
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text_transformed(gui_x + gui_width / 2, gui_y + 20, "GAME SETTINGS", 1.5, 1.5, 0);
    
    // Draw section titles
    draw_set_halign(fa_left);
    draw_text(gui_x + 20, gui_y + 80, "INSTRUMENT:");
    draw_text(gui_x + 20, gui_y + 220, "DIFFICULTY:");
    
    // Draw instrument buttons
    var button_y = gui_y + 110;
    for (var i = 0; i < array_length(instruments); i++) {
        var button_x = gui_x + 20 + (i % 2) * (gui_state.button_width + gui_state.padding);
        var row_offset = floor(i / 2) * (gui_state.button_height + gui_state.padding);
        
        // Check if mouse is hovering over button
        var mouse_over = point_in_rectangle(mouse_x, mouse_y, 
            button_x, button_y + row_offset,
            button_x + gui_state.button_width, button_y + row_offset + gui_state.button_height);
        
        // Store hover state
        if (mouse_over) {
            gui_state.hover_button = i;
        }
        
        // Draw button
        var selected = (gui_state.selected_instrument == i);
        draw_set_color(selected ? c_lime : (mouse_over ? c_yellow : c_gray));
        draw_roundrect(
            button_x, button_y + row_offset,
            button_x + gui_state.button_width, button_y + row_offset + gui_state.button_height,
            false
        );
        
        // Draw button text
        draw_set_color(c_black);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(
            button_x + gui_state.button_width / 2,
            button_y + row_offset + gui_state.button_height / 2,
            instruments[i].name
        );
        
        // Check for mouse click
        if (mouse_over && mouse_check_button_pressed(mb_left)) {
            SetInstrument(i);
        }
    }
    
    // Draw difficulty buttons
    button_y = gui_y + 250;
    for (var i = 0; i < array_length(difficulties); i++) {
        var button_x = gui_x + 20 + (i % 2) * (gui_state.button_width + gui_state.padding);
        var row_offset = floor(i / 2) * (gui_state.button_height + gui_state.padding);
        
        // Check if mouse is hovering over button
        var mouse_over = point_in_rectangle(mouse_x, mouse_y, 
            button_x, button_y + row_offset,
            button_x + gui_state.button_width, button_y + row_offset + gui_state.button_height);
        
        // Store hover state
        if (mouse_over) {
            gui_state.hover_button = i + 100; // Offset to distinguish from instrument buttons
        }
        
        // Get button color based on difficulty
        var diff_color;
        switch(i) {
            case 0: diff_color = c_lime; break;   // Easy - Green
            case 1: diff_color = c_yellow; break; // Medium - Yellow
            case 2: diff_color = c_orange; break; // Hard - Orange
            case 3: diff_color = c_red; break;    // Expert - Red
            default: diff_color = c_gray;
        }
        
        // Draw button
        var selected = (gui_state.selected_difficulty == i);
        draw_set_color(selected ? diff_color : (mouse_over ? c_ltgray : c_dkgray));
        draw_roundrect(
            button_x, button_y + row_offset,
            button_x + gui_state.button_width, button_y + row_offset + gui_state.button_height,
            false
        );
        
        // Draw button text
        draw_set_color(selected ? c_black : c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(
            button_x + gui_state.button_width / 2,
            button_y + row_offset + gui_state.button_height / 2,
            difficulties[i].name
        );
        
        // Check for mouse click
        if (mouse_over && mouse_check_button_pressed(mb_left)) {
            SetDifficulty(i);
        }
    }
    
    // Draw close button
    var close_button_x = gui_x + gui_width - 40;
    var close_button_y = gui_y + 20;
    
    draw_set_color(c_red);
    draw_circle(close_button_x, close_button_y, 15, false);
    
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(close_button_x, close_button_y, "X");
    
    // Check for mouse click on close button
    if (mouse_check_button_pressed(mb_left)) {
        if (point_distance(mouse_x, mouse_y, close_button_x, close_button_y) < 15) {
            ToggleGUI();
        }
    }
    
    // Draw info about keyboard shortcuts
    draw_set_color(c_gray);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_text(gui_x + gui_width / 2, gui_y + gui_height - 20, "Press ESC to toggle this menu");
}