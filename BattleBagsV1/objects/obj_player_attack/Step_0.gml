/// @description Insert description here
// You can write your code in this editor
	// ✅ Stop everything except the pause check
if (global.paused) || global.in_upgrade_menu {
	return;
}


	speed = spd;
	effect_create_depth(depth, ef_smoke, x, y, 0.5, color);
