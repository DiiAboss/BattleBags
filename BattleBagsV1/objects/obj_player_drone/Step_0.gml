// STEP EVENT - Fixed version
var input = obj_game_manager.input;
input.Update(self, x, y);

// Calculate horizontal movement
var move = input.Right - input.Left;
move_dir = move; // Store move direction for animations
if (move_dir != 0) my_dir = move_dir;

// Set speed based on running or walking
var current_speed = input.RunKey ? run_speed : walk_speed;
hsp = move * current_speed;

// Ground detection - FIXED version for jump-through platforms
var on_jump_through = false;
if (vsp >= 0) { // Only consider standing on jump-through when moving down or not moving vertically
    if (place_meeting(x, y+1, obj_jump_through) && !place_meeting(x, y, obj_jump_through)) {
        on_jump_through = true;
    }
}

// Ground detection
var was_on_ground = can_jump;
can_jump = place_meeting(x, y+1, obj_floor) || on_jump_through;

// Add this platform detection code:
on_moving_platform = false;
platform_id = noone;

// Check if standing on a moving platform - FIXED detection
if (can_jump) {
    var platform = instance_place(x, y+1, obj_moving_platform);
    if (platform != noone && !place_meeting(x, y, platform)) {
        on_moving_platform = true;
        platform_id = platform;
    }
}

// Coyote time handling
if (was_on_ground && !can_jump) {
    coyote_time = coyote_time_max;
}
else if (coyote_time > 0) {
    coyote_time--;
}

// Jump buffer handling
if (jump_buffer > 0) jump_buffer--;
if (input.UpPress) {
    jump_buffer = jump_buffer_max;
    // Add visual debug for jump button press
    show_debug_message("JUMP PRESSED: buffer=" + string(jump_buffer));
}

// Process jump input
if (jump_buffer > 0 && (can_jump || coyote_time > 0)) {
    vsp = jump_speed;
    jump_buffer = 0;
    coyote_time = 0;
    can_jump = false;  // Immediately set can_jump to false
    show_debug_message("JUMP EXECUTED: vsp=" + string(vsp));
}

// Drop through jump-through platforms - FIXED version
if (input.DownPress && on_jump_through) {
    y += 2; // Move down a bit more to ensure we clear the platform
}

// Apply gravity
if (!can_jump || vsp < 0) {  // Apply gravity when jumping or falling
    vsp += grv;
    if (vsp > max_fall_speed) vsp = max_fall_speed;
} else if (can_jump && vsp >= 0) {
    // Reset vertical speed when on ground and not jumping
    vsp = 0;
}

// HORIZONTAL COLLISION AND SLOPE HANDLING
var slope_max_pixels = 8; // Maximum height a slope can rise in one step

// Try to move horizontally
var original_y = y;
var found_valid_pos = false;

for (var i = 0; i <= slope_max_pixels; i++) {
    // Check if we can move by temporarily adjusting our height
    y = original_y - i;
    if (!place_meeting(x + hsp, y, obj_floor)) {
        // We found a spot where we can move!
        x += hsp;
        found_valid_pos = true;
        break;
    }
}

// Reset y if we didn't find a valid position
if (!found_valid_pos) {
    y = original_y;
    // We couldn't find a valid spot, stop horizontal movement
    hsp = 0;
}

// VERTICAL COLLISION - FIXED version for better platform detection
if (vsp >= 0) { // Only check when moving downward
    // Moving down - standard collision check, but handle slopes
    var slope_y = y;
    var found_collision = false;
    
    for (var j = 0; j <= abs(vsp); j++) {
        slope_y = y + j;
        // Check for collision at this position - FIXED jump-through logic
        var floor_collision = place_meeting(x, slope_y, obj_floor);
        var jump_through_collision = false;
        
        if (!input.DownPress) { // Only check jump-through if not pressing down
            jump_through_collision = place_meeting(x, slope_y, obj_jump_through) && 
                                    !place_meeting(x, y, obj_jump_through);
        }
        
        if (floor_collision || jump_through_collision) {
            // Found collision
            y = slope_y - 1;
            vsp = 0;
            found_collision = true;
            break;
        }
    }
    
    // If no collision found, move normally
    if (!found_collision) {
        y += vsp;
    }
} else {
    // Moving up - check for collisions
    if (place_meeting(x, y + vsp, obj_floor)) {
        // Move until just before collision
        //while (!place_meeting(x, y - 1, obj_floor) && vsp < 0) {
            //y -= 1;
        //}
        vsp = 1;
    } else {
        // No collision, move normally
        y += vsp;
    }
}

// Final ground check after movement - FIXED version
if (place_meeting(x, y+1, obj_floor) || 
    (vsp >= 0 && place_meeting(x, y+1, obj_jump_through) && !place_meeting(x, y, obj_jump_through))) {
    can_jump = true;
} else {
    can_jump = false;
}

// Debug information
show_debug_message("vsp: " + string(vsp) + ", can_jump: " + string(can_jump) + ", on_jump_through: " + string(on_jump_through));