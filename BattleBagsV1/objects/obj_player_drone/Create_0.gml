// CREATE EVENT
name = "";
walk_speed = 2;
run_speed = 3;
jump_speed = -12;
grv = 0.4;        // Reduced gravity for better jump feel
move_dir = 0;

// Movement variables
hsp = 0;          // Horizontal speed
vsp = 0;          // Vertical speed
max_fall_speed = 10; // Maximum falling speed
can_jump = false;
jump_through = true; // Enable jump through platforms
jump_buffer = 0;     // For jump buffering
jump_buffer_max = 10; // Frames to buffer a jump
coyote_time = 0;     // For coyote time
coyote_time_max = 5; // Frames of coyote time

my_dir = 1;
platform_id = noone;   // Reference to platform the player is standing on
on_moving_platform = false;