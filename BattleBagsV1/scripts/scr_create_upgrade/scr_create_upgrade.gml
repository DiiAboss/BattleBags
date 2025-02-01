function create_upgrade(_name, _desc, _effect) {
    var upgrade = {
        name: _name,
        desc: _desc,
        effect: _effect
    };
    return upgrade;
}



// ✅ Define upgrade names (for reference)
enum UPGRADE {
    BOMB_START_LEVEL,       // Bombs start at level 2, then +1 per upgrade
    POWERUP_SPAWN_RATE,     // Increases overall power-up appearance
    SPECIFIC_GEM_POWERUP,   // Boosts power-up chance for a selected gem color
    COLOR_SPAWN_RATE,       // Increases spawn rate for a specific color
    WILD_POTION_SPAWN,      // Wild Potion blocks appear more often
    MAX_LEVEL_UPGRADE,      // Allows power-ups to exceed default max levels
    EXP_MULTIPLIER,         // Increases experience gained
}

// ✅ Initialize upgrades (start at level 0)
function init_upgrades() {
    ds_map_add(global.upgrades, UPGRADE.BOMB_START_LEVEL, 0);
    ds_map_add(global.upgrades, UPGRADE.POWERUP_SPAWN_RATE, 0);
    ds_map_add(global.upgrades, UPGRADE.SPECIFIC_GEM_POWERUP, 0);
    ds_map_add(global.upgrades, UPGRADE.COLOR_SPAWN_RATE, 0);
    ds_map_add(global.upgrades, UPGRADE.WILD_POTION_SPAWN, 0);
    ds_map_add(global.upgrades, UPGRADE.MAX_LEVEL_UPGRADE, 0);
    ds_map_add(global.upgrades, UPGRADE.EXP_MULTIPLIER, 0);
}




