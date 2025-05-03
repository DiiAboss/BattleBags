/// @description
conveyor = obj_conveyor_belt;
sprite = spr_sorter_drone;

hand_sprite = spr_sorter_drone_hand;
hand_x = x;
hand_y = y;

conveyor_x = conveyor.conveyor_x_start + conveyor.conveyor_width;
array_push(conveyor.conveyor_drones, self);

range = 32;

range_min = y - range;
range_max = y + range;

active = false;
depth = -y;