/// @function Song_Collection(name, metadata)
/// @description Creates a new song collection that manages related MIDI files
/// @param {string} name - The name of the song collection
/// @param {struct} metadata - Optional metadata about the song (artist, genre, etc)
function Song_Collection(name, metadata = {}) constructor {
    // Basic properties
    self.name = name;
    self.metadata = metadata;
    self.files = {}; // Track files by type
    self.loaded = false; // Track if files are loaded
    self.instrument_difficulties = {
        bass: -1,
        vocals: -1,
        leads: -1,
        drums: -1,
        other: -1
    };
    
    // File paths
    self.file_paths = {
        bass: "",
        vocals: "",
        leads: "", 
        drums_kick: "",
        drums_snare: "",
        drums_cymbals: "",
        drums_other: ""
    };
    
    // Track indices
    self.track_indices = {
        bass: -1,
        vocals: -1,
        leads: -1,
        drums_kick: -1,
        drums_snare: -1,
        drums_cymbals: -1,
        drums_other: -1
    };
    
    /// @function SetFilePath(instrument_type, file_path, difficulty)
    /// @description Sets the file path for a particular instrument type
    /// @param {string} instrument_type - The type of instrument ("bass", "vocals", "leads", "drums_kick", etc)
    /// @param {string} file_path - Path to the MIDI JSON file
    /// @param {real} difficulty - The difficulty level of this track (0-3)
    /// @returns {bool} Whether the path was successfully set
    static SetFilePath = function(instrument_type, file_path, difficulty) {
        if (variable_struct_exists(self.file_paths, instrument_type)) {
            self.file_paths[$ instrument_type] = file_path;
            
            // Set difficulty for the main instrument category
            var main_instrument = instrument_type;
            if (string_pos("drums_", instrument_type) == 1) {
                main_instrument = "drums";
            }
            
            // Only update difficulty if higher than current or not set yet
            if (self.instrument_difficulties[$ main_instrument] < difficulty) {
                self.instrument_difficulties[$ main_instrument] = difficulty;
            }
            
            return true;
        }
        return false;
    }
    
    /// @function LoadFiles(midi_player)
    /// @description Loads all song files into the MIDI player
    /// @param {struct} midi_player - The MIDI player to load files into
    /// @returns {bool} Whether all required files were loaded successfully
    static LoadFiles = function(midi_player) {
        var success = true;
        
        // Clear any existing files in the player
        midi_player.StopAll();
        midi_player.midi_files = [];
        midi_player.muted_files = [];
        midi_player.track_types = [];
        
        // Reset track indices
        struct_foreach(self.track_indices, function(key, value) {
            self.track_indices[$ key] = -1;
        });
        
        // Map file types to track types
        var track_type_map = {
            bass: 0,
            vocals: 1,
            leads: 2,
            drums_kick: 3,
            drums_snare: 4,
            drums_cymbals: 5,
            drums_other: 6
        };
        
        // Load each file if path exists
        struct_foreach(self.file_paths, function(key, file_path) {
            if (file_path != "") {
                var track_type = track_type_map[$ key];
                var file_index = midi_player.AddMidiFile(file_path, track_type);
                
                if (file_index >= 0) {
                    self.track_indices[$ key] = file_index;
                } else {
                    show_debug_message("Failed to load " + key + " track: " + file_path);
                    success = false;
                }
            }
        });
        
        self.loaded = success;
        return success;
    }
    
    /// @function HasRequiredTracks()
    /// @description Checks if this song has the minimum required tracks
    /// @returns {bool} Whether the song has the minimum required tracks
    static HasRequiredTracks = function() {
        // Define what's required based on your game's needs
        // For example, we might require at least one instrument track
        var has_instrument = (
            self.file_paths.bass != "" || 
            self.file_paths.vocals != "" || 
            self.file_paths.leads != ""
        );
        
        // For drums, we need at least kick and snare
        var has_drums = (
            self.file_paths.drums_kick != "" && 
            self.file_paths.drums_snare != ""
        );
        
        // Return true if we have either type of track
        return has_instrument || has_drums;
    }
    
    /// @function CanPlayInstrument(instrument_type)
    /// @description Checks if a specific instrument can be played
    /// @param {string} instrument_type - The type of instrument to check
    /// @returns {bool} Whether the instrument is available
    static CanPlayInstrument = function(instrument_type) {
        switch(instrument_type) {
            case "bass":
                return self.file_paths.bass != "";
            case "vocals":
                return self.file_paths.vocals != "";
            case "leads":
                return self.file_paths.leads != "";
            case "drums":
                // For drums, we need at minimum the kick and snare
                return self.file_paths.drums_kick != "" && self.file_paths.drums_snare != "";
            default:
                return false;
        }
    }
    
    /// @function GetInstrumentDifficulty(instrument_type)
    /// @description Gets the difficulty level of a specific instrument
    /// @param {string} instrument_type - The type of instrument to check
    /// @returns {real} The difficulty level (0-3) or -1 if not available
    static GetInstrumentDifficulty = function(instrument_type) {
        if (variable_struct_exists(self.instrument_difficulties, instrument_type)) {
            return self.instrument_difficulties[$ instrument_type];
        }
        return -1;
    }
    
    /// @function SelectInstrument(midi_player, instrument_type)
    /// @description Sets up the MIDI player to play a specific instrument
    /// @param {struct} midi_player - The MIDI player
    /// @param {string} instrument_type - The type of instrument to select
    /// @returns {bool} Whether the instrument was successfully selected
    static SelectInstrument = function(midi_player, instrument_type) {
        if (!self.loaded) {
            show_debug_message("Song not loaded yet");
            return false;
        }
        
        // Set up MIDI player based on instrument type
        switch(instrument_type) {
            case "bass":
                if (self.track_indices.bass >= 0) {
                    midi_player.SetGameTrack(self.track_indices.bass);
                    return true;
                }
                break;
                
            case "vocals":
                if (self.track_indices.vocals >= 0) {
                    midi_player.SetGameTrack(self.track_indices.vocals);
                    return true;
                }
                break;
                
            case "leads":
                if (self.track_indices.leads >= 0) {
                    midi_player.SetGameTrack(self.track_indices.leads);
                    return true;
                }
                break;
                
            case "drums":
                // For drums, we set to the kick drum track as the main track
                if (self.track_indices.drums_kick >= 0) {
                    midi_player.SetGameTrack(self.track_indices.drums_kick);
                    return true;
                }
                break;
                
            default:
                return false;
        }
        
        return false;
    }
}

