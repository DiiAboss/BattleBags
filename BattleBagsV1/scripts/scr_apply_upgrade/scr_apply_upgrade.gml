function apply_upgrade(upgrade) {
    switch (upgrade.effect) {
        case "fire_boost":
            //global.fire_damage += 1;
            break;
        case "slow_fall":
           // global.fall_speed *= 0.8; // 20% slower
            break;
        case "more_yellow":
            global.color_spawn_weight[BLOCK.YELLOW] += 2;
            break;
        case "extra_time":
            global.gameSpeed -= 1;
            break;
    }

    instance_destroy(obj_upgrade_menu);
}
