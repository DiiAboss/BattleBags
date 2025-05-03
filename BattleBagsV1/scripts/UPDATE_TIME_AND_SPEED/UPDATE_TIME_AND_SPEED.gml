function update_time(_self, fps = _FPS)
{

	_self.total_time += 1;
	var t_i_s = (_self.total_time / fps);
	_self.time_in_seconds = floor(t_i_s);
	_self.time_in_minutes = floor(_self.time_in_seconds / 60);
	if (t_i_s % 30 == 0)
	{
		_self.game_speed_default += 0.1;
	}
}

function update_draw_time(_self)
{
    var draw_minutes = _self.time_in_minutes;
    if (draw_minutes <10) draw_minutes="0"+string(draw_minutes);
    var draw_seconds = _self.time_in_seconds % 60;
    if (draw_seconds <10) draw_seconds="0"+string(draw_seconds);
    _self.draw_time = string(draw_minutes) + ":" + string(draw_seconds);
}


function draw_next_event_timer(player, next_event_timer)
{
    var draw_minutes = floor(next_event_timer / 60);
    if (draw_minutes <10) draw_minutes="0"+string(draw_minutes);
    var draw_seconds = next_event_timer % 60;
    if (draw_seconds <10) draw_seconds="0"+string(draw_seconds);
        
    var draw_time = string(draw_minutes) + ":" + string(draw_seconds);
    
    return draw_time;
}


 
