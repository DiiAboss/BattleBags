/// @description MIDI Player System
/// A simple MIDI JSON player using a single sound with pitch shifting

// Global variables for the MIDI player
global.midi_data = undefined;
global.midi_notes = [];
global.midi_current_time = 0;
global.midi_is_playing = false;
global.midi_base_note = 60; // Middle C (MIDI note 60)
global.midi_base_sound = undefined; // Will store the sound resource

/// @function midi_load_json(filename)
/// @description Loads a MIDI JSON file and prepares it for playback
/// @param {string} filename - The name of the JSON file to load
function midi_load_json(filename) {
    // Load the JSON file
    var json_string = "";
    
    if (file_exists(filename)) {
        var file = file_text_open_read(filename);
        while (!file_text_eof(file)) {
            json_string += file_text_read_string(file);
            file_text_readln(file);
        }
        file_text_close(file);
    } else {
        show_debug_message("MIDI JSON file not found: " + filename);
        return false;
    }
    
    // Parse the JSON
    global.midi_data = json_parse(json_string);
    
    // Extract notes from all tracks into a single array
    global.midi_notes = [];
    
    for (var t = 0; t < array_length(global.midi_data.tracks); t++) {
        var track = global.midi_data.tracks[t];
        
        // Skip empty tracks
        if (array_length(track.notes) == 0) continue;
        
        // Add all notes from this track
        for (var n = 0; n < array_length(track.notes); n++) {
            var note = track.notes[n];
            array_push(global.midi_notes, {
                time: note.time,       // Time in seconds when the note should play
                midi: note.midi,       // MIDI note number
                duration: note.duration, // Duration in seconds
                velocity: note.velocity  // Volume (0-1)
            });
        }
    }
    
    // Sort notes by time
    array_sort(global.midi_notes, function(a, b) {
        return a.time - b.time;
    });
    
    show_debug_message("MIDI loaded with " + string(array_length(global.midi_notes)) + " notes");
    return true;
}

/// @function midi_start_playback(base_sound)
/// @description Starts playback of the loaded MIDI file
/// @param {asset.gmSound} base_sound - The sound resource to use as the base sound
function midi_start_playback(base_sound) {
    if (global.midi_data == undefined) {
        show_debug_message("No MIDI data loaded");
        return false;
    }
    
    global.midi_base_sound = base_sound;
    global.midi_current_time = 0;
    global.midi_is_playing = true;
    
    show_debug_message("MIDI playback started");
    return true;
}

/// @function midi_stop_playback()
/// @description Stops playback of the MIDI file
function midi_stop_playback() {
    global.midi_is_playing = false;
    audio_stop_all();
    show_debug_message("MIDI playback stopped");
}

/// @function midi_update()
/// @description Updates the MIDI playback, should be called in the Step event
function midi_update() {
    if (!global.midi_is_playing) return;
    
    // Get delta time (time since last frame in seconds)
    var _delta_time = delta_time / 1000000; // Convert microseconds to seconds
    
    // Update current time
    global.midi_current_time += _delta_time;
    
    // Check for notes that should be played now
    for (var i = 0; i < array_length(global.midi_notes); i++) {
        var note = global.midi_notes[i];
        
        // If this note's start time is within our current time window
        if (note.time <= global.midi_current_time && 
            note.time + _delta_time > global.midi_current_time - _delta_time) {
            
            // Calculate pitch shift based on the difference from our base note
            var pitch_shift = power(2, (note.midi - global.midi_base_note) / 12);
            
            // Play the note with adjusted pitch and volume
            var sound_instance = audio_play_sound(global.midi_base_sound, 10, false);
            audio_sound_pitch(sound_instance, pitch_shift);
            audio_sound_gain(sound_instance, note.velocity, 0);
            
            // Optional: Schedule the sound to stop after its duration
            // This isn't necessary since we're not looping the sound, but it's more accurate
            var duration_ms = note.duration * 1000;
            audio_sound_gain(sound_instance, 0, duration_ms);
            
            show_debug_message("Playing note: " + string(note.midi) + 
                " at time: " + string(global.midi_current_time) + 
                " with pitch: " + string(pitch_shift));
        }
    }
    
    // Check if we've reached the end of the song
    if (array_length(global.midi_notes) > 0) {
        var last_note = global.midi_notes[array_length(global.midi_notes) - 1];
        if (global.midi_current_time > last_note.time + last_note.duration + 1) {
            show_debug_message("MIDI playback finished");
            global.midi_is_playing = false;
        }
    }
}

/// @function midi_seek(time)
/// @description Seeks to a specific time in the MIDI file
/// @param {real} time - The time in seconds to seek to
function midi_seek(time) {
    global.midi_current_time = time;
    audio_stop_all(); // Stop all currently playing sounds
    show_debug_message("MIDI seek to time: " + string(time));
}

/// @function note_to_frequency(midi_note)
/// @description Converts a MIDI note number to frequency in Hz
/// @param {real} midi_note - The MIDI note number
/// @returns {real} The frequency in Hz
function note_to_frequency(midi_note) {
    // A4 (MIDI note 69) is 440 Hz
    return 440 * power(2, (midi_note - 69) / 12);
}