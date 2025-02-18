function create_player(_id)
{
    return {
        id: _id,                              // Player ID
        input: new Input(),                   // Player input
        grid: create_grid_array(),            // Player grid
        global_y_offset: 0,                   // Y Offset
        start_row: 12,
        shift_speed: 1,                        // Shift speed
        score: 0,                              // Player score
        alive: true,                           // Is the player still active?
        input_type: INPUT.NONE,                // Default input type
        pop_list: undefined,
        combo: 0,
        board_x_offset: 0,
        bottom_playable_row: 20,
        random_seed: 0,
    };
}
