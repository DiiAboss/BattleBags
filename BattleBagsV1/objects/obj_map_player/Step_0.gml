/// @description



if (target != noone)
{
    direction = point_direction(x, y, target.x, target.y);
    
    
    if (distance_to_point(target.x, target.y) > max_speed)
    {
        x += lengthdir_x(move_speed, direction);
        y += lengthdir_y(move_speed, direction);
    }
    else {
        
    }

}
