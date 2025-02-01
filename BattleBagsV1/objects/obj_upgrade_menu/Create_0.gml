/// @description Create Upgrade Menu
array_size = 3;
upgrade = array_create(array_size);

// ✅ Ensure `global.upgrades` is a `ds_list`
if (!variable_global_exists("global.upgrades")) {
    global.upgrades = ds_list_create();
}


ds_list_add(global.upgrades, create_upgrade(
    "🕒 Slow Drop", 
    "Blocks fall " + string(10 * get_upgrade_level()) + "% slower.",
    "slow_fall",
    get_upgrade_level()
));

ds_list_add(global.upgrades, create_upgrade(
    "🟡 More Color Spawn", 
    "Yellow blocks appear " + string(2 * get_upgrade_level()) + "% more frequently.",
    "more_yellow",
    get_upgrade_level()
));

ds_list_add(global.upgrades, create_upgrade(
    "⏳ Extra Time", 
    "Reduces game speed by " + string(0.1 * get_upgrade_level()) + "x.",
    "extra_time",
    get_upgrade_level()
));

ds_list_add(global.upgrades, create_upgrade(
    "💣 Power-Up Boost", 
    "Power-ups appear " + string(5 * get_upgrade_level()) + "% more often.",
    "increase_powerup_spawn",
    get_upgrade_level()
));

// ✅ Select 3 random upgrades from the list
for (var i = 0; i < array_size; i++) {
    var index = irandom(ds_list_size(global.upgrades) - 1);
    upgrade[i] = ds_list_find_value(global.upgrades, index);
}


global.upgrade_positions = array_create(array_size); // Store button positions

var x_start = (room_width / 2) - (256 * 1.5);
var y_start = 200;

// ✅ Select 3 random upgrades from the global list
for (var i = 0; i < array_size; i++) {
    var index = irandom(ds_list_size(global.upgrades) - 1);
    upgrade[i] = global.upgrades[| index];

    // ✅ Store button positions for clicking
    global.upgrade_positions[i] = {
        x: x_start + (i * 280),  // Spaced horizontally
        y: y_start,
        width: 256,
        height: 256
    };
}

depth = -99;