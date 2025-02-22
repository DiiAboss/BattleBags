/// @description
// Initialize control assignments
player_assigning = 0; // No player is assigning yet
assigning_done = false; // Flag to mark when control assignments are done

// Set up rectangles to represent control assignments
rect_width = 150;
rect_height = 50;


max_players = 4;

top_playable_row = 4;
bottom_playable_row = 20;


// Delay for input managing.
delay = 0;
max_delay = 10;

mouse_assigned = false;
dInput = false;
xInput = true;

random_seed = irandom(999999) * -1;

shift_speed = 0.25;

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
    player.shift_speed = 0.5;
    player.random_seed = random_seed;
    player.hovered_block = [4, 12];
    player.input.InputType = INPUT.NONE;
}

width = 8;
height = 24;

gem_size = 48;
offset = gem_size * 0.5;
show_debug_overlay(true);

gamepad_taken_list = array_create(12, -1);

