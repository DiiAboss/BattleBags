/// @description
// Draw background
    draw_set_color(c_black);
    draw_rectangle(0, 0, width, height, false);
    
    // Draw load button
    draw_set_color(c_gray);
    draw_rectangle(btn_load_x, btn_load_y, btn_load_x + btn_load_width, btn_load_y + btn_load_height, false);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(btn_load_x + btn_load_width/2, btn_load_y + btn_load_height/2, "Load MIDI");
    
    // Draw play/pause button
    draw_set_color(c_gray);
    draw_rectangle(btn_play_x, btn_play_y, btn_play_x + btn_play_width, btn_play_y + btn_play_height, false);
    draw_set_color(c_white);
    draw_text(btn_play_x + btn_play_width/2, btn_play_y + btn_play_height/2, playing ? "Pause" : "Play");
    
    // Draw progress bar
    draw_set_color(c_dkgray);
    draw_rectangle(progress_x, progress_y, progress_x + progress_width, progress_y + progress_height, false);
    
    // Draw current progress if MIDI is loaded
    if (global.midi_data != undefined) {
        // Find the last note to determine total duration
        var last_note = global.midi_notes[array_length(global.midi_notes) - 1];
        var total_duration = last_note.time + last_note.duration;
        
        // Calculate current progress
        var progress = global.midi_current_time / total_duration;
        
        // Draw progress indicator
        draw_set_color(c_lime);
        draw_rectangle(progress_x, progress_y, progress_x + (progress_width * progress), progress_y + progress_height, false);
        
        // Draw current time / total time
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        var minutes_current = floor(global.midi_current_time / 60);
        var seconds_current = global.midi_current_time mod 60;
        var minutes_total = floor(total_duration / 60);
        var seconds_total = total_duration mod 60;
        
        var time_str = string(minutes_current) + ":" + string_format(seconds_current, 2, 1) + 
                      " / " + string(minutes_total) + ":" + string_format(seconds_total, 2, 1);
        draw_text(progress_x, progress_y + progress_height + 10, time_str);
    }
    
    // Draw status
    var status = "No MIDI loaded";
    if (global.midi_data != undefined) {
        status = "MIDI loaded with " + string(array_length(global.midi_notes)) + " notes";
        if (playing) {
            status += " (Playing)";
        } else {
            status += " (Paused)";
        }
    }
    
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_text(100, 200, status);
    
    // Display some information about the MIDI file
    if (global.midi_data != undefined) {
        draw_text(100, 230, "Song name: " + string(global.midi_data.header.name));
        draw_text(100, 250, "BPM: " + string(global.midi_data.header.bpm));
        draw_text(100, 270, "Time signature: " + string(global.midi_data.header.timeSignature[0]) + 
                 "/" + string(global.midi_data.header.timeSignature[1]));
    }