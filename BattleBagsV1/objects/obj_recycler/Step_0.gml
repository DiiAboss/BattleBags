
/// @description Process recycling and block generation

if (global.paused) return;

// Check for collision with transfer block
var transfer_block = instance_place(x, y, obj_block_transfer);
if (transfer_block != noone) {
    // Start processing
    recycler_queue += 1;
    player_object.energy_points += player_object.ep_gain;
    // Destroy the transfer block
    with (transfer_block) {
        instance_destroy();
    }
}



if (rotation < max_rotation)
{
    rotation_direction = 1;
}



if (rotation > 0)
{
    rotation_direction = -1;
}

rotation = 0;
direction = rotation;



// Update cooldown
if (cooldown > 0) {
    cooldown--;
}



if (recycler_queue > 0)
{
    processing = true;
}
else
{
    processing = false;
}



// Process animation if processing
if (processing) {
    process_time++;
    
    // If processing is complete, potentially spawn a block
    if (process_time >= max_process_time) {
        process_time = 0;
        cooldown = max_cooldown;
        
        var chance = success_chance;
        
        // Determine if a block is created
        if (irandom(100) < chance) {
            var spawn_x = x + lengthdir_x(96, 270 + irandom_range(-stats.range, stats.range));
            var spawn_y = y + lengthdir_y(96, 270 + irandom_range(-stats.range, stats.range));
            
            var new_deposit_block = create_deposit_block(self, spawn_x, spawn_y, deposit_blocks);
            
            if (new_deposit_block == noone) return;
                
            new_deposit_block.speed = random_range(eject_speed_min, eject_speed_max);
            new_deposit_block.direction = 270;
            new_deposit_block.hspeed = random_range(-stats.range, stats.range * 0.5);
            new_deposit_block.gravity = 0.2;
            
        }
        
        recycler_queue -= 1;
    }
}



function set_deposit_spawn_rate(_type, rate)
{
    var keys = variable_struct_get_names(deposit_blocks);
    var len = array_length(keys);
    // Build weighted list based on type
    for (var i = 0; i < len; i++) {
        var block = deposit_blocks[$ keys[i]];
        var __type = _type;
        if (block.value == __type) {
            block.weight = rate;
        }
    }
}



if (keyboard_check_pressed(ord("V")))
{
    set_deposit_spawn_rate(BLOCK.BUG, 100);
}



function update_recycler_stats()
{
    // Block generation properties
    success_chance   = stats.success_chance   * mod_stats.success_chance; // 50% chance to create a block
    max_process_time = stats.process_time     * mod_stats.process_time; // 1.5 seconds to process
    cooldown_time    = stats.cooldown_time    * mod_stats.cooldown_time;
    block_chance     = stats.block_chance     * mod_stats.block_chance;
    upgrade_chance   = stats.upgrade_chance   * mod_stats.upgrade_chance;
    bad_block_chance = stats.bad_block_weight * mod_stats.bad_block_chance;
    energy_gain      = stats.energy_gain      * mod_stats.energy_gain; 
}


 