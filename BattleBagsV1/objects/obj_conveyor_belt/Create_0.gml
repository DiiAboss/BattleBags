/// @description Initialize Conveyor Belt Attack System
// Conveyor configuration
conveyor_speed = 2;           // Speed of attacks moving upward
conveyor_start_y = room_height;  // Bottom position where attacks spawn
conveyor_activation_y = 400;   // Y position where attacks activate
conveyor_width = 400;         // Width of the conveyor display area
lane_count = 1;   

player_obj = obj_game_control; 
conveyor_x_start = player_obj.board_x_offset + (player_obj.board_width * player_obj.gem_size) + (conveyor_width * 0.5);           // Number of parallel lanes

// Attack tracking
conveyor_attacks = ds_list_create();
max_visible_attacks = 5;      // Maximum number of attacks shown on conveyor

// Cache the attack previews for all possible attacks
attack_preview_cache = ds_map_create();
initialize_attack_previews();

// Link to the global attack queue
queue_sync_timer = 0;
queue_sync_interval = 5;      // How often to sync with global queue

// Visuals
show_grid_overlay = true;     // Whether to show grid lines
debug_menu_open = false;