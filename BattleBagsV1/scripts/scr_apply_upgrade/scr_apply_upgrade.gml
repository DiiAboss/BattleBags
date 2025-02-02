function apply_upgrade(upgrade) {
    var level = get_upgrade_level(); // Assign level dynamically

    switch (upgrade.effect) {
        case "more_red": global.color_spawn_weight[BLOCK.RED] += level; break;
        case "more_yellow": global.color_spawn_weight[BLOCK.YELLOW] += level; break;
        case "more_green": global.color_spawn_weight[BLOCK.GREEN] += level; break;
        case "more_pink": global.color_spawn_weight[BLOCK.PINK] += level; break;
        case "more_light_blue": global.color_spawn_weight[BLOCK.LIGHTBLUE] += level; break;
        case "more_purple": global.color_spawn_weight[BLOCK.PURPLE] += level; break;
        case "more_orange": global.color_spawn_weight[BLOCK.ORANGE] += level; break;

        case "more_bombs": adjust_powerup_weights(POWERUP.BOMB, level); break;
        case "more_multi": adjust_powerup_weights(POWERUP.MULTI_2X, level); break;
        case "more_bows": adjust_powerup_weights(POWERUP.BOW, level); break;
        case "more_exp": adjust_powerup_weights(POWERUP.EXP, level); break;
        case "more_hearts": adjust_powerup_weights(POWERUP.HEART, level); break;
        case "more_money": adjust_powerup_weights(POWERUP.MONEY, level); break;
        case "more_timers": adjust_powerup_weights(POWERUP.TIMER, level); break;
        case "more_wild_potions": adjust_powerup_weights(POWERUP.WILD_POTION, level); break;

        case "extra_time": global.gameSpeed -= (0.1 * level); break;
    }

    instance_destroy(obj_upgrade_menu);
}


