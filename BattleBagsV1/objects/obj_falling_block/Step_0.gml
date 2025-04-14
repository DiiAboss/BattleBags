/// @description
// Step Event:
// Move downward
y += fall_speed;

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