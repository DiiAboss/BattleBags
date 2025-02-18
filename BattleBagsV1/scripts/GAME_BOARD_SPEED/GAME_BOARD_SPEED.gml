function process_gameboard_speed(_self, speedUpKey)
{
    global.modifier = game_speed_default / game_speed_start;
    
    if (speedUpKey) 
    {
        global.gameSpeed = _self.game_speed_default + _self.game_speed_increase_modifier;
        global.enemy_timer_game_speed = global.gameSpeed;
    } 
    else {
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
