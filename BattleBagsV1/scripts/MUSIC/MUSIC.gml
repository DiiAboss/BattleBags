function play_next_song() {
    // ✅ Stop any currently playing music
    audio_stop_all();

    // ✅ Move to the next song in the list
    current_song += 1;

    // ✅ Loop back to the first song when reaching the end
    if (current_song >= array_length(songs)) {
        current_song = 0;
    }

    // ✅ Play the new song
    audio_play_sound(songs[current_song], true, false);
}