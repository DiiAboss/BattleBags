/// @description Create Upgrade Menu
array_size = min(3, ds_list_size(global.upgrade_pool )); // ✅ Ensure we don't pick more than available
upgrade = array_create(array_size);

global.upgrade_positions = array_create(array_size); // Store button positions

var x_start = (room_width / 2) - (384 * 1);
var y_start = 300;

// ✅ Create a temporary list to store selectable upgrades
var available_upgrades = ds_list_create();
ds_list_copy(available_upgrades, global.upgrade_pool );

// ✅ Select up to `array_size` unique upgrades
for (var i = 0; i < array_size; i++) {
    if (ds_list_size(available_upgrades) > 0) {
        var index = irandom(ds_list_size(available_upgrades) - 1); // Pick a random upgrade
        upgrade[i] = available_upgrades[| index]; // Select the upgrade

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
