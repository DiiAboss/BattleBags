/// @function get_upgrade_current_stat(effect)
/// @description Retrieves the current value of the specified upgrade effect.
function get_upgrade_current_stat(effect) {
    switch (effect) {
        // 🎨 **Color Spawn Rates**
        case "more_red": return global.color_spawn_weight[BLOCK.RED];
        case "more_yellow": return global.color_spawn_weight[BLOCK.YELLOW];
        case "more_green": return global.color_spawn_weight[BLOCK.GREEN];
        case "more_pink": return global.color_spawn_weight[BLOCK.PINK];
        case "more_light_blue": return global.color_spawn_weight[BLOCK.LIGHTBLUE];
		case "more_blue": return global.color_spawn_weight[BLOCK.BLUE];
        case "more_purple": return global.color_spawn_weight[BLOCK.PURPLE];
        case "more_orange": return global.color_spawn_weight[BLOCK.ORANGE];
        case "more_black": return global.color_spawn_weight[BLOCK.BLACK];

        // 💥 **Power-Up Spawn Rates**
        case "more_bombs": return ds_map_find_value(global.powerup_weights, POWERUP.BOMB);
        case "more_multi": return ds_map_find_value(global.powerup_weights, POWERUP.MULTI_2X);
        case "more_bows": return ds_map_find_value(global.powerup_weights, POWERUP.BOW);
        case "more_exp": return ds_map_find_value(global.powerup_weights, POWERUP.EXP);
        case "more_hearts": return ds_map_find_value(global.powerup_weights, POWERUP.HEART);
        case "more_money": return ds_map_find_value(global.powerup_weights, POWERUP.MONEY);
        case "more_fire": return ds_map_find_value(global.powerup_weights, POWERUP.FIRE);
        case "more_ice": return ds_map_find_value(global.powerup_weights, POWERUP.ICE);
        case "more_timers": return ds_map_find_value(global.powerup_weights, POWERUP.TIMER);
        case "more_feather": return ds_map_find_value(global.powerup_weights, POWERUP.FEATHER);
        case "more_wild_potions": return ds_map_find_value(global.powerup_weights, POWERUP.WILD_POTION);

        // 🐢 **Game Speed Modifier**
        case "extra_time": return global.gameSpeed;

        // ❌ Default (If No Stat Exists)
        default: return "N/A";
    }
}
