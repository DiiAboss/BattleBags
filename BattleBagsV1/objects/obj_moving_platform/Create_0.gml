// CREATE EVENT
// Platform movement settings
h_speed = 0;           // Horizontal speed
v_speed = 1;           // Vertical speed (0 for horizontal-only movement)
move_distance = 600;   // Distance to travel before turning around
wait_time = 60;        // Frames to wait at endpoints (1 second at 60 FPS)

// Important: initialize these variables
last_h_move = 0;
last_v_move = 0;

// Internal variables
start_x = x;          // Starting X position
start_y = y;          // Starting Y position 
dir = -1;        // 1 = right/down, -1 = left/up
wait_counter = 0;     // Counter for waiting at endpoints
has_rider = false;    // Tracks if player is on the platform
carried_instance = noone; // Reference to the instance being carried