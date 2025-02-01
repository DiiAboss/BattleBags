function apply_upgrade(upgrade) {
    // Get the upgrade level using weighted probability
    var level = get_upgrade_level();
    upgrade.level = level; // Assign the level to the upgrade

    switch (upgrade.effect) {
        // 🔴 Increase spawn rate for RED blocks
        case "more_red":
            global.color_spawn_weight[BLOCK.RED] += level;
            break;

        // 🟡 Increase spawn rate for YELLOW blocks
        case "more_yellow":
            global.color_spawn_weight[BLOCK.YELLOW] += level;
            break;

        // 🟢 Increase spawn rate for GREEN blocks
        case "more_green":
            global.color_spawn_weight[BLOCK.GREEN] += level;
            break;
		
		        // 🔵 Increase spawn rate for BLUE blocks
        case "more_pink":
            global.color_spawn_weight[BLOCK.LIGHTBLUE] += level;
            break;

        // 🔵 Increase spawn rate for BLUE blocks
        case "more_light_blue":
            global.color_spawn_weight[BLOCK.LIGHTBLUE] += level;
            break;

        // 🟣 Increase spawn rate for PURPLE blocks
        case "more_purple":
            global.color_spawn_weight[BLOCK.PURPLE] += level;
            break;

        // 🟠 Increase spawn rate for ORANGE blocks
        case "more_orange":
            global.color_spawn_weight[BLOCK.ORANGE] += level;
            break;


        // 🔥 Increase only BOMB power-up spawn rate
        case "more_bombs":
            adjust_powerup_weights(POWERUP.BOMB, level);
            break;

        // 💥 Increase only MULTI 2X power-up spawn rate
        case "more_multi":
            adjust_powerup_weights(POWERUP.MULTI_2X, level);
            break;

        // 🎯 Increase only BOW power-up spawn rate
        case "more_bows":
            adjust_powerup_weights(POWERUP.BOW, level);
            break;

        // 🌟 Increase only EXP power-up spawn rate
        case "more_exp":
            adjust_powerup_weights(POWERUP.EXP, level);
            break;

        // 💖 Increase only HEART power-up spawn rate
        case "more_hearts":
            adjust_powerup_weights(POWERUP.HEART, level);
            break;

        // 💰 Increase only MONEY power-up spawn rate
        case "more_money":
            adjust_powerup_weights(POWERUP.MONEY, level);
            break;



        // ⏳ Increase only TIMER power-up spawn rate
        case "more_timers":
            adjust_powerup_weights(POWERUP.TIMER, level);
            break;


        // 🍷 Increase only WILD POTION power-up spawn rate
        case "more_wild_potions":
            adjust_powerup_weights(POWERUP.WILD_POTION, level);
            break;

        // ⏩ Decrease game speed per upgrade level
        case "extra_time":
            global.gameSpeed -= (0.1 * level);
            break;
    }

    // Remove upgrade menu after selection
    instance_destroy(obj_upgrade_menu);
}

