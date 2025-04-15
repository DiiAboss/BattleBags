/// @description MIDI Player Constructor
/// A constructor-based MIDI player that can be instanced multiple times

/// @function Midi_Player(base_sound, x, y, width, height)
/// @description Creates a new MIDI player instance
/// @param {asset.gmSound} base_sound - The sound resource to use as the base sound
/// @param {real} x - The x position for the player UI
/// @param {real} y - The y position for the player UI
/// @param {real} width - The width of the player UI
/// @param {real} height - The height of the player UI
function Midi_Player(base_sound, x, y, width, height) constructor {
    // Initialize properties
    self.base_sound = base_sound;
    self.base_note = 60; // Middle C (MIDI note 60)
    self.midi_files = []; // Array to store multiple MIDI files
    self.active_file = -1; // Index of the currently active file
    self.muted_files = []; // Array to track which files are muted
    
    // UI properties
    self.x = x;
    self.y = y;
    self.width = width;
    self.height = height;
    self.show_player = true;
    self.is_open = false; // Track if the player UI is expanded
    
    // Button dimensions
    self.btn_size = 40;
    self.btn_spacing = 10;
    
    /// @function AddMidiFile(filename)
    /// @description Loads a MIDI file and adds it to this player
    /// @param {string} filename - The name of the JSON file to load
    /// @returns {real} The index of the loaded file or -1 if failed
    static AddMidiFile = function(filename) {
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
            return -1;
        }
        
        // Parse the JSON
        var midi_data = json_parse(json_string);
        
        // Create a new MIDI file object
        var midi_file = {
            data: midi_data,
            notes: [],
            tempo_changes: [],
            current_time: 0,
            is_playing: false,
            duration: 0,
            bpm: 0,
            sound_instances: [],
            filename: filename
        };
        
        // Extract notes from the "notes" array
        var note_format = midi_data.format;
        
        // Create an index map for easy access to values
        var midi_index = -1;
        var time_index = -1;
        var duration_index = -1;
        
        // Find the indices for the format values
        for (var i = 0; i < array_length(note_format); i++) {
            if (note_format[i] == "midi") {
                midi_index = i;
            } else if (note_format[i] == "time") {
                time_index = i;
            } else if (note_format[i] == "duration") {
                duration_index = i;
            }
        }
        
        // Check if we found all required indices
        if (midi_index == -1 || time_index == -1 || duration_index == -1) {
            show_debug_message("MIDI file has invalid format: " + filename);
            return -1;
        }
        
        // Extract all notes based on the format
        var notes_array = midi_data.notes;
        for (var n = 0; n < array_length(notes_array); n++) {
            var note_data = notes_array[n];
            
            // Extract values based on the format indices
            var midi_note = note_data[midi_index];
            var start_time = note_data[time_index];
            var duration = note_data[duration_index];
            
            // Add the note to our array
            array_push(midi_file.notes, {
                time: start_time,       // Time in seconds when the note should play
                midi: midi_note,        // MIDI note number
                duration: duration,     // Duration in seconds
                velocity: 0.8           // Default velocity (0-1) since it might not be in the data
            });
        }
        
        // Sort notes by time
        array_sort(midi_file.notes, function(a, b) {
            return a.time - b.time;
        });
        
        // Store metadata information
        var meta = midi_data.meta;
        midi_file.total_notes = meta.totalNotes;
        midi_file.duration = meta.duration;
        midi_file.bpm = meta.bpm;
        
        // Parse tempo changes if they exist
        if (variable_struct_exists(midi_data, "tempo")) {
            var tempo_format = midi_data.tempoFormat;
            
            // Find the indices for tempo format
            var tempo_time_index = -1;
            var tempo_bpm_index = -1;
            
            for (var i = 0; i < array_length(tempo_format); i++) {
                if (tempo_format[i] == "time") {
                    tempo_time_index = i;
                } else if (tempo_format[i] == "bpm") {
                    tempo_bpm_index = i;
                }
            }
            
            if (tempo_time_index != -1 && tempo_bpm_index != -1) {
                // Extract tempo changes
                var tempo_data = midi_data.tempo;
                for (var t = 0; t < array_length(tempo_data); t++) {
                    array_push(midi_file.tempo_changes, {
                        time: tempo_data[t][tempo_time_index],
                        bpm: tempo_data[t][tempo_bpm_index]
                    });
                }
            }
        }
        
        // Add the file to our array
        var file_index = array_length(self.midi_files);
        array_push(self.midi_files, midi_file);
        array_push(self.muted_files, false); // Not muted by default
        
        // Set as active file if it's the first one
        if (file_index == 0) {
            self.active_file = 0;
        }
        
        show_debug_message("MIDI loaded with " + string(array_length(midi_file.notes)) + " notes");
        show_debug_message("BPM: " + string(midi_file.bpm) + ", Duration: " + string(midi_file.duration) + " seconds");
        
        return file_index;
    }
    
    /// @function PlayFile(file_index)
    /// @description Starts playback of a specific file
    /// @param {real} file_index - The index of the file to play
    /// @returns {bool} True if successful
    static PlayFile = function(file_index) {
        if (file_index < 0 || file_index >= array_length(self.midi_files)) {
            show_debug_message("Invalid file index: " + string(file_index));
            return false;
        }
        
        var midi_file = self.midi_files[file_index];
        midi_file.current_time = 0;
        midi_file.is_playing = true;
        
        show_debug_message("Started playback of MIDI file: " + midi_file.filename);
        return true;
    }
    
    /// @function StopFile(file_index)
    /// @description Stops playback of a specific file
    /// @param {real} file_index - The index of the file to stop
    static StopFile = function(file_index) {
        if (file_index < 0 || file_index >= array_length(self.midi_files)) {
            show_debug_message("Invalid file index: " + string(file_index));
            return;
        }
        
        var midi_file = self.midi_files[file_index];
        midi_file.is_playing = false;
        
        // Stop all sounds for this file
        for (var i = 0; i < array_length(midi_file.sound_instances); i++) {
            var snd = midi_file.sound_instances[i];
            if (audio_is_playing(snd)) {
                audio_stop_sound(snd);
            }
        }
        
        // Clear the sound instances array
        midi_file.sound_instances = [];
        
        show_debug_message("Stopped playback of MIDI file: " + midi_file.filename);
    }
    
    /// @function TogglePlayback(file_index)
    /// @description Toggles playback of a specific file
    /// @param {real} file_index - The index of the file to toggle
    /// @returns {bool} The new play state
    static TogglePlayback = function(file_index) {
        if (file_index < 0 || file_index >= array_length(self.midi_files)) {
            show_debug_message("Invalid file index: " + string(file_index));
            return false;
        }
        
        var midi_file = self.midi_files[file_index];
        
        if (midi_file.is_playing) {
            self.StopFile(file_index);
            return false;
        } else {
            self.PlayFile(file_index);
            return true;
        }
    }
    
    /// @function ToggleMute(file_index)
    /// @description Toggles mute status of a specific file
    /// @param {real} file_index - The index of the file to toggle mute
    /// @returns {bool} The new mute state
    static ToggleMute = function(file_index) {
        if (file_index < 0 || file_index >= array_length(self.midi_files)) {
            show_debug_message("Invalid file index: " + string(file_index));
            return false;
        }
        
        // Toggle mute state
        self.muted_files[file_index] = !self.muted_files[file_index];
        
        // If the file is muted, mute all current sound instances
        if (self.muted_files[file_index]) {
            var midi_file = self.midi_files[file_index];
            for (var i = 0; i < array_length(midi_file.sound_instances); i++) {
                var snd = midi_file.sound_instances[i];
                if (audio_is_playing(snd)) {
                    audio_sound_gain(snd, 0, 100); // Fade to silence quickly
                }
            }
        }
        
        return self.muted_files[file_index];
    }
    
    /// @function SeekFile(file_index, time)
    /// @description Seeks to a specific time in a file
    /// @param {real} file_index - The index of the file to seek
    /// @param {real} time - The time in seconds to seek to
    static SeekFile = function(file_index, time) {
        if (file_index < 0 || file_index >= array_length(self.midi_files)) {
            show_debug_message("Invalid file index: " + string(file_index));
            return;
        }
        
        var midi_file = self.midi_files[file_index];
        midi_file.current_time = time;
        
        // Stop all sounds for this file
        for (var i = 0; i < array_length(midi_file.sound_instances); i++) {
            var snd = midi_file.sound_instances[i];
            if (audio_is_playing(snd)) {
                audio_stop_sound(snd);
            }
        }
        
        // Clear the sound instances array
        midi_file.sound_instances = [];
        
        show_debug_message("Seek to time " + string(time) + " in MIDI file: " + midi_file.filename);
    }
    
    /// @function SetActiveFile(file_index)
    /// @description Sets the active file for UI display and controls
    /// @param {real} file_index - The index of the file to set active
    static SetActiveFile = function(file_index) {
        if (file_index < 0 || file_index >= array_length(self.midi_files)) {
            show_debug_message("Invalid file index: " + string(file_index));
            return;
        }
        
        self.active_file = file_index;
    }
    
    /// @function GetCurrentBpm(file_index)
    /// @description Gets the current BPM based on playback time for a file
    /// @param {real} file_index - The index of the file to check
    /// @returns {real} The current BPM
    static GetCurrentBpm = function(file_index) {
        if (file_index < 0 || file_index >= array_length(self.midi_files)) {
            return 120; // Default BPM if invalid
        }
        
        var midi_file = self.midi_files[file_index];
        var current_bpm = midi_file.bpm;
        
        if (array_length(midi_file.tempo_changes) > 0) {
            // Find the most recent tempo change
            for (var i = 0; i < array_length(midi_file.tempo_changes); i++) {
                if (midi_file.tempo_changes[i].time <= midi_file.current_time) {
                    current_bpm = midi_file.tempo_changes[i].bpm;
                } else {
                    break; // Stop once we reach future tempo changes
                }
            }
        }
        
        return current_bpm;
    }
    
    /// @function Update()
    /// @description Updates all MIDI playback, call this in the Step event
    static Update = function() {
        // Get delta time (time since last frame in seconds)
        var dt = delta_time / 1000000; // Convert microseconds to seconds
        
        // Process each MIDI file
        for (var file_index = 0; file_index < array_length(self.midi_files); file_index++) {
            var midi_file = self.midi_files[file_index];
            
            // Update playing files
            if (midi_file.is_playing) {
                // Update current time
                midi_file.current_time += dt;
                
                // Check for notes that should be played now
                for (var i = 0; i < array_length(midi_file.notes); i++) {
                    var note = midi_file.notes[i];
                    
                    // If this note's start time is within our current time window
                    if (note.time <= midi_file.current_time && 
                        note.time + dt > midi_file.current_time - dt) {
                        
                        // Only play if not muted
                        if (!self.muted_files[file_index]) {
                            // Calculate pitch shift based on the difference from our base note
                            var pitch_shift = power(2, (note.midi - self.base_note) / 12);
                            
                            // Play the note with adjusted pitch and volume
                            var sound_instance = audio_play_sound(self.base_sound, 10, false);
                            audio_sound_pitch(sound_instance, pitch_shift);
                            
                            // Use default velocity or the one provided in the data
                            var velocity = 0.8;
                            if (variable_struct_exists(note, "velocity")) {
                                velocity = note.velocity;
                            }
                            audio_sound_gain(sound_instance, velocity, 0);
                            
                            // Schedule the sound to fade out after its duration
                            var duration_ms = note.duration * 1000;
                            audio_sound_gain(sound_instance, 0, duration_ms);
                            
                            // Store the sound instance for later reference
                            array_push(midi_file.sound_instances, sound_instance);
                            
                            show_debug_message("Playing note: " + string(note.midi) + 
                                " at time: " + string(midi_file.current_time) + 
                                " with pitch: " + string(pitch_shift) + 
                                " in file: " + string(file_index));
                        }
                    }
                }
                
                // Check if we've reached the end of the song
                if (midi_file.current_time > midi_file.duration + 1) {
                    show_debug_message("MIDI playback finished for file: " + midi_file.filename);
                    midi_file.is_playing = false;
                }
            }
        }
        
        // Check for UI interaction
        if (self.show_player) {
            // Toggle player open/closed when clicking the header
            if (mouse_check_button_pressed(mb_left)) {
                if (point_in_rectangle(mouse_x, mouse_y, 
                                       self.x, self.y, 
                                       self.x + self.width, self.y + 30)) {
                    self.is_open = !self.is_open;
                }
                
                // If player is open, check for button clicks
                if (self.is_open && self.active_file >= 0 && self.active_file < array_length(self.midi_files)) {
                    var file = self.midi_files[self.active_file];
                    
                    // Play/pause button
                    if (point_in_rectangle(mouse_x, mouse_y, 
                                          self.x + 10, self.y + 40, 
                                          self.x + 10 + self.btn_size, self.y + 40 + self.btn_size)) {
                        self.TogglePlayback(self.active_file);
                    }
                    
                    // Mute button
                    if (point_in_rectangle(mouse_x, mouse_y, 
                                          self.x + 10 + self.btn_size + self.btn_spacing, self.y + 40, 
                                          self.x + 10 + self.btn_size * 2 + self.btn_spacing, self.y + 40 + self.btn_size)) {
                        self.ToggleMute(self.active_file);
                    }
                    
                    // Progress bar
                    if (point_in_rectangle(mouse_x, mouse_y, 
                                          self.x + 10, self.y + 40 + self.btn_size + 10, 
                                          self.x + self.width - 10, self.y + 40 + self.btn_size + 20)) {
                        // Calculate seek position
                        var progress = (mouse_x - (self.x + 10)) / (self.width - 20);
                        var seek_time = file.duration * progress;
                        self.SeekFile(self.active_file, seek_time);
                    }
                    
                    // File selection buttons - show previous files
                    if (self.active_file > 0 && point_in_rectangle(mouse_x, mouse_y,
                                                                 self.x + 10, self.y + 40 + self.btn_size + 30,
                                                                 self.x + 30, self.y + 40 + self.btn_size + 50)) {
                        self.SetActiveFile(self.active_file - 1);
                    }
                    
                    // File selection buttons - show next files
                    if (self.active_file < array_length(self.midi_files) - 1 && 
                        point_in_rectangle(mouse_x, mouse_y,
                                          self.x + 40, self.y + 40 + self.btn_size + 30,
                                          self.x + 60, self.y + 40 + self.btn_size + 50)) {
                        self.SetActiveFile(self.active_file + 1);
                    }
                }
            }
        }
    }
    
    /// @function Draw()
    /// @description Draws the MIDI player UI, call this in the Draw event
    static Draw = function() {
        if (!self.show_player) return;
        
        // Draw the player background
        draw_set_color(c_black);
        draw_set_alpha(0.8);
        draw_rectangle(self.x, self.y, self.x + self.width, self.y + 30, false);
        
        // Draw the header
        draw_set_color(c_white);
        draw_set_alpha(1);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_text(self.x + 10, self.y + 15, "MIDI Player - " + 
                                           string(array_length(self.midi_files)) + 
                                           " file(s) loaded");
        
        // Draw expand/collapse indicator
        draw_text(self.x + self.width - 20, self.y + 15, self.is_open ? "▼" : "►");
        
        // If expanded, draw the full player
        if (self.is_open) {
            // Calculate height based on content
            var player_height = 120; // Basic height
            
            // Draw expanded background
            draw_set_color(c_black);
            draw_set_alpha(0.8);
            draw_rectangle(self.x, self.y + 30, self.x + self.width, self.y + player_height, false);
            draw_set_alpha(1);
            
            // If we have a selected file, show its controls
            if (self.active_file >= 0 && self.active_file < array_length(self.midi_files)) {
                var file = self.midi_files[self.active_file];
                
                // Draw file name
                draw_set_color(c_white);
                draw_text(self.x + 10, self.y + 30 + 15, "File " + string(self.active_file + 1) + ": " + 
                                                       file.filename);
                
                // Draw play/pause button
                draw_set_color(file.is_playing ? c_lime : c_gray);
                draw_rectangle(self.x + 10, self.y + 40, 
                               self.x + 10 + self.btn_size, self.y + 40 + self.btn_size, false);
                draw_set_color(c_white);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text(self.x + 10 + self.btn_size / 2, self.y + 40 + self.btn_size / 2, 
                          file.is_playing ? "⏸" : "▶");
                
                // Draw mute button
                draw_set_color(self.muted_files[self.active_file] ? c_red : c_gray);
                draw_rectangle(self.x + 10 + self.btn_size + self.btn_spacing, self.y + 40, 
                               self.x + 10 + self.btn_size * 2 + self.btn_spacing, self.y + 40 + self.btn_size, false);
                draw_set_color(c_white);
                draw_text(self.x + 10 + self.btn_size * 1.5 + self.btn_spacing, self.y + 40 + self.btn_size / 2, 
                          self.muted_files[self.active_file] ? "🔇" : "🔊");
                
                // Draw progress bar
                draw_set_color(c_dkgray);
                draw_rectangle(self.x + 10, self.y + 40 + self.btn_size + 10, 
                               self.x + self.width - 10, self.y + 40 + self.btn_size + 20, false);
                
                // Draw progress
                var progress = file.current_time / file.duration;
                draw_set_color(c_lime);
                draw_rectangle(self.x + 10, self.y + 40 + self.btn_size + 10, 
                               self.x + 10 + (self.width - 20) * progress, self.y + 40 + self.btn_size + 20, false);
                
                // Draw time
                draw_set_color(c_white);
                draw_set_halign(fa_left);
                var minutes_current = floor(file.current_time / 60);
                var seconds_current = file.current_time mod 60;
                var minutes_total = floor(file.duration / 60);
                var seconds_total = file.duration mod 60;
                
                var time_str = string(minutes_current) + ":" + string_format(seconds_current, 2, 1) + 
                              " / " + string(minutes_total) + ":" + string_format(seconds_total, 2, 1);
                draw_text(self.x + 10, self.y + 40 + self.btn_size + 25, time_str);
                
                // Draw BPM
                var current_bpm = self.GetCurrentBpm(self.active_file);
                draw_text(self.x + self.width - 80, self.y + 40 + self.btn_size + 25, 
                          "BPM: " + string(current_bpm));
                
                // Draw file selection buttons
                draw_set_color(c_gray);
                // Previous file button
                if (self.active_file > 0) {
                    draw_rectangle(self.x + 10, self.y + 40 + self.btn_size + 30, 
                                   self.x + 30, self.y + 40 + self.btn_size + 50, false);
                    draw_set_color(c_white);
                    draw_text(self.x + 20, self.y + 40 + self.btn_size + 40, "◀");
                    draw_set_color(c_gray);
                }
                
                // Next file button
                if (self.active_file < array_length(self.midi_files) - 1) {
                    draw_rectangle(self.x + 40, self.y + 40 + self.btn_size + 30, 
                                   self.x + 60, self.y + 40 + self.btn_size + 50, false);
                    draw_set_color(c_white);
                    draw_text(self.x + 50, self.y + 40 + self.btn_size + 40, "▶");
                }
            } else {
                // No files loaded or selected
                draw_set_color(c_white);
                draw_set_halign(fa_center);
                draw_text(self.x + self.width / 2, self.y + 30 + 40, "No MIDI files loaded");
            }
        }
    }
    
    /// @function StopAll()
    /// @description Stops all MIDI playback
    static StopAll = function() {
        for (var i = 0; i < array_length(self.midi_files); i++) {
            self.StopFile(i);
        }
    }
    
    /// @function PlayAll()
    /// @description Plays all MIDI files simultaneously
    static PlayAll = function() {
        for (var i = 0; i < array_length(self.midi_files); i++) {
            self.PlayFile(i);
        }
    }
    
    /// @function TogglePlayer()
    /// @description Toggles the visibility of the player UI
    static TogglePlayer = function() {
        self.show_player = !self.show_player;
        return self.show_player;
    }
    
    /// @function Clean()
    /// @description Cleans up resources, call this when destroying the player
    static Clean = function() {
        self.StopAll();
    }
}