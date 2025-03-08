/// @description AIBoardController
/// This is a GML implementation of the AIBoardController class from C++

// Constants for input actions
enum InputAction {
    INPUT_UP,
    INPUT_RIGHT,
    INPUT_DOWN, 
    INPUT_LEFT,
    INPUT_SWAP,
    INPUT_RAISE,
    INPUT_WAIT
}




/// @function create_ai_input
/// @description Creates an input handler for AI players
/// @param {struct} player The player
/// @returns {struct} Input handler
function create_ai_input(player) {
    return {
        InputType: INPUT.AI,
        Device: -100 - player._id,
        
        // Basic input state
        Up: false,
        Down: false,
        Left: false,
        Right: false,
        ActionPress: false,
        ActionKey: false,
        ActionRelease: false,
        SpeedUpKey: false,
        
        // The Update function is called by the multiplayer controller
        Update: function(_self, _x, _y) {
            // For AI players, inputs are set directly by the AI controller
            // No need to process anything here, as the AI controller sets these flags
            
            // Clear ActionPress and ActionRelease each frame to prevent persistent presses
            if (ActionPress) {
                ActionPress = false;
            }
            
            if (ActionRelease) {
                ActionRelease = false;
            }
        }
    };
}

/// @function create_ai_player
/// @param {real} _id Player ID
/// @returns {struct} AI player struct
function create_ai_player(_id) {
    // Create standard player first
    var player = create_player(_id);
    
    // Make sure pop_list is properly initialized
    if (player.pop_list == undefined) {
        player.pop_list = ds_list_create();
    }
    
    // Make sure grid is properly initialized and filled
    if (player.grid == undefined) {
        player.grid = create_grid_array();
        spawn_random_blocks_in_array(player.grid, player.start_row);
    }
    
    // Make sure other required properties are set
    if (player.swap_info == undefined) {
        player.swap_info = create_swap_info();
    }
    
    if (player.swap_queue == undefined) {
        player.swap_queue = create_swap_queue();
    }
    
    // Add AI-specific properties
    player.is_ai = true;
    player.ai_difficulty = 1; // 1-5 scale
    player.ai_delay = 0;      // Current delay counter
    player.ai_max_delay = 5;  // Maximum delay between AI actions
    player.ai_thinking = false;
    
    // Override input with AI-specific input handler
    player.input = create_ai_input(player);
    
    // Create AI components
    player.ai_scanner = new AIBoardScanner(player);
    player.ai_controller = new AIBoardController(player);
    
    return player;
}




/// @function setup_ai_players
/// @description Set up AI players for the multiplayer game
/// @param {id} controller The multiplayer controller object
function setup_ai_players(controller) {
    if (!controller.ai_enabled) return;
    
    // Get number of human players
    var human_count = 0;
    for (var i = 0; i < ds_list_size(global.player_list); i++) {
        var player = ds_list_find_value(global.player_list, i);
        if (player.input.InputType != INPUT.NONE && player.input.InputType != INPUT.AI) {
            human_count++;
        }
    }
    
    // Add AI players to fill remaining slots
    for (var i = human_count; i < controller.max_players && i < human_count + controller.ai_player_count; i++) {
        if (i < ds_list_size(global.player_list)) {
            ds_list_delete(global.player_list, i);
        }
        
        var ai_player = create_ai_player(i);
        ai_player.ai_controller.set_difficulty(controller.ai_difficulty);
        
        // Setup display position
        var draw_x_start = room_width / (controller.max_players + 1) - (controller.width * 0.5);
        ai_player.board_x_offset = 96 + ((draw_x_start) * i) + (i * (9 * controller.gem_size));
        
        ds_list_add(global.player_list, ai_player);
        
        show_debug_message("Created AI player " + string(i));
        
        // Make sure the AI board scanner exists
        if (player.ai_scanner == undefined) {
            player.ai_scanner = new AIBoardScanner(player);
        }
        
        // Make sure the AI controller exists
        if (player.ai_controller == undefined) {
            player.ai_controller = new AIBoardController(player);
        }
    }
}





/// @function update_ai_players
/// @description Update AI players in the game loop
/// @param {id} _self The multiplayer controller object
function update_ai_players(_self) {
    for (var i = 0; i < ds_list_size(global.player_list); i++) {
        var player = ds_list_find_value(global.player_list, i);
        
        if (player != undefined && player.is_ai && player.alive) {
            // Process AI thinking
            player.ai_controller.tick();
        }
    }
}

/// @function cleanup_ai_players
/// @description Clean up AI players when the game ends
/// @param {id} _self The multiplayer controller object
function cleanup_ai_players(_self) {
    for (var i = 0; i < ds_list_size(global.player_list); i++) {
        var player = ds_list_find_value(global.player_list, i);
        
        if (player.is_ai && player.ai_controller != undefined) {
            player.ai_controller.cleanup();
        }
    }
}



/// @function draw_ai_debug
/// @description Draw debug information for AI players
/// @param {struct} player The player to debug
function draw_ai_debug(player) {
    //return;
    if (!player.is_ai) return;
    
    // Get screen position to draw debug info
    var board_x = player.board_x_offset - 100;
    var board_y = room_height - 300;
    
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    // Draw the AI's last decision
    draw_text(board_x, board_y, "AI Player " + string(player._id) + " (Lvl " + string(player.ai_difficulty) + ")");
    board_y += 20;
    
    draw_text(board_x, board_y, "Last decision: " + player.ai_controller.last_decision);
    board_y += 20;
    
    draw_text(board_x, board_y, "Cursor at: " + string(player.hovered_block[0]) + "," + string(player.hovered_block[1]));
    board_y += 20;
    
    draw_text(board_x, board_y, "Decision history:");
    board_y += 20;
    
    // Draw decision history
    for (var i = 0; i < array_length(player.ai_controller.decision_log); i++) {
        draw_text(board_x, board_y, "- " + player.ai_controller.decision_log[i]);
        board_y += 20;
    }
    
    // Draw active flags
    board_y += 10;
    draw_text(board_x, board_y, "AI Flags:");
    board_y += 20;
    
    draw_text(board_x, board_y, "Delay: " + string(player.ai_delay) + "/" + string(player.ai_max_delay));
    board_y += 20;
    
    draw_text(board_x, board_y, "Swap cooldown: " + string(player.ai_controller.swap_cooldown));
    board_y += 20;
    
    draw_text(board_x, board_y, "Swap in progress: " + string(player.swap_in_progress));
    board_y += 20;
}