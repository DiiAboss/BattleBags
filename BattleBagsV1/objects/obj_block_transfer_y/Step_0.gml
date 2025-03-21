/// @description
if (global.paused){
    speed = 0;
    return;
}
else {
    speed = default_speed;
}

if (y < target_y) 
{
    var t = instance_create_depth(obj_target.x, obj_target.y, depth, obj_block_transfer);
    t.my_image = my_image;
    t.my_size = my_size;
    t.my_value = my_value;
    t.sprite = sprite;
    instance_destroy();
}
   
