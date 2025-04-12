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
    var rec = obj_recycler;
    direction = point_direction(x, y, rec.x, rec.y);
	rot = 0;
}
