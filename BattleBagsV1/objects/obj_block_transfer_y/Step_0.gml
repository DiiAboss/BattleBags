/// @description

if (y < target_y) 
{
    instance_destroy();
    instance_create_depth(obj_target.x, obj_target.y, depth, obj_block_transfer);
}
   
