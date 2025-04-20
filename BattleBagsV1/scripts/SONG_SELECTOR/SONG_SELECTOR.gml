/// @function Song_Selector(song_manager, midi_player, rhythm_game)
/// @description Creates a song selection interface
/// @param {struct} song_manager - The song manager
/// @param {struct} midi_player - The MIDI player
/// @param {struct} rhythm_game - The rhythm game
function Song_Selector(song_manager, midi_player, rhythm_game) constructor {
    self.song_manager = song_manager;
    self.midi_player = midi_player;
    self.rhythm_game = rhythm_game;
    
    // UI state
    self.visible = false;
    self.selected_song_index = 0;
    self.selected_instrument = "drums"; // Default to drums
    self.selected_difficulty = 1; // Default to medium
    self.transition = 0; // 0-1 for animation
    self.scroll_offset = 0;
    
    // UI layout
    self.padding = 20;
    self.song_btn_height = 60;
    self.instrument_btn_width = 150;
    self.instrument_btn_height = 40;
    self.difficulty_btn_width = 100;
    self.difficulty_btn_height = 30;
    self.button_spacing = 10;
    
    // Available instruments
    self.instruments = [
        { name: "Bass", id: "bass", color: c_aqua },
        { name: "Vocals", id: "vocals", color: c_fuchsia },
        { name: "Leads", id: "leads", color: c_yellow },
        { name: "Drums", id: "drums", color: c_lime }
    ];
    
    // Difficulty options
    self.difficulties = [
        { name: "Easy", level: 0, color: c_green },
        { name: "Medium", level: 1, color: c_yellow },
        { name: "Hard", level: 2, color: c_orange },
        { name: "Expert", level: 3, color: c_red }
    ];
    
    // Sound effects for navigation
    self.sfx = {
        hover: undefined, // Set in your Create event
        select: undefined, // Set in your Create event
        back: undefined    // Set in your Create event
    };
    
    /// @function Show()
    /// @description Makes the song selector visible
    static Show = function() {
        self.visible = true;
        self.transition = 0;
        
        // Pause current music if playing
        if (self.midi_player.active_file >= 0) {
            for (var i = 0; i < array_length(self.midi_player.midi_files); i++) {
                if (self.midi_player.midi_files[i].is_playing) {
                    self.midi_player.StopFile(i);
                }
            }
        }
    }
    
    /// @function Hide()
    /// @description Hides the song selector
    static Hide = function() {
        self.visible = false;
    }
    
    /// @function Update()
    /// @description Updates the song selector
    static Update = function() {
        if (!self.visible) return;
        
        // Update animation
        if (self.transition < 1) {
            self.transition += 0.1;
            if (self.transition > 1) self.transition = 1;
        }
        
        // Handle keyboard navigation
        if (keyboard_check_pressed(vk_escape)) {
            self.Hide();
            return;
        }
        
        var song_count = array_length(self.song_manager.songs);
        
        // Song navigation
        if (keyboard_check_pressed(vk_up)) {
            self.selected_song_index = max(0, self.selected_song_index - 1);
            // Play sound
            if (self.sfx.hover != undefined) audio_play_sound(self.sfx.hover, 1, false);
        }
        
        if (keyboard_check_pressed(vk_down)) {
            self.selected_song_index = min(song_count - 1, self.selected_song_index + 1);
            // Play sound
            if (self.sfx.hover != undefined) audio_play_sound(self.sfx.hover, 1, false);
        }
        
        // Mouse handling
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        var clicked = mouse_check_button_pressed(mb_left);
        
        // Calculate UI positions
        var center_x = display_get_gui_width() / 2;
        var start_y = display_get_gui_height() * 0.15;
        var available_height = display_get_gui_height() - start_y - self.padding * 2;
        var visible_songs = floor(available_height / (self.song_btn_height + self.button_spacing));
        
        // Adjust scroll offset based on selection
        var target_offset = max(0, self.selected_song_index - floor(visible_songs / 2));
        self.scroll_offset = lerp(self.scroll_offset, target_offset, 0.2);
        
        // Calculate song list area
        var song_list_width = display_get_gui_width() * 0.4;
        var song_list_x = center_x - song_list_width / 2;
        var song_list_y = start_y;
        
        // Draw and handle song list
        for (var i = 0; i < song_count; i++) {
            var song = self.song_manager.songs[i];
            var item_y = song_list_y + (i - self.scroll_offset) * (self.song_btn_height + self.button_spacing);
            
            // Skip if out of view
            if (item_y < start_y - self.song_btn_height || item_y > display_get_gui_height() - self.padding) {
                continue;
            }
            
            // Check for mouse over and click
            var is_selected = (i == self.selected_song_index);
            var is_hover = point_in_rectangle(mx, my, song_list_x, item_y, song_list_x + song_list_width, item_y + self.song_btn_height);
            
            if (is_hover && clicked) {
                self.selected_song_index = i;
                // Play sound
                if (self.sfx.select != undefined) audio_play_sound(self.sfx.select, 1, false);
            }
        }
        
        // Handle instrument selection
        var instrument_btns_y = start_y + visible_songs * (self.song_btn_height + self.button_spacing) + self.padding * 2;
        var instrument_btns_x = center_x - (self.instrument_btn_width * 2 + self.button_spacing);
        
        for (var i = 0; i < array_length(self.instruments); i++) {
            var inst = self.instruments[i];
            var btn_x = instrument_btns_x + (i % 2) * (self.instrument_btn_width + self.button_spacing);
            var btn_y = instrument_btns_y + floor(i / 2) * (self.instrument_btn_height + self.button_spacing);
            
            var is_hover = point_in_rectangle(mx, my, btn_x, btn_y, btn_x + self.instrument_btn_width, btn_y + self.instrument_btn_height);
            var current_song = self.song_manager.GetCurrentSong();
            var is_available = (current_song != undefined && current_song.CanPlayInstrument(inst.id));
            
            if (is_hover && is_available && clicked) {
                self.selected_instrument = inst.id;
                // Play sound
                if (self.sfx.select != undefined) audio_play_sound(self.sfx.select, 1, false);
            }
        }
        
        // Handle difficulty selection
        var difficulty_btns_y = instrument_btns_y + 2 * (self.instrument_btn_height + self.button_spacing) + self.padding;
        var difficulty_btns_x = center_x - (self.difficulty_btn_width * 2 + self.button_spacing);
        
        for (var i = 0; i < array_length(self.difficulties); i++) {
            var diff = self.difficulties[i];
            var btn_x = difficulty_btns_x + (i % 4) * (self.difficulty_btn_width + self.button_spacing/2);
            var btn_y = difficulty_btns_y;
            
            var is_hover = point_in_rectangle(mx, my, btn_x, btn_y, btn_x + self.difficulty_btn_width, btn_y + self.difficulty_btn_height);
            
            if (is_hover && clicked) {
                self.selected_difficulty = diff.level;
                // Play sound
                if (self.sfx.select != undefined) audio_play_sound(self.sfx.select, 1, false);
            }
        }
        
        // Handle play button
        var play_btn_width = 200;
        var play_btn_height = 50;
        var play_btn_x = center_x - play_btn_width / 2;
        var play_btn_y = difficulty_btns_y + self.difficulty_btn_height + self.padding * 2;
        
        var play_hover = point_in_rectangle(mx, my, play_btn_x, play_btn_y, play_btn_x + play_btn_width, play_btn_y + play_btn_height);
        
        if (play_hover && clicked) {
            // Start the game with selected settings
            self.StartGame();
        }
    }
    
    /// @function Draw()
    /// @description Draws the song selector
    static Draw = function() {
        if (!self.visible) return;
        
        // Apply animation
        var offset_y = (1 - self.transition) * display_get_gui_height();
        
        // Draw darkened background
        draw_set_alpha(0.8 * self.transition);
        draw_set_color(c_black);
        draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
        draw_set_alpha(1);
        
        // Set up text drawing
        draw_set_font(-1); // Replace with your font if available (fnt_menu)
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        // Draw header
        var header_y = display_get_gui_height() * 0.08 + offset_y;
        draw_set_color(c_white);
        draw_text_transformed(display_get_gui_width() / 2, header_y, "SONG SELECT", 2, 2, 0);
        
        // Calculate UI positions
        var center_x = display_get_gui_width() / 2;
        var start_y = display_get_gui_height() * 0.15 + offset_y;
        var available_height = display_get_gui_height() - start_y - self.padding * 2;
        var visible_songs = floor(available_height / (self.song_btn_height + self.button_spacing));
        
        // Song list area
        var song_list_width = display_get_gui_width() * 0.4;
        var song_list_x = center_x - song_list_width / 2;
        var song_list_y = start_y;
        
        // Draw song list background
        draw_set_color(c_dkgray);
        draw_set_alpha(0.6);
        draw_rectangle(song_list_x - self.padding, song_list_y - self.padding, 
                      song_list_x + song_list_width + self.padding,
                      song_list_y + visible_songs * (self.song_btn_height + self.button_spacing),
                      false);
        draw_set_alpha(1.0);
        
        // Draw song list
        var song_count = array_length(self.song_manager.songs);
        for (var i = 0; i < song_count; i++) {
            var song = self.song_manager.songs[i];
            var item_y = song_list_y + (i - self.scroll_offset) * (self.song_btn_height + self.button_spacing);
            
            // Skip if out of view
            if (item_y < start_y - self.song_btn_height || item_y > display_get_gui_height() - self.padding) {
                continue;
            }
            
            // Draw song button
            var is_selected = (i == self.selected_song_index);
            
            // Button background
            draw_set_color(is_selected ? c_navy : c_black);
            draw_set_alpha(0.8);
            draw_rectangle(song_list_x, item_y, song_list_x + song_list_width, item_y + self.song_btn_height, false);
            
            // Button outline
            draw_set_color(is_selected ? c_white : c_gray);
            draw_set_alpha(1.0);
            draw_rectangle(song_list_x, item_y, song_list_x + song_list_width, item_y + self.song_btn_height, true);
            
            // Song name and metadata
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_color(is_selected ? c_white : c_ltgray);
            draw_text(song_list_x + self.padding, item_y + self.padding, song.name);
            
            // Draw song metadata if available
            if (variable_struct_exists(song.metadata, "artist")) {
                draw_set_color(c_gray);
                draw_set_font(-1); // Smaller font
                draw_text(song_list_x + self.padding, item_y + self.padding + 20, "by " + song.metadata.artist);
                draw_set_font(-1); // Reset font
            }
            
            // Draw instrument icons for available instruments
            draw_set_halign(fa_right);
            var icon_x = song_list_x + song_list_width - self.padding;
            var icon_y = item_y + self.song_btn_height / 2;
            var icon_spacing = 20;
            
            for (var j = array_length(self.instruments) - 1; j >= 0; j--) {
                var inst = self.instruments[j];
                var is_available = song.CanPlayInstrument(inst.id);
                
                draw_set_color(is_available ? inst.color : c_dkgray);
                draw_set_alpha(is_available ? 1.0 : 0.3);
                
                // Draw instrument icon (simplified)
                draw_circle(icon_x, icon_y, 8, false);
                
                icon_x -= icon_spacing;
            }
            
            draw_set_alpha(1.0);
        }
        
        // Reset text alignment
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        // Draw instrument selection section
        var instrument_section_y = start_y + visible_songs * (self.song_btn_height + self.button_spacing) + self.padding;
        draw_set_color(c_white);
        draw_text(center_x, instrument_section_y, "SELECT INSTRUMENT");
        
        // Draw instrument buttons
        var instrument_btns_y = instrument_section_y + self.padding;
        var instrument_btns_x = center_x - (self.instrument_btn_width * 2 + self.button_spacing);
        
        for (var i = 0; i < array_length(self.instruments); i++) {
            var inst = self.instruments[i];
            var btn_x = instrument_btns_x + (i % 2) * (self.instrument_btn_width + self.button_spacing);
            var btn_y = instrument_btns_y + floor(i / 2) * (self.instrument_btn_height + self.button_spacing);
            
            var is_selected = (inst.id == self.selected_instrument);
            var current_song = self.song_manager.GetCurrentSong();
            var is_available = (current_song != undefined && current_song.CanPlayInstrument(inst.id));
            
            // Button background
            draw_set_color(is_selected ? inst.color : c_dkgray);
            draw_set_alpha(is_available ? 0.8 : 0.3);
            draw_rectangle(btn_x, btn_y, btn_x + self.instrument_btn_width, btn_y + self.instrument_btn_height, false);
            
            // Button outline
            draw_set_color(is_selected ? c_white : c_gray);
            draw_set_alpha(is_available ? 1.0 : 0.3);
            draw_rectangle(btn_x, btn_y, btn_x + self.instrument_btn_width, btn_y + self.instrument_btn_height, true);
            
            // Instrument name
            draw_set_color(is_selected ? c_black : c_white);
            draw_text(btn_x + self.instrument_btn_width / 2, btn_y + self.instrument_btn_height / 2, inst.name);
            
            // Show difficulty if available
            if (current_song != undefined) {
                var diff_level = current_song.GetInstrumentDifficulty(inst.id);
                if (diff_level >= 0 && is_available) {
                    draw_set_color(self.difficulties[diff_level].color);
                    draw_set_alpha(0.8);
                    draw_circle(btn_x + self.instrument_btn_width - 10, btn_y + 10, 5, false);
                    draw_set_alpha(1.0);
                }
            }
        }
        
        draw_set_alpha(1.0);
        
        // Draw difficulty selection
        var difficulty_section_y = instrument_btns_y + 2 * (self.instrument_btn_height + self.button_spacing) + self.padding;
        draw_set_color(c_white);
        draw_text(center_x, difficulty_section_y, "SELECT DIFFICULTY");
        
        // Draw difficulty buttons
        var difficulty_btns_y = difficulty_section_y + self.padding;
        var difficulty_btns_x = center_x - ((self.difficulty_btn_width * array_length(self.difficulties)) + 
                                          (self.button_spacing * (array_length(self.difficulties) - 1))) / 2;
        
        for (var i = 0; i < array_length(self.difficulties); i++) {
            var diff = self.difficulties[i];
            var btn_x = difficulty_btns_x + i * (self.difficulty_btn_width + self.button_spacing);
            var btn_y = difficulty_btns_y;
            
            var is_selected = (diff.level == self.selected_difficulty);
            
            // Button background
            draw_set_color(is_selected ? diff.color : c_dkgray);
            draw_set_alpha(0.8);
            draw_rectangle(btn_x, btn_y, btn_x + self.difficulty_btn_width, btn_y + self.difficulty_btn_height, false);
            
            // Button outline
            draw_set_color(is_selected ? c_white : c_gray);
            draw_set_alpha(1.0);
            draw_rectangle(btn_x, btn_y, btn_x + self.difficulty_btn_width, btn_y + self.difficulty_btn_height, true);
            
            // Difficulty name
            draw_set_color(is_selected ? c_black : c_white);
            draw_text(btn_x + self.difficulty_btn_width / 2, btn_y + self.difficulty_btn_height / 2, diff.name);
        }
        
        // Draw play button
        var play_btn_width = 200;
        var play_btn_height = 50;
        var play_btn_x = center_x - play_btn_width / 2;
        var play_btn_y = difficulty_btns_y + self.difficulty_btn_height + self.padding * 2;
        
        // Get current song and check if it's playable
        var current_song = self.song_manager.GetCurrentSong();
        var can_play = (current_song != undefined && current_song.CanPlayInstrument(self.selected_instrument));
        
        // Button background
        draw_set_color(can_play ? c_lime : c_dkgray);
        draw_set_alpha(can_play ? 0.8 : 0.3);
        draw_rectangle(play_btn_x, play_btn_y, play_btn_x + play_btn_width, play_btn_y + play_btn_height, false);
        
        // Button outline
        draw_set_color(can_play ? c_white : c_gray);
        draw_set_alpha(can_play ? 1.0 : 0.3);
        draw_rectangle(play_btn_x, play_btn_y, play_btn_x + play_btn_width, play_btn_y + play_btn_height, true);
        
        // Button text
        draw_set_color(c_black);
        draw_text_transformed(play_btn_x + play_btn_width / 2, play_btn_y + play_btn_height / 2, "PLAY", 1.5, 1.5, 0);
        
        draw_set_alpha(1.0);
        
        // Draw instructions
        var instructions_y = play_btn_y + play_btn_height + self.padding;
        draw_set_color(c_gray);
        draw_set_font(-1); // Smaller font
        draw_text(center_x, instructions_y, "Arrow Keys: Navigate   |   Mouse: Select   |   Esc: Back");
        draw_set_font(-1); // Reset font
	}
}