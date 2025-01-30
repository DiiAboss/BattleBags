/// @description Insert description here
// You can write your code in this editor
if (global.paused) {
	speed = 0;
	return;
}
	speed = spd;
	effect_create_depth(depth, ef_smoke, x, y, 0.5, color);
