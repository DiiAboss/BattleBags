/// @description

if (my_target == noone) return;
    


if (distance_to_point(my_target.x, my_target.y) > 32)
{  
    target_direction = point_direction(x, y, my_target.x, my_target.y);
    x += lengthdir_x(move_speed, target_direction);
    y += lengthdir_y(move_speed, target_direction);
}

else {
    
    switch(my_target)
    {
        case obj_recycler:
            
        break;
        
        case obj_deposit_block:
            
        break;
        
        case obj_conveyor_belt:
            
        break;
        default: 
            
        break;
        
    }
}