/// @function Song_Manager()
/// @description Creates a manager for multiple song collections
function Song_Manager() constructor {
    self.songs = [];
    self.current_song_index = -1;
    
    /// @function AddSong(song_collection)
    /// @description Adds a song collection to the manager
    /// @param {struct} song_collection - The song collection to add
    /// @returns {real} The index of the added song
    static AddSong = function(song_collection) {
        var index = array_length(self.songs);
        array_push(self.songs, song_collection);
        
        // Set as current song if this is the first one
        if (index == 0) {
            self.current_song_index = 0;
        }
        
        return index;
    }
    
    /// @function GetCurrentSong()
    /// @description Gets the currently selected song
    /// @returns {struct} The current song collection or undefined if none
    static GetCurrentSong = function() {
        if (self.current_song_index >= 0 && self.current_song_index < array_length(self.songs)) {
            return self.songs[self.current_song_index];
        }
        return undefined;
    }
    
    /// @function SelectSong(index)
    /// @description Selects a song by index
    /// @param {real} index - The index of the song to select
    /// @returns {bool} Whether the song was successfully selected
    static SelectSong = function(index) {
        if (index >= 0 && index < array_length(self.songs)) {
            self.current_song_index = index;
            return true;
        }
        return false;
    }
    
    /// @function LoadCurrentSong(midi_player)
    /// @description Loads the currently selected song into the MIDI player
    /// @param {struct} midi_player - The MIDI player to load into
    /// @returns {bool} Whether the song was successfully loaded
    static LoadCurrentSong = function(midi_player) {
        var current_song = self.GetCurrentSong();
        if (current_song != undefined) {
            return current_song.LoadFiles(midi_player);
        }
        return false;
    }
}