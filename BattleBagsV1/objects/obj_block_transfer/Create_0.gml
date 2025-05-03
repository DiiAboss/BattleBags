/// @description

target_y = 256;
depth = -room_height;
default_speed = 8;
if (instance_exists(obj_target))
{
    var target_x = obj_target.x;
    target_y = obj_target.y;
    speed = 8;
    direction = point_direction(x, y, target_x, target_y);
}

my_image = 0;
size = 1;
my_value = size;
sprite = spr_transfer_block;
rotation_speed = 0;
color = c_white;
rot = 90;