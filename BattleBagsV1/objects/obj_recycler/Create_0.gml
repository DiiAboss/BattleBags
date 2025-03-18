/// @description
tar_x = obj_game_control.board_x_offset + (obj_game_control.width * 64);
my_target = instance_create_depth(tar_x, y, -1, obj_target);
depth = -1;


/// @description Initialize recycler
// Visual properties
sprite_index = spr_block_recycler;
image_speed = 0.2;
depth = 10;

// Production properties
cooldown = 0;
max_cooldown = 1; // 2 seconds between processing
processing = false;
process_time = 0;
max_process_time = 1; // 1.5 seconds to process

// Block generation properties
success_chance = 0.5; // 70% chance to create a block
block_weights = ds_map_create();
ds_map_add(block_weights, BLOCK.RED, 5);
ds_map_add(block_weights, BLOCK.YELLOW, 5);
ds_map_add(block_weights, BLOCK.GREEN, 5);
ds_map_add(block_weights, BLOCK.PINK, 5);
ds_map_add(block_weights, BLOCK.PURPLE, 5);
ds_map_add(block_weights, BLOCK.LIGHTBLUE, 5);
ds_map_add(block_weights, BLOCK.ORANGE, 5);
ds_map_add(block_weights, BLOCK.BLUE, 5);
ds_map_add(block_weights, BLOCK.BLACK, 20);
ds_map_add(block_weights, BLOCK.WILD, 0);

// Ejection parameters
eject_speed_min = 4;
eject_speed_max = 5;
//eject_angle_min = 30;
//eject_angle_max = 150;
eject_point_x = x;
eject_point_y = y - 32;




rotation_speed = 0.1;
rotation_direction = -1;
rotation = 0;
max_rotation = -64;

direction = 0;