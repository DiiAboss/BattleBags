function bring_up_upgrade_menu()
{
	global.paused = !global.paused;
    if (!instance_exists(obj_upgrade_menu)) {
        instance_create_depth(room_width / 2, room_height / 2, 0, obj_upgrade_menu);
    } else {
        instance_destroy(obj_upgrade_menu); // Close menu
    }
}