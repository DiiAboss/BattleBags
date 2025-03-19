/// @description

// Get direction away from the colliding block
var angle = point_direction(other.x, other.y, x, y);

// Push away with a stronger force
var push_distance = scale * 0.1; // Increase this value if blocks are still too close

if !(other.falling) 
{
    y += dsin(angle) * push_distance;

    direction = point_direction(other.x, other.y, x, y);
    speed = (sign(rotation_speed) * push_distance * 0.1);
    x += sign(rotation_speed) * dcos(angle) * push_distance * 0.05 - 0.25;
    
    var other_push = (sign(rotation_speed) * (dcos(angle) * push_distance  * 0.1 + (0.1 * vsp)));
    other.x -= other_push;
    other.speed = other_push;
}
else {
    x += dcos(angle) * push_distance;
    vsp =+ other.vsp;
    falling = other.falling;
    
    
    var distance_to_bottom = point_distance(x, y, x, default_base);
    var blocks_to_bottom = distance_to_bottom / scale;
    
    
    // Optional: Slightly nudge the other block too
    other.x -= (dcos(angle) * push_distance);
}


