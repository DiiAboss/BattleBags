/// @description Initialize deposit block
image_speed = 0;
depth = 10;

rand = irandom_range(-99999, 99999);

level = 1;

// Block state management
state = "ready";
regen_timer = 0;
max_regen_time = 60 * 3; // 3 seconds to regenerate
depletion_chance = 0.1; // 10% chance to become depleted after pickup
depletion_timer = 0;
max_depletion_time = 60 * 15; // 15 seconds to recover from depletion

// Visual properties
float_offset = 0;
float_speed = 0.01;
float_range = 1;
glow_alpha = 0;
sparkle_timer = 0;
sparkle_interval = 10;
max_height = 99;
max_width = 99;

default_size = 64;
size_mod = 0.75;

stats =
{
    scale: 64,
}

mod_stats = 
{
    scale: 0.75,
}

special_stats =
{
    destroy_matches: false,
    create_upgrade_block_on_destroy: false,
}


scale = stats.scale * mod_stats.scale;

image_xscale = size_mod;
image_yscale = size_mod;

is_active = false;

// Interface function for drones to get a block
get_block_type = function() {
    if (state == "ready") {
        // Store the current block type to return
        var block_to_return = 
        {
            current_block_type,
            type,
            value,
            sprite,
            img,
        }
        
        // Transition to cooldown state
        state = "cooldown";
        regen_timer = 0;
        
        
        return block_to_return;
    }
}

current_block_type = BLOCK.NONE;

targetter = noone;
falling = true;
vsp = 3;
default_base = obj_conveyor_belt.conveyor_start_y;
base = default_base;
rotation = irandom(360);
rotation_speed = 1 + irandom(2);

color = c_red;
check_for_match = 30;

alarm[0] = check_for_match;
gravity = 0;