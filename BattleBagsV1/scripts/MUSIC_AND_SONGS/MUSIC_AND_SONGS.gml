function transition_to_regular_song(current_song)
{
		// ✅ Transition back to regular music
	if (global.music_regular == -1) {
		global.music_regular = audio_play_sound(current_song, 1, true);
	}
    
	global.music_regular_volume = min(global.music_regular_volume + global.music_fade_speed, 1);
	global.music_fight_volume = max(global.music_fight_volume - global.music_fade_speed, 0);
    
	//  Pause fight music if volume is 0
	if (global.music_fight_volume <= 0 && global.music_fight != -1) {
		audio_pause_sound(global.music_fight);
	}
    
	// ▶️ Resume regular music if it was paused
	if (global.music_regular_volume > 0 && audio_is_paused(global.music_regular)) {
		audio_resume_sound(global.music_regular);
	}	
} 


function transition_to_fast_song(fast_song = music_fast_music_test)
{
	if (global.music_fight == -1) {
	global.music_fight = audio_play_sound(fast_song, 1, true);
	}
    
	global.music_fight_volume = min(global.music_fight_volume + global.music_fade_speed, 1);
	global.music_regular_volume = max(global.music_regular_volume - global.music_fade_speed, 0);
    
	//  Pause regular music if volume is 0
	if (global.music_regular_volume <= 0 && global.music_regular != -1) {
		audio_pause_sound(global.music_regular);
	}
    
	// ▶️ Resume fight music if it was paused
	if (global.music_fight_volume > 0 && audio_is_paused(global.music_fight)) {
		audio_resume_sound(global.music_fight);
	}
}


function apply_volume_settings()
{
	if (global.music_regular != -1) audio_sound_gain(global.music_regular, global.music_regular_volume, 0);
	if (global.music_fight != -1) audio_sound_gain(global.music_fight, global.music_fight_volume, 0);
}

function process_play_next_song(current_song)
{
	if (!audio_is_playing(current_song)) {
	play_next_song();
	}
}