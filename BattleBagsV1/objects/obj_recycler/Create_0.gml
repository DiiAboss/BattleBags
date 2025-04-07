/// @description

// TODO: HAVE A DEPOSIT BLOCKS MANAGER
deposit_blocks =
{
    red:
    {
        type: DEPOSIT_BLOCK.BLOCK, 
        weight: 5,
        value: BLOCK.RED,
        sprite: spr_red_gem,
        img: 0,
        level: 0,
    },
    yellow:
    {
        type: DEPOSIT_BLOCK.BLOCK, 
        weight: 5,
        value: BLOCK.YELLOW,
        sprite: spr_yellow_gem,
        img: 0,
        level: 0,
    },
    green:
    {
        type: DEPOSIT_BLOCK.BLOCK,
        weight: 5,
        value: BLOCK.GREEN,
        sprite: spr_green_gem,
        img: 0,
        level: 0,
    },
    pink:
    {
        type: DEPOSIT_BLOCK.BLOCK,
        weight: 5,
        value: BLOCK.PINK,
        sprite: spr_pink_gem,
        img: 0,
        level: 0,
    },
    purple:
    {
        type: DEPOSIT_BLOCK.BLOCK,
        weight: 5,
        value: BLOCK.PURPLE,
        sprite: spr_purple_gem,
        img: 0,
        level: 0,
    },
    lightblue:
    {
        type: DEPOSIT_BLOCK.BLOCK,
        weight: 5,
        value: BLOCK.LIGHTBLUE,
        sprite: spr_lightblue_gem,
        img: 0,
        level: 0,
    },
    orange:
    {
         type: DEPOSIT_BLOCK.BLOCK,
         weight: 5,
         value: BLOCK.ORANGE,
         sprite: spr_orange_gem,
         img: 0,
        level: 0,
    },
    blue:
    {
        type: DEPOSIT_BLOCK.BLOCK,
        weight: 5,
        value: BLOCK.BLUE,
        sprite: spr_blue_gem,
        img: 0,
        level: 0,
    },
    black:
    {
        type: DEPOSIT_BLOCK.BLOCK,
        weight: 25,
        value: BLOCK.BLACK,
        sprite: spr_gameOver,
        img: 0,
        level: 0,
    },
    bug:
    {
        type: DEPOSIT_BLOCK.BLOCK,
        weight: 25,
        value: BLOCK.BUG,
        sprite: spr_enemy_fly,
        img: 0,
        level: 0,
    },
    wild:
    {
        type: DEPOSIT_BLOCK.BLOCK,
        weight: 0,
        value: BLOCK.WILD,
        sprite: spr_Oshki,
        img: 0,
        level: 0,
    },
    arrow:
    {
        type: DEPOSIT_BLOCK.UPGRADE,
        weight: 5,
        value: POWERUP.BOW,
        sprite: spr_upgrades,
        img: 0,
        level: 0,
    },
    heart:
    {
        type: DEPOSIT_BLOCK.UPGRADE,
        weight: 5,
        value: POWERUP.HEART,
         sprite: spr_upgrades,
         img: 4,
        level: 0,
    },
    bomb:
    {
        type: DEPOSIT_BLOCK.UPGRADE,
        weight: 5,
        value: POWERUP.BOMB,
        sprite: spr_upgrades,
        img: 5,
        level: 0,
    },
    timer:
    {
        type: DEPOSIT_BLOCK.UPGRADE,
        weight: 5,
        value: POWERUP.TIMER,
        sprite: spr_upgrades,
        img: 1,
        level: 0,
    },
}

// Base stats that define default values
stats = {
    // Production properties
    cooldown_time: 1,            // Seconds between processing attempts
    process_time: 30,            // Frames to process a block
    
    // Block generation properties
    success_chance: 0.50,        // 50% chance to create a block
    block_chance: 70,            // Weight for regular blocks
    upgrade_chance: 30,          // Weight for upgrades
    
    // Bad block properties
    bad_block_weight: 25,        // Default weight for bad blocks
    bug_block_spawn_weight: 0,
    
    // Ejection parameters
    eject_speed_min: 4,
    eject_speed_max: 5,
    
    // Energy gain
    energy_gain: 1              // Energy points per block processed
};

// Modifier stats that can be adjusted by upgrades
mod_stats = {
    // Production modifiers
    cooldown_time: 1.0,         // Modifier for cooldown (lower is faster)
    process_time: 1.0,          // Modifier for processing time (lower is faster)
    
    // Chance modifiers
    success_chance: 1.0,        // Modifier for success chance (higher is better)
    block_chance: 1.0,          // Modifier for block spawn chance
    upgrade_chance: 1.0,        // Modifier for upgrade spawn chance
    bad_block_chance: 1.0,      // Modifier for bad block spawn chance
    bug_block_spawn_weight: 0,
    
    // Special types modifiers
    bomb_chance: 1.0,           // Modifier for bomb spawn chance
    bow_chance: 1.0,            // Modifier for bow spawn chance
    color_bomb_chance: 0.0,     // Chance for color bomb (wild) to spawn
    
    // Ejection modifiers
    eject_speed: 1.0,           // Modifier for ejection speed
    
    // Energy gain modifiers
    energy_gain: 1.0            // Modifier for energy gain
};

// Special states
special_states = {
    repel_bugs: false,            // Whether bug blocks are suppressed
    repel_bugs_timer: 0,          // Timer for bug repelling
    big_block_attractor: false,   // Whether big blocks attract matching blocks
    spawn_color_bomb_counter: -1,
};


// Block generation properties
success_chance   = stats.success_chance   * mod_stats.success_chance; // 50% chance to create a block
max_process_time = stats.process_time     * mod_stats.process_time; // 1.5 seconds to process
cooldown_time    = stats.cooldown_time    * mod_stats.cooldown_time;
block_chance     = stats.block_chance     * mod_stats.block_chance;
upgrade_chance   = stats.upgrade_chance   * mod_stats.upgrade_chance;
bad_block_chance = stats.bad_block_weight * mod_stats.bad_block_chance;
energy_gain      = stats.energy_gain      * mod_stats.energy_gain;



/// @description Initialize recycler
// Visual properties
sprite_index = spr_block_recycler;
image_speed = 0.2;

player_object = obj_game_control;

tar_x = player_object.board_x_offset + (player_object.board_width * 64);
my_target = instance_create_depth(tar_x, y, -1, obj_target);
depth = -1;

// Production properties
cooldown = 0;
max_cooldown = 1; // 2 seconds between processing
processing = false;
process_time = 0;





// Ejection parameters
eject_speed_min = 4;
eject_speed_max = 5;
eject_point_x = x;
eject_point_y = y - 32;

rotation_speed = 0.1;
rotation_direction = -1;
rotation = 0;
max_rotation = -64;

direction = 0;


recycler_queue = 0;