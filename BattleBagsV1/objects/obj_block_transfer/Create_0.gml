/// @description

target_x = room_width - 64;

if (instance_exists(obj_recycler))
{
    target_x = obj_recycler.x;
    var target_y = obj_recycler.y;
    speed = 8;
    direction = point_direction(x, y, target_x, target_y);
}

my_image = 0;
my_size = 1;
my_value = 0;