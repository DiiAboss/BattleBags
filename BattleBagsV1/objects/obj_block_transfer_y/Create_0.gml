/// @description

target_y = 256;
depth = -room_height;

if (instance_exists(obj_target))
{
    var target_x = obj_target.x;
    target_y = obj_target.y;
    speed = 8;
    direction = point_direction(x, y, target_x, target_y);
}

my_image = 0;
my_size = 1;
my_value = obj_game_control.combo;