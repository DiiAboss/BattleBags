/// @description
// Initialize control assignments
player_assigning = 1; // No player is assigning yet
assigning_done = false; // Flag to mark when control assignments are done

total_enemies = 1;

// Add to Create Event
// New variables for AI player selection
ai_available = true;         // Can AI players be added?
ai_players_enabled = [];     // Array to track which player slots have AI
for (var i = 0; i < total_enemies; i++) {
    ai_players_enabled[i] = true;
}

number_of_block_types = 8;

top_playable_row    = 4;
bottom_playable_row = 20;


// Delay for input managing.
delay     = 0;
max_delay = 10;

mouse_assigned = false;
dInput         = false;
xInput         = true;

random_seed  = irandom(999999) * -1;
shift_speed  = 0.5;
enemy_list   = array_create(0);
gem_size     = 64;
offset       = gem_size * 0.5;
board_width  = 8;
board_height = 24;

for (var i = 0; i < total_enemies; i++) {
    array_push(enemy_list, create_player(i));
}
//Test

for (var i = 0; i < array_length(enemy_list); i++) {
    var player = enemy_list[i];
    random_set_seed(random_seed);
    spawn_random_blocks_in_array(player, player.grid, player.start_row);
    player.swap_info             = create_swap_info();
    player.swap_queue            = create_swap_queue();
    player.pop_list              = ds_list_create();
    player.shift_speed           = shift_speed;
    player.default_shift_speed   = shift_speed;
    player.random_seed           = random_seed;
    player.hovered_block         = [4, 12];
    player.input.InputType       = INPUT.NONE;
    player.gem_size              = gem_size;
    player.grid_width            = board_width;
    player.grid_height           = board_height;
    player.top_playable_row      = top_playable_row;
    player.bottom_playable_row   = bottom_playable_row;
}

//show_debug_overlay(true);
