function create_player(_id)
{
    return {
        _id: _id,                              // Player ID
        input: new Input(),                   // Player input
        grid: create_grid_array(),            // Player grid
        global_y_offset: 0,                   // Y Offset
        start_row: 12,
        shift_speed: 1,                        // Shift speed
        default_shift_speed: 1,
        score: 0,                              // Player score
        alive: true,                           // Is the player still active?
        input_type: INPUT.NONE,                // Default input type
        pop_list: undefined,
        
        board_x_offset: 0,
        bottom_playable_row: 20,
        random_seed: 0,
        hovered_block: [-1, -1],
        pointer_x: -1,
        pointer_y: -1,
        selected_x: -1,
        selected_y: -1,
        input_delay: 0,
        swap_in_progress: false,
        swap_info: undefined,
        swap_queue: undefined,
        width: 8,
        height: 24,
        online_player: false,
        last_swap_x: -1,
        last_swap_y: -1,
        draw_y_start: 256,
        darken_alpha: 1,
        gem_size: 64,
        is_ai: false,
        topmost_row: 12,
        board_is_clearing:false,
        board_is_shifting: false,
        grid_width: 8,
        grid_height: 28,
        top_playable_row: 4,
        bottom_playable_row: 20,
        board_just_shifted: false,
        combo: 0,
        max_combo_timer: 60,
        combo_timer: 60,
        
        
    };
}

