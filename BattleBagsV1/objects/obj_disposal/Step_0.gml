/// @description
if (place_meeting(x, y+32, obj_deposit_block))
{
	splash_timer = 10;
	
	with (instance_nearest(x, y, obj_deposit_block))
	{
		
// Create a one-time particle system that auto-destroys
var ps = part_system_create();
part_system_depth(ps, depth-1);

// Create the particle type
var pt = part_type_create();
part_type_sprite(pt,sprite, 0, 0, 1);  // Simple square shape
part_type_size(pt, 0.15, 0.25, -0.002, 0);  // Size relative to object
part_type_speed(pt, 1, 3, -0.02, 0);  // Initial speed with deceleration
part_type_direction(pt, 45, 90, 2, 2);  // Random directions
part_type_gravity(pt, 0.1, 270);  // Add gravity
part_type_orientation(pt, 0, 359, 1, 0, true);  // Random rotation
//part_type_color3(pt, color, color, color);  // Simple color transition
part_type_alpha3(pt, 1, 0.2, 0);  // Fade out
part_type_life(pt, room_speed * 0.4, room_speed * 1);  // Live for 0.4-1 seconds

// Create 16 particles in a grid pattern (4x4)
for (var i = 0; i < 4; i++) {
    for (var j = 0; j < 4; j++) {
        // Calculate position for this fragment
        var frag_x = x - sprite_width/2 + (i * sprite_width/4) + sprite_width/8;
        var frag_y = y - sprite_height/2 + (j * sprite_height/4) + sprite_height/8;
        
        // Create particle with slight position variation
        part_particles_create(ps, 
            frag_x + random_range(-2, 2), 
            frag_y + random_range(-2, 2), 
            pt, 1);
    }
}

// Schedule the particles for destruction (using an alarm in the same object)

// Store the particle system and type in variables so the alarm can clean them up
// Create a self-destructing controller that cleans up
    with (instance_create_layer(0, 0, "Instances", obj_part_controller)) {
        self.ps = ps;
		self.pt = pt
        self.fragments = fragments;
        alarm[0] = room_speed * 2; // Cleanup after 2 seconds
    }
 
 instance_destroy();

		
	}
}



if splash_timer > 0
{
	splash_timer -= 1;
	image_index = 1;
}
else {
	image_index = 0;
}

