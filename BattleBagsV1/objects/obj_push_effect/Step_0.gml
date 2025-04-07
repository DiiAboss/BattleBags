/// @description Apply push effect
current_duration++;

// Find all deposit blocks within radius
var list = ds_list_create();
var count = collision_circle_list(x, y, radius, obj_deposit_block, false, true, list, false);

// Apply push force to each block
for (var i = 0; i < count; i++) {
    var block = list[| i];
    
    // Skip blocks that aren't affected by physics (not falling or rotating)
    if (!block.falling && block.rotation_speed == 0) {
        // Calculate direction from center to block
        var dir = point_direction(x, y, block.x, block.y);
        
        // Calculate distance (closer blocks get pushed more)
        var dist = point_distance(x, y, block.x, block.y);
        var push_factor = 1 - (dist / radius);  // 1 at center, 0 at edge
        
        // Apply push force
        block.falling = true;
        block.vsp = -push_strength * push_factor;  // Push upward
        block.rotation_speed = random_range(1, 3) * push_factor;  // Add some rotation
        
        // Set horizontal movement based on direction
        var hsp = lengthdir_x(push_strength * 2 * push_factor, dir);
        block.hspeed = hsp;
    }
}

// Clean up the list
ds_list_destroy(list);
// Smoothly approaches a target value
function approach(current, target, amount) {
    if (current < target) {
        return min(current + amount, target);
    } else {
        return max(current - amount, target);
    }
}

// Visual effect scaling
effect_scale = approach(effect_scale, max_scale, 0.2);
effect_alpha = approach(effect_alpha, 0, 0.05);

// Destroy when duration is over
if (current_duration >= push_duration) {
    instance_destroy();
}
