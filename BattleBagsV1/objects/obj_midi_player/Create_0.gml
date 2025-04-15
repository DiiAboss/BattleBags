/// @description
width = room_width;
height = room_height;
playing = false;

// Create a button to load the MIDI file
btn_load_x = 100;
btn_load_y = 50;
btn_load_width = 150;
btn_load_height = 40;

// Create a play/pause button
btn_play_x = 300;
btn_play_y = 50;
btn_play_width = 150;
btn_play_height = 40;

// Position for progress bar
progress_x = 100;
progress_y = 120;
progress_width = 600;
progress_height = 20;

// The MIDI data will be loaded from a file in the included_files folder
// Make sure to include your MIDI JSON file in your project settings under "Included Files"
midi_filename = "midi_data.json";

// Set our base note sound (you need to create this sound in your project)
// This should be a simple, pure tone that can be pitch-shifted well
// A piano note or sine wave works well
base_sound = snd_piano_note; // Change this to your actual sound resource

current_sound = 0;
sound_array_length = 3;
sound_array = [snd_piano_note, snd_ahh_C, snd_ta_note_C, snd_woo_C];