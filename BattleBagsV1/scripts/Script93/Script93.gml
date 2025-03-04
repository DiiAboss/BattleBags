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


function process_inputs_and_delay(player, input)
{
    var width = player.board_width;
    var max_input_delay = input.maxInputDelay;
    var min_x = 0;
    var max_x = width - 1;
    var min_y = player.top_playable_row;
    var max_y = player.bottom_playable_row;


    if (input.inputDelay > 0)
    {
        input.inputDelay --;
        return;
    }
    else {

        if (input.Up)
        {
            if (player.last_position[1] > min_y)
            {
                player.last_position[1] -= 1;
            }
            input.inputDelay = max_input_delay;
        }

        if (input.Down)
        {
            if (player.last_position[1] < max_y)
            {
                player.last_position[1] += 1; 
            }
            input.inputDelay = max_input_delay;
        }

        if (input.Left)
        {
            if (player.last_position[0] > min_x)
            {
                player.last_position[0] -= 1;
            }
            else {
                player.last_position[0] = max_x;
            }
            input.inputDelay = max_input_delay;
        }

        if (input.Right)
        {
            if (player.last_position[0] < max_x)
            {
                player.last_position[0] += 1; 
            }
            else {
                player.last_position[0] = min_x;
            }
            input.inputDelay = max_input_delay;
        }
    }  
}

function process_fight_for_your_life(_self, danger_row)
{
    var in_danger = false;
    var width     = _self.board_width;
    var grid      = _self.grid;
    var gem_size  = _self.gem_size;
    var global_y_offset = _self.global_y_offset;
    var combo     = self.combo;

    for (var i = 0; i < width; i++) {
        for (var _y = 0; _y < danger_row; _y++)
        {
            if (grid[i, _y].type != BLOCK.NONE && !grid[i, _y].falling && grid[i, _y].fall_delay < grid[i, _y].max_fall_delay && !grid[i, _y].is_enemy_block) { 

                if (combo >= 0)
                {
                    in_danger = true;
                }
            }
        }
    }

    return (in_danger);
}