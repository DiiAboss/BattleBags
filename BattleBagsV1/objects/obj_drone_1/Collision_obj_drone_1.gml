/// @description

if (drone.blocks_carried <= 0 || other.drone.blocks_carried <= 0)
{
    
}
else {
    if (other.drone.id > drone.id) drone.walk_direction = (other.drone.walk_direction > 90 && other.drone.walk_direction < 270) ? 180 : 0;
        
    // Get direction away from the colliding block
    var angle = point_direction(other.drone.x, other.drone.y, drone.x, drone.y);
    
    // Push away with a stronger force
    var push_distance = 4; // Increase this value if blocks are still too close
    
    //direction += dcos(point_direction(x, y, other.x, other.y)) + dsin(point_direction(x, y, other.x, other.y));
    
        drone.y += dsin(angle) * push_distance;
        //other.y -= dsin(angle) * push_distance * 0.5;
        direction = point_direction(other.drone.x, other.drone.y, drone.x, drone.y);
        speed = push_distance;
    
        drone.x += dcos(angle) * push_distance * 0.25;
        
        
        
        // Optional: Slightly nudge the other block too
        other.drone.x -= (dcos(angle) * push_distance * 0.25);
    
}
