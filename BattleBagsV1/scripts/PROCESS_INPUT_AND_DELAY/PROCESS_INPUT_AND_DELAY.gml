function process_inputs_and_delay(player, input)
{
    var width = player.board_width;
    var max_input_delay = input.maxInputDelay;
    var min_x = 0;
    var max_x = width - 2;
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