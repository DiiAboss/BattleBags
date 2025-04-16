/// CREATE EVENT
/// @description Initialize MIDI player and rhythm game
// Create array of sounds for different tracks
var sounds = [
    snd_ta_note_C,  // Bass sound
    snd_ta_note_C,  // Vocals sound
    snd_ta_note_C, // Leads sound 
    snd_kick_2,     // Drums_Kick
    snd_snare_1,    // Drums_Snare
    snd_hihat_2     // Drums_Cymbal
];

// Create enhanced MIDI player with multiple sounds
midi_player = new Midi_Player(sounds, 10, 10, 400, 200);

// Add MIDI files with track type parameter
file1 = midi_player.AddMidiFile("Amore_Bass.json", 0);    // Bass - track type 0
file2 = midi_player.AddMidiFile("mario.json", 1);  // Vocals - track type 1
file3 = midi_player.AddMidiFile("Amore_Instro.json", 2);   // Leads - track type 2
file4 = midi_player.AddMidiFile("Amore_Kick.json", 3);   // Drums Kick - track type 3
file5 = midi_player.AddMidiFile("Amore_Snare.json", 4);  // Drums Snare - track type 4
file6 = midi_player.AddMidiFile("Amore_Cymbals.json", 5); // Drums Cymbals - track type 5

// Set default active file
midi_player.SetActiveFile(0);

// Set game track (which track the player needs to play)
midi_player.SetGameTrack(3); // Default to drums track (kick drum)

// Set difficulty (0=Easy, 1=Medium, 2=Hard, 3=Expert)
midi_player.SetDifficulty(1); // Default to Medium

// Create the rhythm game instance
rhythm_game = new Rhythm_Game(midi_player);

// Start all tracks playing by default
PlayAllTracksOnStart();

/// Updated RestartGame function
function RestartGame() {
    // Stop all playback
    midi_player.StopAll();
    
    // Create a new rhythm game instance (resets all scores and effects)
    rhythm_game = new Rhythm_Game(midi_player);
    
    // Optionally seek all files to the beginning
    for (var i = 0; i < array_length(midi_player.midi_files); i++) {
        midi_player.SeekFile(i, 0);
    }
    
    // Start playing all tracks
    midi_player.PlayAll();
    
    // Special handling for drums - make sure ALL drum tracks are playing
    if (midi_player.game_track == 3) {
        PlayAllDrumTracks();
    }
}

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
        }
    }
}

/// Function to add to your Object's Create event after initializing variables
/// @function PlayAllDrumTracks()
/// @description Ensures all drum tracks play simultaneously
function PlayAllDrumTracks() {
    // Make sure all drum tracks are playing and unmuted
    var drum_tracks = [3, 4, 5]; // Kick, Snare, Cymbals
    
    for (var i = 0; i < array_length(drum_tracks); i++) {
        var drum_track = drum_tracks[i];
        
        // Skip if this track doesn't exist
        if (drum_track >= array_length(midi_player.midi_files)) {
            continue;
        }
        
        // Start playing this track if it's not already playing
        if (!midi_player.midi_files[drum_track].is_playing) {
            midi_player.PlayFile(drum_track);
        }
        
        // Make sure the track is not muted
        if (midi_player.muted_files[drum_track]) {
            midi_player.ToggleMute(drum_track);
        }
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
function PlayAllTracksOnStart() {
    midi_player.PlayAll();
    
    // If we're starting with drums, make sure all drum tracks are active
    if (midi_player.game_track == 3) {
        PlayAllDrumTracks();
    }
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