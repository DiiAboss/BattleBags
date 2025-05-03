/// @description

// In Create Event
rotation = 0;             // Current angle
angular_velocity = 0.5;   // Initial velocity (start with some motion)
max_rotation = 45;        // Maximum swing angle
dir = 1;                  // Initial direction
_gravity_constant = 0.15; // Pendulum gravity (higher = faster swing)
damping = 0.995;          // Energy loss (closer to 1 = less loss)
impulse_force = 1;        // Force applied on keypress
falling = false;