/// @description
// Step Event:
// Move downward
y += fall_speed;

if (x > 300 && x < 1200 && y > 64 && y < 600)
{
	if (temp_alpha > 0.25)
	{
		temp_alpha -= 0.05;
	}
	else {
		temp_alpha = 0.25;
	}
	
}
else {
	if (temp_alpha < alpha)
	{
		temp_alpha += 0.1;
	}
	else {
		temp_alpha = alpha;
	}
	
}

// Rotate if needed
if (has_rotation) {
    image_angle += rotation_speed;
}

// Start fading when reaching bottom of room
if (y > room_height - 100 && !fade_out) {
    fade_out = true;
}

// Handle fade out
if (fade_out) {
    alpha -= 0.02;
    if (alpha <= 0) {
        instance_destroy();
    }
}