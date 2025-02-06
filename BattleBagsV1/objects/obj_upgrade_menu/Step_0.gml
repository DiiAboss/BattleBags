
if (!upgrade_pool[0])
{
	global.all_stats_maxed = true;
}


// ✅ If no upgrades are available, do NOT open the menu
if (global.all_stats_maxed) {
    //show_message("All upgrades have reached max level!");
    instance_destroy();
}

// ✅ Press 1, 2, or 3 to choose an upgrade via keyboard
if (keyboard_check_pressed(ord("1"))) apply_upgrade(upgrade_pool[0]);
if (keyboard_check_pressed(ord("2"))) apply_upgrade(upgrade_pool[1]);
if (keyboard_check_pressed(ord("3"))) apply_upgrade(upgrade_pool[2]);

// ✅ Check for mouse click on upgrades (Fixes click issue)
if (mouse_check_button_pressed(mb_left)) {
    var mx = mouse_x;
    var my = mouse_y;

    for (var i = 0; i < array_size; i++) {
        var btn = global.upgrade_positions[i];

        // Adjust hitbox to account for hover animation size increase
        var hitbox_size = 128 * 1.1; // Hovered images scale up, so adjust hitbox
        if (mx >= btn.x - hitbox_size / 2 && mx <= btn.x + hitbox_size / 2 &&
            my >= btn.y - hitbox_size / 2 && my <= btn.y + hitbox_size / 2) {

			
            apply_upgrade(upgrade_pool[i]);
			
			instance_destroy();

        }
    }
}
