// STEP EVENT
// Movement logic
if (wait_counter > 0) {
    // We're waiting at an endpoint
    wait_counter -= 1;
    
    // When wait is over, change direction
    if (wait_counter <= 0) {
        dir *= -1;
        start_x = x;
        start_y = y;
    }
    
    last_h_move = 0;
    last_v_move = 0;
} else {
    // Calculate movement this step
    var move_h = h_speed * dir;
    var move_v = v_speed * dir;
    
    // Check if we've reached an endpoint
    var dist_traveled_h = abs(x - start_x);
    var dist_traveled_v = abs(y - start_y);
    
    // Apply movement and store it for later
    x += move_h;
    y += move_v;
    
    // Remember how much we moved this step
    last_h_move = move_h;
    last_v_move = move_v;
    
    // Clear rider flag (will be set in End Step if needed)
    has_rider = false;
    
    if ((h_speed != 0 && dist_traveled_h >= move_distance) || 
    (v_speed != 0 && dist_traveled_v >= move_distance)) {
    // We've reached maximum distance, start waiting
    wait_counter = wait_time;
    }
}
