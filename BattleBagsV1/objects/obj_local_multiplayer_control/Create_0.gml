/// @description
// Initialize control assignments
player_assigning = 1; // No player is assigning yet
assigning_done = false; // Flag to mark when control assignments are done

// Set up rectangles to represent control assignments
rect_width = 150;
rect_height = 50;


max_players = 4;

// Create the player input array
player_input     = array_create(max_players, undefined);
player_grid      = array_create(max_players, undefined);
global_y_offsets = array_create(max_players, undefined);
shift_speeds     = array_create(max_players, undefined);
// 
top_playable_row = 4;
bottom_playable_row = 20;



for (var i = 0; i < max_players; i++) {
    player_input[i] = new Input();
    player_input[i].InputType = INPUT.NONE;
    global_y_offsets[i] = 0;
    shift_speeds[i] = 1;
    // Create the gird for each player.
    player_grid[i] = create_grid_array();
}

// Assign Player 1 to the main control set up in the menu.
player_input[0] = obj_game_manager.input;

// Delay for input managing.
delay = 0;
max_delay = 10;


mouse_assigned = false;
dInput = false;
xInput = true;

random_seed = irandom(999999) * -1;



shift_speed = 0.25;

max_players = 4; // 🚀 Support up to 35 players
global.player_list = ds_list_create();

for (var i = 0; i < max_players; i++) {
    ds_list_add(global.player_list, create_player(i));
}


for (var i = 0; i < ds_list_size(global.player_list); i++) {
    var player = ds_list_find_value(global.player_list, i);
    random_set_seed(random_seed);
    spawn_random_blocks_in_array(player.grid, player.start_row);
    player.swap_info = create_swap_info();
    player.swap_queue = create_swap_queue();
    player.pop_list = ds_list_create();
    player.shift_speed = 0.5 + (0.1 * i);
    player.random_seed = random_seed;
    player.hovered_block = [4, 12];
    
}

width = 8;
height = 24;

gem_size = 48;
show_debug_overlay(true);

gamepad_taken_list = [];
