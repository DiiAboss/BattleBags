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

// Visual effects
particles = part_system_create();
part_system_depth(particles, depth - 1);

// Create smoke particle
smoke_particle = part_type_create();
part_type_sprite(smoke_particle, spr_preview_blocks, true, true, false);
part_type_scale(smoke_particle, 0.5, 0.5);
part_type_alpha3(smoke_particle, 0.2, 0.4, 0);
part_type_speed(smoke_particle, 0.5, 1, 0, 0);
part_type_direction(smoke_particle, 70, 110, 0, 0);
part_type_life(smoke_particle, room_speed * 0.5, room_speed * 1);

// Create sparkle particle
sparkle_particle = part_type_create();
part_type_sprite(sparkle_particle, spr_preview_blocks, true, true, false);
part_type_scale(sparkle_particle, 0.3, 0.3);
part_type_alpha3(sparkle_particle, 0.2, 0.7, 0);
part_type_speed(sparkle_particle, 1, 2, -0.1, 0);
part_type_direction(sparkle_particle, 0, 360, 0, 5);
part_type_life(sparkle_particle, room_speed * 0.2, room_speed * 0.5);

// Emitter for the particles
emitter = part_emitter_create(particles);
part_emitter_region(particles, emitter, x - 16, x + 16, y - 24, y, ps_shape_rectangle, ps_distr_linear);

// Function to select a block type based on weights
function choose_weighted_block_type() {
    // Create a weighted list
    var weighted_list = ds_list_create();
    
    // Add block types according to their weights
    var keys = ds_map_find_first(block_weights);
    while (!is_undefined(keys)) {
        var weight = ds_map_find_value(block_weights, keys);
        repeat(weight) {
            ds_list_add(weighted_list, keys);
        }
        keys = ds_map_find_next(block_weights, keys);
    }
    
    // Select a random block type from the weighted list
    var selected_type = ds_list_find_value(weighted_list, irandom(ds_list_size(weighted_list) - 1));
    
    // Clean up
    ds_list_destroy(weighted_list);
    
    return selected_type;
}

rotation_speed = 0.1;
rotation_direction = -1;
rotation = 0;
max_rotation = -64;

direction = 0;