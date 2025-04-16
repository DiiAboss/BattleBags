/// @description Enhanced Rhythm Game with Combined Drum Tracks
/// A rhythm game implementation that uses the enhanced MIDI player and properly handles combined drum tracks

/// @function Rhythm_Game(midi_player)
/// @description Creates a new rhythm game using the provided MIDI player
/// @param {struct} midi_player - The MIDI player instance to use
function Rhythm_Game(midi_player) constructor {
    // Store reference to the MIDI player
    self.midi_player = midi_player;
    
    // Game state variables
    self.score = 0;
    self.combo = 0;
    self.max_combo = 0;
    self.accuracy_ratings = {
        perfect: 0,
        great: 0,
        good: 0,
        okay: 0,
        poor: 0,
        miss: 0
    };
    
    // Visual effect variables (reduced capacity to improve performance)
    self.hit_effects = ds_list_create();
    self.miss_effects = ds_list_create();
    self.rating_effects = ds_list_create();
    self.shake_amount = 0;
    
    // Set maximum number of effects to improve performance
    self.max_hit_effects = 10;
    self.max_miss_effects = 3;
    self.max_rating_effects = 20;
    
    // Game configuration
    self.hit_window = 0.15;  // 150ms window for hitting notes
    self.perfect_threshold = 0.95;
    self.great_threshold = 0.85;
    self.good_threshold = 0.65;
    self.okay_threshold = 0.50;
    self.look_ahead = 2.0;   // How many seconds ahead to show notes
    
    // Visual configuration
    self.lane_width = 80;
    self.lane_spacing = 20;
    self.lane_height = 500;
    self.note_size = 30;
    self.hit_circle_size = 40;
    
    // Define lane keys and positions
    self.lanes = [
        { key: ord("Z"), key_text: "Z", color: c_red, x: 0, drum_text: "KICK" },
        { key: ord("X"), key_text: "X", color: c_yellow, x: 0, drum_text: "SNARE" },
        { key: ord("C"), key_text: "C", color: c_aqua, x: 0, drum_text: "HI-HAT" },
        { key: ord("V"), key_text: "V", color: c_fuchsia, x: 0, drum_text: "CRASH" }
    ];
    
    // Use maps for more efficient note tracking
    self.tracked_notes_map = ds_map_create();
    
    // Cache for performance optimization
    self.active_notes = ds_list_create(); // Notes currently in view
    self.active_notes_need_update = true;
    self.last_update_time = 0;
    self.update_frequency = 0.1; // Update active notes cache every 100ms
    
	
	
    /// @function CalculatePositions()
    /// @description Calculate positions based on screen dimensions
    static CalculatePositions = function() {
        var center_x = room_width / 2;
        var total_width = (self.lane_width * array_length(self.lanes)) + 
                          (self.lane_spacing * (array_length(self.lanes) - 1));
        var start_x = center_x - (total_width / 2);
        
        // Calculate lane positions
        for (var i = 0; i < array_length(self.lanes); i++) {
            self.lanes[i].x = start_x + (i * (self.lane_width + self.lane_spacing)) + (self.lane_width / 2);
        }
        
        // Set hit line position
        self.hit_line_y = room_height - 100;
    }
	
/// @function GetLaneForNote(note, file_index)
/// @description Determine which lane a note should appear in based on track, note properties, and progression patterns
/// @param {struct} note - The note to check
/// @param {real} file_index - The file index the note belongs to
/// @returns {real} The lane index
static GetLaneForNote = function(note, file_index) {
    // For drums, map specific drum tracks and notes to different lanes
    if (self.midi_player.game_track == 3) { // If "Drums" is selected as the instrument
        // Map based on file_index (which drum track this is)
        if (file_index == 3) {
            return 0; // Z lane - Kick drum track
        } else if (file_index == 4) {
            return 1; // X lane - Snare drum track
        } else if (file_index == 5) {
            // For cymbals, divide between hi-hat and crash based on note properties
            // Map to C or V based on note pitch
            if (note.midi < 49) { // Low cymbals (hi-hat)
                return 2; // C lane - Hi-hat
            } else { // High cymbals (crash)
                return 3; // V lane - Crash
            }
        }
        // Fallback for any other percussion
        return 2; // Default to C lane
    } else {
        // For melodic instruments, implement progressive pattern detection
        
        // Make sure our variables exist
        if (!variable_struct_exists(self, "note_sequence")) {
            self.note_sequence = [];
        }
        if (!variable_struct_exists(self, "max_sequence_length")) {
            self.max_sequence_length = 8;
        }
        if (!variable_struct_exists(self, "last_note_midi")) {
            self.last_note_midi = -1;
        }
        if (!variable_struct_exists(self, "pattern_direction")) {
            self.pattern_direction = 0;
        }
        if (!variable_struct_exists(self, "progression_count")) {
            self.progression_count = 0;
        }
        if (!variable_struct_exists(self, "last_lane_index")) {
            self.last_lane_index = 0;
        }
        
        // Skip pattern detection if this is the first note
        if (self.last_note_midi == -1) {
            self.last_note_midi = note.midi;
            self.last_lane_index = 0;  // Default first note to Z lane
            return 0;
        }
        
        // Detect direction of note progression
        var note_diff = note.midi - self.last_note_midi;
        var current_direction = 0;
        if (note_diff > 0) {
            current_direction = 1;
        } else if (note_diff < 0) {
            current_direction = -1;
        }
        
        // Add to note sequence history
        array_push(self.note_sequence, note.midi);
        if (array_length(self.note_sequence) > self.max_sequence_length) {
            // Remove oldest note
            array_delete(self.note_sequence, 0, 1);
        }
        
        // Handle direction change or continuation
        if (current_direction != self.pattern_direction && current_direction != 0) {
            // Direction changed, reset progression
            self.pattern_direction = current_direction;
            self.progression_count = 1;
        } else if (current_direction != 0) {
            // Same direction, increment count
            self.progression_count++;
        }
        
        var lane_index = 0;
        
        // Handle different size intervals
        var interval_size = abs(note_diff);
        
        if (interval_size == 0) {
            // Repeated note, use same lane as before
            lane_index = self.last_lane_index;
        } else if (interval_size <= 2) {
            // Small interval (half step or whole step)
            // Move to next adjacent lane with wrapping
            lane_index = (self.last_lane_index + 1) % 4;
        } else if (interval_size <= 4) {
            // Medium interval (minor/major third)
            // Skip one lane with wrapping
            lane_index = (self.last_lane_index + 2) % 4;
        } else {
            // Large interval (fourth or larger)
            // Skip two lanes with wrapping
            lane_index = (self.last_lane_index + 3) % 4;
        }
        
        // Store current note for next comparison
        self.last_note_midi = note.midi;
        self.last_lane_index = lane_index;
        
        return lane_index;
    }
}
	
/// @function Initialize()
/// @description Initialize the rhythm game
static Initialize = function() {
    // Make sure the pattern tracking variables are initialized
    if (!variable_struct_exists(self, "note_sequence")) {
        self.note_sequence = [];
    }
    if (!variable_struct_exists(self, "max_sequence_length")) {
        self.max_sequence_length = 8;
    }
    if (!variable_struct_exists(self, "last_note_midi")) {
        self.last_note_midi = -1;
    }
    if (!variable_struct_exists(self, "pattern_direction")) {
        self.pattern_direction = 0;
    }
    if (!variable_struct_exists(self, "progression_count")) {
        self.progression_count = 0;
    }
    if (!variable_struct_exists(self, "last_lane_index")) {
        self.last_lane_index = 0;
    }
    
    // Reset pattern tracking for new sequence
    self.last_note_midi = -1;
    self.pattern_direction = 0;
    self.progression_count = 0;
    self.last_lane_index = 0;
    self.note_sequence = [];
    
    // Calculate positions
    self.CalculatePositions();
    
    // Clear the tracking map for each note
    ds_map_clear(self.tracked_notes_map);
    
    // Get game track file index
    var game_track = self.midi_player.game_track;
    
    // For drums (track 3), we need to process all drum tracks (3, 4, 5)
    var track_indices = [];
    
    if (game_track == 3) { // If the selected instrument is "Drums"
        // Add ALL available drum tracks
        if (3 < array_length(self.midi_player.midi_files)) 
            array_push(track_indices, 3); // Kick
        if (4 < array_length(self.midi_player.midi_files)) 
            array_push(track_indices, 4); // Snare
        if (5 < array_length(self.midi_player.midi_files)) 
            array_push(track_indices, 5); // Cymbals
    } else {
        // Just use the selected track for non-drum instruments
        array_push(track_indices, game_track);
    }
    
    // Sort notes by time across tracks for proper sequential analysis
    var all_notes = [];
    
    // First, collect all notes from relevant tracks
    for (var track_idx = 0; track_idx < array_length(track_indices); track_idx++) {
        var file_index = track_indices[track_idx];
        
        // Skip if this track doesn't exist
        if (file_index >= array_length(self.midi_player.midi_files)) {
            continue;
        }
        
        var midi_file = self.midi_player.midi_files[file_index];
        
        // For each note in the MIDI file, add to our collection
        for (var i = 0; i < array_length(midi_file.notes); i++) {
            var note = midi_file.notes[i];
            
            // Add all notes to our collection for filtering later
            array_push(all_notes, {
                file_index: file_index,
                note_index: i,
                note: note,
                time: note.time,
                midi: note.midi
            });
        }
    }
    
    // Sort all notes by time
    array_sort(all_notes, function(a, b) {
        return a.time - b.time;
    });
    
    // Apply difficulty filtering
    var filtered_notes = [];
    var current_difficulty = self.midi_player.difficulty;
    
    // Initialize filtering variables
    var lastIncludedNote = -1; // Index of the last note we included
    var noteCounter = 0; // Counter to help with rhythmic patterns
    
    // Filter notes based on difficulty
    if (current_difficulty == 0) { // Easy - Only include major notes with significant pitch or time differences
        for (var i = 0; i < array_length(all_notes); i++) {
            var note_data = all_notes[i];
            
            // Always include the first note
            if (i == 0) {
                array_push(filtered_notes, note_data);
                lastIncludedNote = 0;
                continue;
            }
            
            // Check time and pitch differences from last included note
            var time_diff = note_data.time - all_notes[lastIncludedNote].time;
            var pitch_diff = abs(note_data.midi - all_notes[lastIncludedNote].midi);
            
            // Include note if it's either a significant time or pitch difference
            // Include about 25-30% of notes
            if (time_diff >= 0.5 || pitch_diff >= 3 || (i % 4 == 0)) {
                array_push(filtered_notes, note_data);
                lastIncludedNote = i;
            }
        }
    } else if (current_difficulty == 1) { // Medium - Include about 50-60% of notes
        for (var i = 0; i < array_length(all_notes); i++) {
            var note_data = all_notes[i];
            
            // Always include the first note
            if (i == 0) {
                array_push(filtered_notes, note_data);
                lastIncludedNote = 0;
                continue;
            }
            
            // Check time and pitch differences
            var time_diff = note_data.time - all_notes[lastIncludedNote].time;
            var pitch_diff = abs(note_data.midi - all_notes[lastIncludedNote].midi);
            
            // For medium, include every other note or significant changes
            if (time_diff >= 0.25 || pitch_diff >= 2 || (i % 2 == 0)) {
                array_push(filtered_notes, note_data);
                lastIncludedNote = i;
            }
        }
    } else if (current_difficulty == 2) { // Hard - Include almost all notes (about 90-95%)
        for (var i = 0; i < array_length(all_notes); i++) {
            var note_data = all_notes[i];
            
            // Always include the first note
            if (i == 0) {
                array_push(filtered_notes, note_data);
                lastIncludedNote = 0;
                continue;
            }
            
            // Check if notes are too close together in time
            var time_diff = note_data.time - all_notes[lastIncludedNote].time;
            
            // Only exclude extreme cases (notes that are practically simultaneous)
            // or every 10th note if they're very close together
            if (time_diff >= 0.02 || i % 10 != 0) {
                array_push(filtered_notes, note_data);
                lastIncludedNote = i;
            }
        }
    } else { // Expert - Include all notes
        filtered_notes = all_notes;
    }
    
    // Log note counts (only in debug mode)
    if (false) { // Replace with debug flag if needed
        show_debug_message("Total notes: " + string(array_length(all_notes)));
        show_debug_message("Filtered notes: " + string(array_length(filtered_notes)));
        show_debug_message("Percentage: " + string(array_length(filtered_notes) / array_length(all_notes) * 100) + "%");
    }
    
    // Now process the filtered notes
    for (var i = 0; i < array_length(filtered_notes); i++) {
        var note_data = filtered_notes[i];
        var file_index = note_data.file_index;
        var note_index = note_data.note_index;
        var note = note_data.note;
        
        // Determine which lane this note should appear in
        var lane_index = self.GetLaneForNote(note, file_index);
        
        var key = string(file_index) + "_" + string(note_index);
        ds_map_add(self.tracked_notes_map, key, {
            file_index: file_index,
            note_index: note_index,
            hit: false,
            missed: false,
            lane: lane_index // Store the lane with the note
        });
    }
}
    
    // Get game track file index
    var game_track = self.midi_player.game_track;
    
    // For drums (track 3), we need to process all drum tracks (3, 4, 5)
    var track_indices = [];
    
    if (game_track == 3) { // If the selected instrument is "Drums"
        // Add ALL available drum tracks
        if (3 < array_length(self.midi_player.midi_files)) 
            array_push(track_indices, 3); // Kick
        if (4 < array_length(self.midi_player.midi_files)) 
            array_push(track_indices, 4); // Snare
        if (5 < array_length(self.midi_player.midi_files)) 
            array_push(track_indices, 5); // Cymbals
    } else {
        // Just use the selected track for non-drum instruments
        array_push(track_indices, game_track);
    }
    
    // Sort notes by time across tracks for proper sequential analysis
    var all_notes = [];
    
    // First, collect all notes from relevant tracks
    for (var track_idx = 0; track_idx < array_length(track_indices); track_idx++) {
        var file_index = track_indices[track_idx];
        
        // Skip if this track doesn't exist
        if (file_index >= array_length(self.midi_player.midi_files)) {
            continue;
        }
        
        var midi_file = self.midi_player.midi_files[file_index];
        
        // For each note in the MIDI file, add to our collection
        for (var i = 0; i < array_length(midi_file.notes); i++) {
            var note = midi_file.notes[i];
            
            // Skip notes that don't match the current difficulty level
            if (note.note_type > self.midi_player.difficulty) continue;
            
            // Add to our collection with track info
            array_push(all_notes, {
                file_index: file_index,
                note_index: i,
                note: note,
                time: note.time
            });
        }
    }
    
    // Sort all notes by time
    array_sort(all_notes, function(a, b) {
        return a.time - b.time;
    });
    
    // Now process them in chronological order
    for (var i = 0; i < array_length(all_notes); i++) {
        var note_data = all_notes[i];
        var file_index = note_data.file_index;
        var note_index = note_data.note_index;
        var note = note_data.note;
        
        // Determine which lane this note should appear in
        var lane_index = self.GetLaneForNote(note, file_index);
        
        var key = string(file_index) + "_" + string(note_index);
        ds_map_add(self.tracked_notes_map, key, {
            file_index: file_index,
            note_index: note_index,
            hit: false,
            missed: false,
            lane: lane_index // Store the lane with the note
        });
    }


/// @function Initialize()
/// @description Initialize the rhythm game
static Initialize = function() {
    // Make sure the pattern tracking variables are initialized
    if (!variable_struct_exists(self, "note_sequence")) {
        self.note_sequence = [];
    }
    if (!variable_struct_exists(self, "max_sequence_length")) {
        self.max_sequence_length = 8;
    }
    if (!variable_struct_exists(self, "last_note_midi")) {
        self.last_note_midi = -1;
    }
    if (!variable_struct_exists(self, "pattern_direction")) {
        self.pattern_direction = 0;
    }
    if (!variable_struct_exists(self, "progression_count")) {
        self.progression_count = 0;
    }
    if (!variable_struct_exists(self, "last_lane_index")) {
        self.last_lane_index = 0;
    }
    
    // Reset pattern tracking for new sequence
    self.last_note_midi = -1;
    self.pattern_direction = 0;
    self.progression_count = 0;
    self.last_lane_index = 0;
    self.note_sequence = [];
    
    // Calculate positions
    self.CalculatePositions();
    
    // Clear the tracking map for each note
    ds_map_clear(self.tracked_notes_map);
    
    // Get game track file index
    var game_track = self.midi_player.game_track;
    
    // For drums (track 3), we need to process all drum tracks (3, 4, 5)
    var track_indices = [];
    
    if (game_track == 3) { // If the selected instrument is "Drums"
        // Add ALL available drum tracks
        if (3 < array_length(self.midi_player.midi_files)) 
            array_push(track_indices, 3); // Kick
        if (4 < array_length(self.midi_player.midi_files)) 
            array_push(track_indices, 4); // Snare
        if (5 < array_length(self.midi_player.midi_files)) 
            array_push(track_indices, 5); // Cymbals
    } else {
        // Just use the selected track for non-drum instruments
        array_push(track_indices, game_track);
    }
    
    // Sort notes by time across tracks for proper sequential analysis
    var all_notes = [];
    
    // First, collect all notes from relevant tracks
    for (var track_idx = 0; track_idx < array_length(track_indices); track_idx++) {
        var file_index = track_indices[track_idx];
        
        // Skip if this track doesn't exist
        if (file_index >= array_length(self.midi_player.midi_files)) {
            continue;
        }
        
        var midi_file = self.midi_player.midi_files[file_index];
        
        // For each note in the MIDI file, add to our collection
        for (var i = 0; i < array_length(midi_file.notes); i++) {
            var note = midi_file.notes[i];
            
            // Add all notes to our collection for filtering later
            array_push(all_notes, {
                file_index: file_index,
                note_index: i,
                note: note,
                time: note.time,
                midi: note.midi
            });
        }
    }
    
    // Sort all notes by time
    array_sort(all_notes, function(a, b) {
        return a.time - b.time;
    });
    
    // Apply difficulty filtering
    var filtered_notes = [];
    var current_difficulty = self.midi_player.difficulty;
    
    // Initialize filtering variables
    var lastIncludedNote = -1; // Index of the last note we included
    var noteCounter = 0; // Counter to help with rhythmic patterns
    
    // Filter notes based on difficulty
    if (current_difficulty == 0) { // Easy - Only include major notes with significant pitch or time differences
        for (var i = 0; i < array_length(all_notes); i++) {
            var note_data = all_notes[i];
            
            // Always include the first note
            if (i == 0) {
                array_push(filtered_notes, note_data);
                lastIncludedNote = 0;
                continue;
            }
            
            // Check time and pitch differences from last included note
            var time_diff = note_data.time - all_notes[lastIncludedNote].time;
            var pitch_diff = abs(note_data.midi - all_notes[lastIncludedNote].midi);
            
            // Include note if it's either a significant time or pitch difference
            // Include about 25-30% of notes
            if (time_diff >= 0.5 || pitch_diff >= 3 || (i % 4 == 0)) {
                array_push(filtered_notes, note_data);
                lastIncludedNote = i;
            }
        }
    } else if (current_difficulty == 1) { // Medium - Include about 50-60% of notes
        for (var i = 0; i < array_length(all_notes); i++) {
            var note_data = all_notes[i];
            
            // Always include the first note
            if (i == 0) {
                array_push(filtered_notes, note_data);
                lastIncludedNote = 0;
                continue;
            }
            
            // Check time and pitch differences
            var time_diff = note_data.time - all_notes[lastIncludedNote].time;
            var pitch_diff = abs(note_data.midi - all_notes[lastIncludedNote].midi);
            
            // For medium, include every other note or significant changes
            if (time_diff >= 0.25 || pitch_diff >= 2 || (i % 2 == 0)) {
                array_push(filtered_notes, note_data);
                lastIncludedNote = i;
            }
        }
    } else if (current_difficulty == 2) { // Hard - Include most notes (about 75-80%)
        for (var i = 0; i < array_length(all_notes); i++) {
            var note_data = all_notes[i];
            
            // Always include the first note
            if (i == 0) {
                array_push(filtered_notes, note_data);
                lastIncludedNote = 0;
                continue;
            }
            
            // Check if notes are too close together in time
            var time_diff = note_data.time - all_notes[lastIncludedNote].time;
            
            // Skip only the very rapid notes or every 5th note if too close
            if (time_diff >= 0.05 || i % 5 != 0) {
                array_push(filtered_notes, note_data);
                lastIncludedNote = i;
            }
        }
    } else { // Expert - Include all notes
        filtered_notes = all_notes;
    }
    
    // Log note counts (only in debug mode)
    if (false) { // Replace with debug flag if needed
        show_debug_message("Total notes: " + string(array_length(all_notes)));
        show_debug_message("Filtered notes: " + string(array_length(filtered_notes)));
        show_debug_message("Percentage: " + string(array_length(filtered_notes) / array_length(all_notes) * 100) + "%");
    }
    
    // Now process the filtered notes
    for (var i = 0; i < array_length(filtered_notes); i++) {
        var note_data = filtered_notes[i];
        var file_index = note_data.file_index;
        var note_index = note_data.note_index;
        var note = note_data.note;
        
        // Determine which lane this note should appear in
        var lane_index = self.GetLaneForNote(note, file_index);
        
        var key = string(file_index) + "_" + string(note_index);
        ds_map_add(self.tracked_notes_map, key, {
            file_index: file_index,
            note_index: note_index,
            hit: false,
            missed: false,
            lane: lane_index // Store the lane with the note
        });
    }
}
    
    // Get game track file index
    var game_track = self.midi_player.game_track;
    
    // For drums (track 3), we need to process all drum tracks (3, 4, 5)
    var track_indices = [];
    
    if (game_track == 3) { // If the selected instrument is "Drums"
        // Add ALL available drum tracks
        if (3 < array_length(self.midi_player.midi_files)) 
            array_push(track_indices, 3); // Kick
        if (4 < array_length(self.midi_player.midi_files)) 
            array_push(track_indices, 4); // Snare
        if (5 < array_length(self.midi_player.midi_files)) 
            array_push(track_indices, 5); // Cymbals
    } else {
        // Just use the selected track for non-drum instruments
        array_push(track_indices, game_track);
    }
    
    // Sort notes by time across tracks for proper sequential analysis
    var all_notes = [];
    
    // First, collect all notes from relevant tracks
    for (var track_idx = 0; track_idx < array_length(track_indices); track_idx++) {
        var file_index = track_indices[track_idx];
        
        // Skip if this track doesn't exist
        if (file_index >= array_length(self.midi_player.midi_files)) {
            continue;
        }
        
        var midi_file = self.midi_player.midi_files[file_index];
        
        // For each note in the MIDI file, add to our collection
        for (var i = 0; i < array_length(midi_file.notes); i++) {
            var note = midi_file.notes[i];
            
            // Skip notes that don't match the current difficulty level
            if (note.note_type > self.midi_player.difficulty) continue;
            
            // Add to our collection with track info
            array_push(all_notes, {
                file_index: file_index,
                note_index: i,
                note: note,
                time: note.time
            });
        }
    }
    
    // Sort all notes by time
    array_sort(all_notes, function(a, b) {
        return a.time - b.time;
    });
    
    // Now process them in chronological order
    for (var i = 0; i < array_length(all_notes); i++) {
        var note_data = all_notes[i];
        var file_index = note_data.file_index;
        var note_index = note_data.note_index;
        var note = note_data.note;
        
        // Determine which lane this note should appear in
        var lane_index = self.GetLaneForNote(note, file_index);
        
        var key = string(file_index) + "_" + string(note_index);
        ds_map_add(self.tracked_notes_map, key, {
            file_index: file_index,
            note_index: note_index,
            hit: false,
            missed: false,
            lane: lane_index // Store the lane with the note
        });
    }


/// @function AnalyzeNotePattern(notes)
/// @description Analyze a sequence of notes to detect patterns
/// @param {array} notes - Array of note MIDIs to analyze
/// @returns {struct} Information about the detected pattern
static AnalyzeNotePattern = function(notes) {
    if (array_length(notes) < 2) return { type: "unknown", direction: 0 };
    
    var is_ascending = true;
    var is_descending = true;
    var is_alternating = true;
    var previous_diff = 0;
    var i;
    
    for (var i = 1; i < array_length(notes); i++) {
        var diff = notes[i] - notes[i-1];
        
        // Check direction
        if (diff < 0) is_ascending = false;
        if (diff > 0) is_descending = false;
        
        // Check if alternating pattern is broken
        if (i > 1) {
            if (sign(diff) == sign(previous_diff)) {
                is_alternating = false;
            }
        }
        
        previous_diff = diff;
    }
    
    // Determine pattern type
    var pattern_type = "unknown";
    var _direction = 0;
    
    if (is_ascending) {
        pattern_type = "scale";
        _direction = 1;
    } else if (is_descending) {
        pattern_type = "scale";
        _direction = -1;
    } else if (is_alternating) {
        pattern_type = "alternating";
        if (notes[1] > notes[0]) {
            _direction = 1;
        } else {
            _direction = -1;
        }
    } else {
        // Check for arpeggios or other patterns
        // This would need more sophisticated analysis
        pattern_type = "complex";
    }
    
    return {
        type: pattern_type,
        direction: _direction
    };
}
    
    /// @function Update()
    /// @description Update the rhythm game state
    static Update = function() {
        // Get current time for efficiency
        var _current_time = current_time / 1000;
        
        // Only update active notes list periodically for performance
        if (_current_time - self.last_update_time > self.update_frequency) {
            self.active_notes_need_update = true;
            self.last_update_time = _current_time;
        }
        
        // Update visual effects
        self.UpdateEffects();
        
        // Update screen shake
        if (self.shake_amount > 0) {
            self.shake_amount -= 0.5;
            if (self.shake_amount < 0) self.shake_amount = 0;
        }
        
        // Process player inputs and check for note hits
        self.CheckNoteHits();
        
        // Update active notes and check for missed notes
        if (self.active_notes_need_update) {
            self.UpdateActiveNotes();
            self.active_notes_need_update = false;
        }
        
        // Check for notes that were missed
        self.CheckMissedNotes();
    }
    
    /// @function UpdateActiveNotes()
    /// @description Update the list of notes that are currently active
    static UpdateActiveNotes = function() {
        // Clear the active notes list
        ds_list_clear(self.active_notes);
        
        // Get game track file index
        var game_track = self.midi_player.game_track;
        
        // Track indices to process
        var track_indices = [];
        
        // For drums (track 3), include all available drum tracks (3, 4, 5)
        if (game_track == 3) {
            // Add ALL drum tracks that exist
            if (3 < array_length(self.midi_player.midi_files)) 
                array_push(track_indices, 3); // Kick
            if (4 < array_length(self.midi_player.midi_files)) 
                array_push(track_indices, 4); // Snare
            if (5 < array_length(self.midi_player.midi_files)) 
                array_push(track_indices, 5); // Cymbals
        } else {
            // Just use the selected track for non-drum instruments
            array_push(track_indices, game_track);
        }
        
        // Process each relevant track
        for (var track_idx = 0; track_idx < array_length(track_indices); track_idx++) {
            var current_track = track_indices[track_idx];
            
            // Skip if this track doesn't exist
            if (current_track >= array_length(self.midi_player.midi_files)) {
                continue;
            }
            
            var midi_file = self.midi_player.midi_files[current_track];
            
            // For drums, always process all drum tracks when drum instrument is selected
            // For other instruments, only process if playing and not muted
            var should_process = false;
            
            if (game_track == 3) {
                // Always process drum tracks when drums are selected
                should_process = midi_file.is_playing;
            } else {
                // For other instruments, only process if playing and not muted
                should_process = midi_file.is_playing && !self.midi_player.muted_files[current_track];
            }
            
            if (should_process) {
                // Determine the visible time window
                var window_start = midi_file.current_time - self.hit_window;
                var window_end = midi_file.current_time + self.look_ahead;
                
                // Check each note
                for (var i = 0; i < array_length(midi_file.notes); i++) {
                    var note = midi_file.notes[i];
                    
                    // Skip notes that don't match the current difficulty level
                    if (note.note_type > self.midi_player.difficulty) continue;
                    
                    // Check if note is in the visible window
                    if (note.time >= window_start && note.time <= window_end) {
                        // Check if note has already been hit or missed
                        var key = string(current_track) + "_" + string(i);
                        var tracked = ds_map_find_value(self.tracked_notes_map, key);
                        
                        if (tracked != undefined && !tracked.hit && !tracked.missed) {
                            // Add to active notes list with all needed info
                            ds_list_add(self.active_notes, {
                                file_index: current_track,
                                note_index: i,
                                note: note,
                                tracked: tracked,
                                key: key
                            });
                        }
                    }
                }
            }
        }
    }
    
    /// @function UpdateEffects()
    /// @description Update all visual effects
    static UpdateEffects = function() {
        // Update hit effects
        for (var i = ds_list_size(self.hit_effects) - 1; i >= 0; i--) {
            var effect = ds_list_find_value(self.hit_effects, i);
            effect.life -= 1;
            
            if (effect.life <= 0) {
                ds_list_delete(self.hit_effects, i);
            }
        }
        
        // Update miss effects
        for (var i = ds_list_size(self.miss_effects) - 1; i >= 0; i--) {
            var effect = ds_list_find_value(self.miss_effects, i);
            effect.life -= 1;
            
            if (effect.life <= 0) {
                ds_list_delete(self.miss_effects, i);
            }
        }
        
        // Update rating effects
        for (var i = ds_list_size(self.rating_effects) - 1; i >= 0; i--) {
            var effect = ds_list_find_value(self.rating_effects, i);
            effect.life -= 1;
            effect.y -= 2; // Move up
            effect.alpha = effect.life / effect.max_life;
            
            if (effect.life <= 0) {
                ds_list_delete(self.rating_effects, i);
            }
        }
    }
    
    /// @function CheckNoteHits()
    /// @description Check for player inputs and note hits
    static CheckNoteHits = function() {
        // Check each lane for key presses
        for (var lane_index = 0; lane_index < array_length(self.lanes); lane_index++) {
            var lane = self.lanes[lane_index];
            
            // If the key for this lane was pressed
            if (keyboard_check_pressed(lane.key)) {
                var hit_something = false;
                
                // Find the closest note to hit in this lane
                var closest_note = undefined;
                var closest_time_diff = self.hit_window;
                var closest_file_index = -1;
                var closest_note_index = -1;
                var closest_key = "";
                
                // Check only active notes (much more efficient)
                var active_notes_count = ds_list_size(self.active_notes);
                for (var i = 0; i < active_notes_count; i++) {
                    var active_note_data = ds_list_find_value(self.active_notes, i);
                    var note = active_note_data.note;
                    var tracked = active_note_data.tracked;
                    
                    // Skip if not in the correct lane or already hit/missed
                    if (tracked.lane != lane_index || tracked.hit || tracked.missed) {
                        continue;
                    }
                    
                    // Get the MIDI file 
                    var file_index = active_note_data.file_index;
                    var midi_file = self.midi_player.midi_files[file_index];
                    
                    // Check if note is within hit window
                    var time_diff = abs(midi_file.current_time - note.time);
                    
                    if (time_diff < self.hit_window && time_diff < closest_time_diff) {
                        closest_note = note;
                        closest_time_diff = time_diff;
                        closest_file_index = file_index;
                        closest_note_index = active_note_data.note_index;
                        closest_key = active_note_data.key;
                    }
                }
                
                // If we found a note to hit
                if (closest_note != undefined) {
                    // Mark note as hit
                    var tracked = ds_map_find_value(self.tracked_notes_map, closest_key);
                    tracked.hit = true;
                    
                    // Calculate accuracy
                    var accuracy = 1.0 - (closest_time_diff / self.hit_window);
                    
                    // Register the hit with appropriate accuracy
                    self.RegisterHit(closest_note, accuracy, closest_file_index, lane_index);
                    hit_something = true;
                    
                    // Mark active notes for update on next frame
                    self.active_notes_need_update = true;
                }
                
                // If no hit was registered, show a miss effect
                if (!hit_something) {
                    self.RegisterMiss(lane_index);
                }
                
                // Add key press visual effect
                if (ds_list_size(self.hit_effects) < self.max_hit_effects) {
                    ds_list_add(self.hit_effects, {
                        x: lane.x,
                        y: self.hit_line_y,
                        radius: self.hit_circle_size,
                        color: hit_something ? lane.color : c_gray,
                        life: 10,
                        initial_radius: self.hit_circle_size
                    });
                }
            }
        }
    }
    
    /// @function CheckMissedNotes()
    /// @description Check for notes that were missed
    static CheckMissedNotes = function() {
        // Check only active notes (much more efficient)
        var active_notes_count = ds_list_size(self.active_notes);
        for (var i = 0; i < active_notes_count; i++) {
            var active_note_data = ds_list_find_value(self.active_notes, i);
            var note = active_note_data.note;
            var tracked = active_note_data.tracked;
            var file_index = active_note_data.file_index;
            
            // Skip notes already processed
            if (tracked.hit || tracked.missed) continue;
            
            // Get the MIDI file
            var midi_file = self.midi_player.midi_files[file_index];
            
            // If the note has passed the hit window and wasn't hit
            if (midi_file.current_time > note.time + self.hit_window) {
                // Mark as missed
                tracked.missed = true;
                
                // Register the miss
                var lane_index = tracked.lane;
                self.RegisterMiss(lane_index);
                
                // Add miss effect
                if (ds_list_size(self.miss_effects) < self.max_miss_effects) {
                    ds_list_add(self.miss_effects, {
                        text: "MISS",
                        alpha: 1.0,
                        life: 30,
                        scale: 1.0
                    });
                }
                
                // Add screen shake
                self.shake_amount = 5;
                
                // Reset combo
                self.combo = 0;
                
                // Mark active notes for update on next frame
                self.active_notes_need_update = true;
            }
        }
    }
    
    /// @function RegisterHit(note, accuracy, file_index, lane_index)
    /// @description Register a successful hit with accuracy
    /// @param {struct} note - The note that was hit
    /// @param {real} accuracy - How accurate the hit was (0-1)
    /// @param {real} file_index - Which file the note is from
    /// @param {real} lane_index - Which lane the note was in
    static RegisterHit = function(note, accuracy, file_index, lane_index) {
        // Determine rating based on accuracy
        var rating = "";
        var points = 0;
        var add_to_combo = false;
        
        if (accuracy >= self.perfect_threshold) {
            rating = "PERFECT";
            points = 1000;
            add_to_combo = true;
            self.accuracy_ratings.perfect++;
        } else if (accuracy >= self.great_threshold) {
            rating = "GREAT";
            points = 700;
            add_to_combo = true;
            self.accuracy_ratings.great++;
        } else if (accuracy >= self.good_threshold) {
            rating = "GOOD";
            points = 400;
            add_to_combo = true;
            self.accuracy_ratings.good++;
        } else if (accuracy >= self.okay_threshold) {
            rating = "OKAY";
            points = 200;
            self.accuracy_ratings.okay++;
        } else {
            rating = "POOR";
            points = 50;
            self.accuracy_ratings.poor++;
        }
        
        // Apply score multiplier based on difficulty
        var difficultyMultiplier = self.midi_player.difficulty + 1; // 1x for Easy, 2x for Medium, etc.
        
        // Add difficulty bonus
        if (add_to_combo) {
            self.combo++;
            if (self.combo > self.max_combo) {
                self.max_combo = self.combo;
            }
            
            // Additional combo bonus
            if (self.combo > 10) {
                difficultyMultiplier *= 1.0 + (self.combo * 0.01); // 1% per combo point over 10
            }
        } else {
            self.combo = 0;
        }
        
        // Calculate final score
        var final_score = round(points * difficultyMultiplier);
        self.score += final_score;
        
        // Add rating effect
        if (ds_list_size(self.rating_effects) < self.max_rating_effects) {
            var lane = self.lanes[lane_index];
            ds_list_add(self.rating_effects, {
                text: rating,
                x: lane.x,
                y: self.hit_line_y - 20,
                color: lane.color,
                alpha: 1.0,
                life: 30,
                max_life: 30,
                points: "+" + string(final_score)
            });
        }
    }
    
    /// @function RegisterMiss(lane_index)
    /// @description Register a missed note
    /// @param {real} lane_index - Which lane the miss occurred in
    static RegisterMiss = function(lane_index) {
        // Reset combo
        self.combo = 0;
        
        // Increment miss counter
        self.accuracy_ratings.miss++;
        
        // Add miss effect to the specific lane
        if (ds_list_size(self.rating_effects) < self.max_rating_effects) {
            var lane = self.lanes[lane_index];
            ds_list_add(self.rating_effects, {
                text: "MISS",
                x: lane.x,
                y: self.hit_line_y - 20,
                color: c_red,
                alpha: 1.0,
                life: 30,
                max_life: 30,
                points: ""
            });
        }
    }
    
    /// @function Draw()
    /// @description Draw the rhythm game
    static Draw = function() {
        // Apply screen shake
        var shake_x = 0;
        var shake_y = 0;
        
        if (self.shake_amount > 0) {
            shake_x = random_range(-self.shake_amount, self.shake_amount);
            shake_y = random_range(-self.shake_amount, self.shake_amount);
        }
        
        // Draw lanes
        for (var i = 0; i < array_length(self.lanes); i++) {
            var lane = self.lanes[i];
            
            // Draw lane background
            draw_set_color(c_dkgray);
            draw_set_alpha(0.7);
            draw_rectangle(
                lane.x - (self.lane_width / 2) + shake_x, 
                50 + shake_y, 
                lane.x + (self.lane_width / 2) + shake_x, 
                self.hit_line_y + shake_y, 
                false
            );
            draw_set_alpha(1.0);
            
            // Draw hit circle
            draw_set_color(lane.color);
            draw_circle(
                lane.x + shake_x, 
                self.hit_line_y + shake_y, 
                self.hit_circle_size, 
                true
            );
            
            // Draw key label
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_white);
            
            // If player is playing drums, show drum component names
            if (self.midi_player.game_track == 3) {
                self.DrawFancyText(
                    lane.drum_text, 
                    lane.x + shake_x, 
                    self.hit_line_y - 25 + shake_y  // Slightly above the key
                );
            }
            
            self.DrawFancyText(
                lane.key_text, 
                lane.x + shake_x, 
                self.hit_line_y + shake_y
            );
        }
        
        // Draw only the active notes (much more efficient)
        var active_notes_count = ds_list_size(self.active_notes);
        for (var i = 0; i < active_notes_count; i++) {
            var active_note_data = ds_list_find_value(self.active_notes, i);
            var note = active_note_data.note;
            var tracked = active_note_data.tracked;
            var file_index = active_note_data.file_index;
            
            // Skip if already hit
            if (tracked.hit) continue;
            
            // Get the MIDI file
            var midi_file = self.midi_player.midi_files[file_index];
            
            // Get time difference
            var time_diff = note.time - midi_file.current_time;
            
            // Draw note if it's in our look-ahead window
            if (time_diff >= -self.hit_window && time_diff <= self.look_ahead) {
                // Get the lane
                var lane_index = tracked.lane;
                var lane = self.lanes[lane_index];
                
                // Calculate y position based on time difference (top to bottom)
                var progress = 1.0 - (time_diff / self.look_ahead);
                var note_y = 50 + progress * (self.hit_line_y - 50);
                
                // Determine color based on note type (difficulty)
                var note_color = lane.color;
                var border_color = c_black;
                
                // Visual distinction for different note types
                var note_size_multiplier = 1.0;
                
                if (note.note_type == 0) { // Whole notes (Easy)
                    note_size_multiplier = 1.3;
                    border_color = c_white;
                } else if (note.note_type == 1) { // Half notes (Medium)
                    note_size_multiplier = 1.15;
                    border_color = c_lime;
                } else if (note.note_type == 2) { // Quarter notes (Hard)
                    note_size_multiplier = 1.0;
                    border_color = c_yellow;
                } else { // Other notes (Expert)
                    note_size_multiplier = 0.9;
                    border_color = c_red;
                }
                
                // Apply alpha based on track (for multi-track visualization)
                var note_alpha = 1.0;
                
                // Draw note
                draw_set_alpha(note_alpha);
                draw_set_color(note_color);
                draw_circle(
                    lane.x + shake_x, 
                    note_y + shake_y, 
                    self.note_size * note_size_multiplier, 
                    false
                );
                
                // Draw border
                draw_set_color(border_color);
                draw_circle(
                    lane.x + shake_x, 
                    note_y + shake_y, 
                    self.note_size * note_size_multiplier, 
                    true
                );
                
                draw_set_alpha(1.0);
            }
        }
        
        // Draw hit effects
        var hit_effects_count = ds_list_size(self.hit_effects);
        for (var i = 0; i < hit_effects_count; i++) {
            var effect = ds_list_find_value(self.hit_effects, i);
            
            // Calculate effect size and alpha
            var progress = effect.life / 10;
            var current_radius = effect.initial_radius * (2.0 - progress);
            var alpha = progress;
            
            // Draw effect
            draw_set_alpha(alpha);
            draw_set_color(effect.color);
            draw_circle(
                effect.x + shake_x, 
                effect.y + shake_y, 
                current_radius, 
                true
            );
            draw_set_alpha(1.0);
        }
        
        // Draw rating effects
        var rating_effects_count = ds_list_size(self.rating_effects);
        for (var i = 0; i < rating_effects_count; i++) {
            var effect = ds_list_find_value(self.rating_effects, i);
            
            // Draw rating text
            draw_set_alpha(effect.alpha);
            draw_set_color(effect.color);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text_transformed(
                effect.x + shake_x, 
                effect.y + shake_y, 
                effect.text, 
                1.5, 1.5, 0
            );
            
            // Draw points text if present
            if (effect.points != "") {
                draw_text_transformed(
                    effect.x + shake_x, 
                    effect.y + 20 + shake_y, 
                    effect.points, 
                    1.0, 1.0, 0
                );
            }
            
            draw_set_alpha(1.0);
        }
        
        // Draw miss effects (large text in center of screen)
        var miss_effects_count = ds_list_size(self.miss_effects);
        for (var i = 0; i < miss_effects_count; i++) {
            var effect = ds_list_find_value(self.miss_effects, i);
            
            // Calculate effect size and alpha
            var progress = effect.life / 30;
            var scale = 2.0 + (1.0 - progress) * 3.0;
            var alpha = progress;
            
            // Only draw briefly
            if (progress > 0.7) {
                // Draw effect
                draw_set_alpha(alpha);
                draw_set_color(c_red);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text_transformed(
                    room_width / 2 + shake_x, 
                    room_height / 2 + shake_y, 
                    effect.text, 
                    scale, scale, 0
                );
                draw_set_alpha(1.0);
            }
        }
        
        // Draw HUD
        self.DrawHUD();
    }
    
    /// @function DrawHUD()
    /// @description Draw the game HUD (score, combo, etc.)
    static DrawHUD = function() {
        // Draw score
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_text(20, 20, "Score: " + string(self.score));
        
        // Draw combo
        var combo_color = c_white;
        if (self.combo >= 50) combo_color = c_fuchsia;
        else if (self.combo >= 30) combo_color = c_yellow;
        else if (self.combo >= 10) combo_color = c_aqua;
        
        draw_set_color(combo_color);
        draw_set_halign(fa_right);
        draw_text(room_width - 20, 20, "Combo: " + string(self.combo));
        
        // Draw max combo
        draw_set_color(c_gray);
        draw_text(room_width - 20, 40, "Max: " + string(self.max_combo));
        
        // Draw accuracy stats
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        var total_notes = self.accuracy_ratings.perfect + 
                         self.accuracy_ratings.great + 
                         self.accuracy_ratings.good + 
                         self.accuracy_ratings.okay + 
                         self.accuracy_ratings.poor + 
                         self.accuracy_ratings.miss;
        
        if (total_notes > 0) {
            var accuracy = (self.accuracy_ratings.perfect * 1.0 + 
                           self.accuracy_ratings.great * 0.9 + 
                           self.accuracy_ratings.good * 0.7 + 
                           self.accuracy_ratings.okay * 0.5 + 
                           self.accuracy_ratings.poor * 0.2) / total_notes;
            
            draw_text(20, 40, "Accuracy: " + string_format(accuracy * 100, 3, 1) + "%");
        }
        
        // Draw difficulty
        draw_set_halign(fa_center);
        draw_set_color(c_lime);
        draw_text(room_width / 2, 20, "Difficulty: " + self.midi_player.difficulty_names[self.midi_player.difficulty]);
        
        // Draw active track info
        draw_set_color(c_aqua);
        
        // For drums, show "Drums" instead of individual drum track
        if (self.midi_player.game_track == 3) {
            draw_text(room_width / 2, 40, "Playing: Drums");
        } 
        else if (self.midi_player.game_track >= 0 && self.midi_player.game_track < array_length(self.midi_player.midi_files)) {
            var track_name = self.midi_player.midi_files[self.midi_player.game_track].filename;
            draw_text(room_width / 2, 40, "Playing: " + track_name);
        }
    }
    
    /// @function DrawFancyText(text, x, y)
    /// @description Draw fancy text with shadow and border
    /// @param {string} text - The text to draw
    /// @param {real} x - X position
    /// @param {real} y - Y position
    static DrawFancyText = function(text, x, y) {
        // Draw shadow
        draw_set_color(c_black);
        draw_set_alpha(0.5);
        draw_text(x + 2, y + 2, text);
        
        // Draw text
        draw_set_alpha(1.0);
        draw_set_color(c_white);
        draw_text(x, y, text);
    }
    
    /// @function Clean()
    /// @description Clean up resources
    static Clean = function() {
        // Clean up data structures
        ds_list_destroy(self.hit_effects);
        ds_list_destroy(self.miss_effects);
        ds_list_destroy(self.rating_effects);
        ds_map_destroy(self.tracked_notes_map);
        ds_list_destroy(self.active_notes);
    }
    
    // Initialize the rhythm game
    self.Initialize();
}