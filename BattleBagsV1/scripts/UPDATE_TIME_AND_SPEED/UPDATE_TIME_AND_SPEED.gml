function update_time(_self, FPS = 60)
{

	_self.total_time += 1;
	var t_i_s = (_self.total_time / FPS);
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




 
