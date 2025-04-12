drone_x = 0;
    drone_y = 0;
    my_sprite = spr_clay_drone;
    experience = 0;
    max_experience = 100;
    level = 1;
    max_level = 10;
    target = noone;
    walk_direction = 0;
    aim_direction = 0;
    color = c_white;
    carry_capacity = 8;
    throw_distance = 128;
    selected = false;

    
    // Block carrying state
    blocks_carried = 0;
    carried_blocks = array_create(0); // Stores info about carried blocks
    
    // Movement properties
    move_speed = 4;
    state = "seeking"; // seeking, collecting, delivering, idle
    
    // Timers and counters
    pickup_timer = 0;
    max_pickup_timer = 15;
    throw_timer  = 0;
    max_throw_timer = 15;
    drone_x      = room_width * 0.6 + irandom(room_width * 0.3);
    drone_y      = room_height - 256;
    game_control = obj_game_control;

    target = noone;

wait_to_return = 0;
wait_to_return_max = 60;

