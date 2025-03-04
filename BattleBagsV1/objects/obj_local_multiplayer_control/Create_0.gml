/// @description
// Initialize control assignments
player_assigning = 0; // No player is assigning yet
assigning_done = false; // Flag to mark when control assignments are done

// Set up rectangles to represent control assignments
rect_width = 150;
rect_height = 50;

max_players = 4;

// Add to Create Event
// New variables for AI player selection
ai_available = true;         // Can AI players be added?
ai_players_enabled = [];     // Array to track which player slots have AI
for (var i = 0; i < max_players; i++) {
    ai_players_enabled[i] = false;
}
ai_button_width = 120;       // Width of AI button
ai_button_height = 40;       // Height of AI button
ai_difficulty = 5;           // Default AI difficulty (1-5)
ai_difficulty_names = ["Easy", "Medium", "Hard", "Expert", "Master"];






top_playable_row = 4;
bottom_playable_row = 20;


// Delay for input managing.
delay = 0;
max_delay = 10;

mouse_assigned = false;
dInput = false;
xInput = true;

random_seed = irandom(999999) * -1;

shift_speed = 0.1;

global.player_list = ds_list_create();
gem_size = 64;

for (var i = 0; i < max_players; i++) {
    ds_list_add(global.player_list, create_player(i));
}
//Test

for (var i = 0; i < ds_list_size(global.player_list); i++) {
    var player = ds_list_find_value(global.player_list, i);
    random_set_seed(random_seed);
    spawn_random_blocks_in_array(player.grid, player.start_row);
    player.swap_info = create_swap_info();
    player.swap_queue = create_swap_queue();
    player.pop_list = ds_list_create();
    player.shift_speed = shift_speed;
    player.random_seed = random_seed;
    player.hovered_block = [4, 12];
    player.input.InputType = INPUT.NONE;
    player.gem_size = gem_size;
}

width = 8;
height = 24;


offset = gem_size * 0.5;
show_debug_overlay(true);

gamepad_taken_list = array_create(12, -1);

