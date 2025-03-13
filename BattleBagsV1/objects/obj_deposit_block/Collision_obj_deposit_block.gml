/// @description

// Get direction away from the colliding block
var angle = point_direction(other.x, other.y, x, y);

// Push away with a stronger force
var push_distance = 4; // Increase this value if blocks are still too close

//direction += dcos(point_direction(x, y, other.x, other.y)) + dsin(point_direction(x, y, other.x, other.y));

if !(falling) 
{
    y += dsin(angle) * push_distance;
    //other.y -= dsin(angle) * push_distance * 0.5;
    direction = point_direction(other.x, other.y, x, y);
    speed = push_distance;
}
else {
    x += dcos(angle) * push_distance * 0.25;
    
    
    
    // Optional: Slightly nudge the other block too
    other.x -= (dcos(angle) * push_distance * 0.25);
}
