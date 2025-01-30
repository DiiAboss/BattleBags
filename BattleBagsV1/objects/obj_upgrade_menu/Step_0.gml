/// @description Insert description here
// You can write your code in this editor

var chosen_upgrades = [];

for (var i = 0; i < 3; i++) {
	array_push(chosen_upgrades, upgrade[i]);
	}

// ✅ Press 1, 2, or 3 to choose upgrade
if (keyboard_check_pressed(ord("1"))) apply_upgrade(chosen_upgrades[0]);
if (keyboard_check_pressed(ord("2"))) apply_upgrade(chosen_upgrades[1]);
if (keyboard_check_pressed(ord("3"))) apply_upgrade(chosen_upgrades[2]);
