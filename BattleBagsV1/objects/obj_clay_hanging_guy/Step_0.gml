/// @description Realistic Pendulum Physics

if !(falling)
{
	if (keyboard_check_pressed(vk_down))
{
	falling = true;
}
	
	// First, handle keyboard input to add force
if (keyboard_check_pressed(vk_right)) {
    angular_velocity += impulse_force;
}
if (keyboard_check_pressed(vk_left)) {
    angular_velocity -= impulse_force;
}

// Calculate pendulum physics
// True pendulum motion comes from: acceleration = -g * sin(angle)
// This gives acceleration proportional to position
var angle_radians = degtorad(rotation);
var pendulum_acceleration = -_gravity_constant * sin(angle_radians);

// Add acceleration to velocity
angular_velocity += pendulum_acceleration;

// Apply damping (air resistance)
angular_velocity *= damping;

// Update position with current velocity
rotation += angular_velocity;

// Handle rotation limits and direction changes
if (rotation > max_rotation) {
    rotation = max_rotation;
    angular_velocity *= -0.8; // Bounce with energy loss
    dir = -1;
} else if (rotation < -max_rotation) {
    rotation = -max_rotation;
    angular_velocity *= -0.8; // Bounce with energy loss
    dir = 1;
}

// Update sprite angle
image_angle = rotation;
}
else {
	
	if (y < room_height * 0.8)
{
	gravity = 0.25;
}
	else {
		gravity = 0;
		y = room_height * 0.8
	}
	
	if (y < room_height * 0.8) {
    sprite_index = spr_clay_hanging_guy_falling
	}
	else
		{
		sprite_index = spr_clay_hanging_guy_landed
	}
	//sprite_index = Sprite170
}


