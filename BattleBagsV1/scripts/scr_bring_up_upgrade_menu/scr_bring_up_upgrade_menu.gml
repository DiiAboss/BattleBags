function bring_up_upgrade_menu()
{
    if (!instance_exists(obj_upgrade_menu)) {
        instance_create_depth(room_width / 2, room_height / 2, 0, obj_upgrade_menu);
    } else {
        instance_destroy(obj_upgrade_menu); // Close menu
    }
}


/// @function get_upgrade_level()
/// @description Uses weighted probability to determine an upgrade level.
function get_upgrade_level() {
    var roll = irandom(99); // Roll between 0-99

    if (roll < 60) return 1;  // 60% chance (previously 50%)
    if (roll < 85) return 2;  // 25% chance (unchanged)
    if (roll < 95) return 3;  // 10% chance (slightly reduced)
    if (roll < 98) return 4;  // 3% chance (slightly reduced)
    if (roll < 99) return 5;  // 1% chance (unchanged)
    return 6;  // 1% chance (unchanged)
}

// 🔥 **Create and Apply All Upgrades Automatically**
function generate_all_upgrades() {
    //global.upgrades = ds_list_create();

    // 🟥 **Color Spawn Rate Upgrades**
    ds_list_add(global.upgrades, create_upgrade("🔥 More Red Blocks", "Red blocks appear more often.", "more_red", get_upgrade_level()));
    ds_list_add(global.upgrades, create_upgrade("🟡 More Yellow Blocks", "Yellow blocks appear more often.", "more_yellow", get_upgrade_level()));
    ds_list_add(global.upgrades, create_upgrade("🟢 More Green Blocks", "Green blocks appear more often.", "more_green", get_upgrade_level()));
    ds_list_add(global.upgrades, create_upgrade("🔵 More Pink Blocks", "Pink blocks appear more often.", "more_pink", get_upgrade_level()));
    ds_list_add(global.upgrades, create_upgrade("🔷 More Light Blue Blocks", "Light Blue blocks appear more often.", "more_light_blue", get_upgrade_level()));
    ds_list_add(global.upgrades, create_upgrade("🟣 More Purple Blocks", "Purple blocks appear more often.", "more_purple", get_upgrade_level()));
    ds_list_add(global.upgrades, create_upgrade("🟠 More Orange Blocks", "Orange blocks appear more often.", "more_orange", get_upgrade_level()));

    // 💥 **Power-Up Spawn Rate Upgrades**
    ds_list_add(global.upgrades, create_upgrade("💣 More Bombs", "Bomb power-ups appear more often.", "more_bombs", get_upgrade_level()));
    ds_list_add(global.upgrades, create_upgrade("🔄 More Multi-2X", "Multi-2X power-ups appear more often.", "more_multi", get_upgrade_level()));
    ds_list_add(global.upgrades, create_upgrade("🏹 More Bows", "Bow power-ups appear more often.", "more_bows", get_upgrade_level()));
    ds_list_add(global.upgrades, create_upgrade("🌟 More EXP", "EXP power-ups appear more often.", "more_exp", get_upgrade_level()));
    ds_list_add(global.upgrades, create_upgrade("💖 More Hearts", "Heart power-ups appear more often.", "more_hearts", get_upgrade_level()));
    ds_list_add(global.upgrades, create_upgrade("💰 More Money", "Money power-ups appear more often.", "more_money", get_upgrade_level()));
    ds_list_add(global.upgrades, create_upgrade("⏳ More Timers", "Timer power-ups appear more often.", "more_timers", get_upgrade_level()));
    ds_list_add(global.upgrades, create_upgrade("🍷 More Wild Potions", "Wild Potion power-ups appear more often.", "more_wild_potions", get_upgrade_level()));

    // ⏩ **Game Speed Modifier**
    ds_list_add(global.upgrades, create_upgrade("🐢 Extra Time", "Slows game speed by " + string(0.1 * get_upgrade_level()) + "x.", "extra_time", get_upgrade_level()));
}