/// @description Create Upgrade Menu
array_size = min(3, ds_list_size(global.upgrade_pool )); // ✅ Ensure we don't pick more than available
upgrade_pool = array_create(array_size);

global.upgrade_positions = array_create(array_size); // Store button positions

var x_start = (room_width / 2) - (384 * 1);
var y_start = 300;

// ✅ Create a temporary list to store only upgrades BELOW max level
var available_upgrades = ds_list_create();

for (var i = 0; i < ds_list_size(global.upgrade_pool); i++) {
    var upgrade = ds_list_find_value(global.upgrade_pool, i);

    // ✅ Only add upgrades that are NOT at max level
    if (upgrade.level < upgrade.max_level) {
        ds_list_add(available_upgrades, upgrade);
    }
}

// ✅ If no available upgrades exist, close the menu and return
if (global.all_stats_maxed) {
    //show_message("All upgrades have reached max level!");
    ds_list_destroy(available_upgrades);
    instance_destroy();
    return;
}

// ✅ Select up to `array_size` unique upgrades
for (var i = 0; i < array_size; i++) {

		if (ds_list_size(available_upgrades) > 0) {
		    var index = irandom(ds_list_size(available_upgrades) - 1); // Pick a random upgrade
		    upgrade_pool[i] = ds_list_find_value(available_upgrades, index); // Select the upgrade
		    ds_list_delete(available_upgrades, index); // ✅ Remove from available options
		


        ds_list_delete(available_upgrades, index); // ✅ Remove from available options to prevent duplicates
    }
    
    // ✅ Store button positions for clicking
    global.upgrade_positions[i] = {
        x: x_start + (i * 384),  // Spaced horizontally
        y: y_start,
        width: 256,
        height: 256
    };
}

// ✅ Destroy temporary list after use
ds_list_destroy(available_upgrades);

depth = -99;
numberOfGemTypes = obj_game_control.numberOfGemTypes;



obj_game_control.after_menu_counter = 0;
