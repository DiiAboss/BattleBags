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

/// @description Initialize recycler
// Visual properties
sprite_index = spr_block_recycler;
image_speed = 0.2;

tar_x = obj_game_control.board_x_offset + (obj_game_control.width * 64);
my_target = instance_create_depth(tar_x, y, -1, obj_target);
depth = -1;

// Production properties
cooldown = 0;
max_cooldown = 1; // 2 seconds between processing
processing = false;
process_time = 0;
max_process_time = 30; // 1.5 seconds to process

// Block generation properties
success_chance = 0.5; // 70% chance to create a block

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