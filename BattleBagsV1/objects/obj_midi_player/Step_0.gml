/// @description
// Only update MIDI playback if playing
    if (global.midi_is_playing) {
        midi_update();
    }
    
	if (keyboard_check_pressed(ord("Q")))
			{
				if (current_sound < sound_array_length)
				{
					current_sound++;
				}
				else {
					current_sound = 0;
				}
			}
			
			global.midi_base_sound = sound_array[current_sound];

    // Check for button clicks
    if (mouse_check_button_pressed(mb_left)) {
        // Load button
        if (point_in_rectangle(mouse_x, mouse_y, btn_load_x, btn_load_y, 
                              btn_load_x + btn_load_width, btn_load_y + btn_load_height)) {
            // Load the MIDI file
            var success = midi_load_json(midi_filename);
            if (success) {
                show_debug_message("MIDI file loaded successfully!");
            }
        }
        
        // Play/Pause button
        if (point_in_rectangle(mouse_x, mouse_y, btn_play_x, btn_play_y, 
                              btn_play_x + btn_play_width, btn_play_y + btn_play_height)) {
            if (!playing && global.midi_data != undefined) {
                midi_start_playback(base_sound);
                playing = true;
            } else {
                midi_stop_playback();
                playing = false;
            }
        }
        
        // Progress bar click (seek)
        if (point_in_rectangle(mouse_x, mouse_y, progress_x, progress_y, 
                              progress_x + progress_width, progress_y + progress_height)) {
            if (global.midi_data != undefined) {
                // Calculate the position in the song based on where the user clicked
                var click_pos = (mouse_x - progress_x) / progress_width;
                
                // Get the duration of the song
                var last_note = global.midi_notes[array_length(global.midi_notes) - 1];
                var total_duration = last_note.time + last_note.duration;
                
                // Seek to that position
                midi_seek(click_pos * total_duration);
            }
        }
    }