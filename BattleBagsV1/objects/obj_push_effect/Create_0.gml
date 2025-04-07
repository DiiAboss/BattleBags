/// @description
// Then create a new object called obj_push_effect with this code in the Create event:
/// @description Initialize push effect
radius = 32;
push_strength = 2;
push_duration = 10;
current_duration = 0;

// Add a ring effect visual
effect_alpha = 1;
effect_scale = 0;
max_scale = radius / 16;  // Scale to match radius