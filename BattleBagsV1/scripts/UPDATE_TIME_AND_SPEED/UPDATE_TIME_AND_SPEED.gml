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

function process_gameboard_speed(_self, speedUpKey)
{

	
	global.modifier = game_speed_default / game_speed_start;
	
	// Space for speed up
	if (_self.fight_for_your_life)
	{
		global.gameSpeed = _self.game_speed_default * _self.game_speed_fight_for_your_life_modifier;
		global.enemy_timer_game_speed = global.gameSpeed;
	}
	else if (speedUpKey) 
	{
	    global.gameSpeed = _self.game_speed_default + _self.game_speed_increase_modifier;
        global.enemy_timer_game_speed = global.gameSpeed;
	} else {
		    if (_self.combo <= 1) 
			{
		        global.gameSpeed = _self.game_speed_default;
				global.enemy_timer_game_speed = global.gameSpeed;
		    }
		    else 
			{
		        global.gameSpeed = _self.game_speed_default * _self.game_speed_combo_modifier;
				global.enemy_timer_game_speed = global.gameSpeed;
		    }
	}

	if (_self.timer_block_slow_down > 0)
	{
		global.gameSpeed  = _self.game_speed_default * 0.5 * _self.game_speed_combo_modifier;
		_self.timer_block_slow_down -= 1;
	}
	else
	{
		_self.timer_block_slow_down = 0;
	}
}