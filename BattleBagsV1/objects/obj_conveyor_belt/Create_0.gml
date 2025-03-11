/// @description Initialize Conveyor Belt System
// Conveyor configuration
conveyor_speed = 2;  // Speed of blocks moving upward
/// @description Initialize Conveyor Belt System
// Conveyor configuration
conveyor_speed = 2;  // Speed of blocks moving upward
conveyor_start_y = room_height - 128;  // Bottom position where blocks spawn
conveyor_activation_y = 400;  // Y position where blocks activate
conveyor_width = 128;  // Width of the conveyor display area
lane_count = 1;  // Number of parallel lanes
lanes_unlocked = 1;  // How many lanes are currently available to use


// Position setup
var offset = 176;
player_obj = obj_game_control;
conveyor_x_start = player_obj.board_x_offset + (player_obj.board_width * player_obj.gem_size) + (conveyor_width * 0.5) + offset;
x = conveyor_x_start;

// Block tracking
conveyor_blocks = ds_list_create();
max_visible_blocks = 10;  // Maximum blocks visible on conveyor

// Visuals
show_grid_overlay = true;  // Whether to show grid lines
pulsing_alpha = 0;

// Integration variables
activation_callback = undefined;  // Function to call when blocks reach the top
block_sprites = ds_map_create();  // Cache for block sprites

// Cache block sprites for faster drawing
for (var i = 0; i <= 10; i++) {
    block_sprites[? i] = sprite_for_block(i);
}

// Conveyor state
conveyor_active = true;  // Can be paused/resumed
belt_animation_offset = 0;  // For scrolling belt animation
throughput_rate = 1.0;  // Multiplier for conveyor speed (upgradeable)

// Stats tracking
blocks_processed = 0;
special_blocks_processed = 0;