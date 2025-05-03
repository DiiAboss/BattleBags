/// @description

if (target == noone) return;
    
next_x = x + lengthdir_x(move_speed, target_direction);
next_y = y + lengthdir_y(move_speed, target_direction);
var tar = instance_place(x, y, obj_bullet);
if (tar)
{
    my_hp -= tar.attack;
    with (tar)
    {
        instance_destroy();
    }
    
}

if (my_hp <= 0)
{
    instance_destroy();
}

if (distance_to_point(target.x, target.y) > 32)
{  
    target_direction = point_direction(x, y, target.x, target.y);
    x += lengthdir_x(move_speed, target_direction);
    y += lengthdir_y(move_speed, target_direction);
}

else {
    instance_destroy();
    
    switch(target)
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