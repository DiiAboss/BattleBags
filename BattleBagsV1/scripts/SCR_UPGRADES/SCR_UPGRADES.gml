
/// @desc Struct for an upgrade
///
/// @param _name
/// @param _desc
/// @param _effect
/// @param _rarity
/// @param _max_level

function create_upgrade(_name, _desc, _effect, _rarity, _max_level, _start_unlocked = false) {
    return {
        name: _name,
        desc: _desc,
        effect: _effect,
        rarity: _rarity,     // 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Epic, 5 = Legendary
        max_level: _max_level,
        level: 0,            // Start at level 0
        unlocked: _start_unlocked
    };
}
function bring_up_upgrade_menu() {

    // ✅ If no upgrades are available, do NOT open the menu
    if (global.all_stats_maxed)  {
        //show_message("All upgrades have reached max level!");
        return;
    }

    if (!instance_exists(obj_upgrade_menu)) {
        instance_create_depth(0, 0, 0, obj_upgrade_menu);
    } else {
        instance_destroy(obj_upgrade_menu); // Close menu
    }
}


/// @function get_upgrade_level()
/// @description Uses weighted probability to determine an upgrade level.
function get_upgrade_level(luck = 0) {
    var roll = irandom(99) + luck; // Roll between 0-99

    if (roll < 55) return 1;  // 60% chance (previously 50%)
    if (roll < 80) return 2;  // 25% chance (unchanged)
    if (roll < 90) return 3;  // 10% chance (slightly reduced)
    if (roll < 95) return 4;  // 3% chance (slightly reduced)
    if (roll < 98) return 5;  // 1% chance (unchanged)
    return 6;  // 1% chance (unchanged)
}


function generate_all_upgrades() {
    global.upgrade_pool      = ds_list_create();
    global.unlocked_upgrades = ds_list_create();

    // **Example Upgrades**
	
    ds_list_add(global.upgrade_pool, create_upgrade(
	"More Red Blocks", 
	"Red blocks appear more often.",       
	"more_red", 
	1, 
	5,
	true));
    
	ds_list_add(global.upgrade_pool, create_upgrade(
		"More Yellow Blocks",                // Name
		"Yellow blocks appear more often.",  // Description
		"more_yellow",                       // effect
		1,								     // rarity
		5,
		true));									 // max_level

		
	ds_list_add(global.upgrade_pool, create_upgrade(
		"More Green Blocks",  
		"Green blocks appear more often.", 
		"more_green",                       // effect
		1,								     // rarity
		5,
	true));
	ds_list_add(global.upgrade_pool, create_upgrade(
		"More Pink Blocks",   
		"Pink blocks appear more often.", 
		"more_pink",                       // effect
		1,								     // rarity
		5,
	true));
	ds_list_add(global.upgrade_pool, create_upgrade(
		"More Light Blue Blocks", 
		"Light Blue blocks appear more often.", 
		"more_light_blue",                       // effect
		1,								     // rarity
		5,
	true));
	ds_list_add(global.upgrade_pool, create_upgrade(
		"More Purple Blocks", 
		"Purple blocks appear more often.", 
		"more_purple",                       // effect
		1,								     // rarity
		5,
	true));
	ds_list_add(global.upgrade_pool, create_upgrade(
		"More Orange Blocks", 
		"Orange blocks appear more often.", 
		"more_orange",                       // effect
		1,								     // rarity
		5,
	true));
	ds_list_add(global.upgrade_pool, create_upgrade(
		"More Blue Blocks", 
		"Blue blocks appear more often.", 
		"more_blue",                       // effect
		1,								     // rarity
		5,
	true));
	
	
	
	ds_list_add(global.upgrade_pool, create_upgrade(
	"More Bombs",      
	"Bomb power-ups appear more often.",   
	"more_bombs", 
	2,
	3, 
	true));
	
	ds_list_add(global.upgrade_pool, create_upgrade(
	"More Multi-2X",      
	"Multi-2X power-ups appear more often.",   
	"more_multi", 
	2,
	3, 
	true));
	
	ds_list_add(global.upgrade_pool, create_upgrade(
	"More Bows",      
	"Bow power-ups appear more often.",   
	"more_bows", 
	2,
	3, 
	true));
	
	ds_list_add(global.upgrade_pool, create_upgrade(
	"More Hearts", "Heart power-ups appear more often.", "more_hearts", 
	2,
	3, 
	true));
	
	ds_list_add(global.upgrade_pool, create_upgrade(
	"More Money", "Money power-ups appear more often.", "more_money", 
	2,
	3, 
	true));
	
	ds_list_add(global.upgrade_pool, create_upgrade(
	"More Timers", "Timer power-ups appear more often.", "more_timers", 
	2,
	3, 
	true));
	
	ds_list_add(global.upgrade_pool, create_upgrade(
	"More Wild Potions", "Wild Potion power-ups appear more often.", "more_wild_potions", 
	2,
	3, 
	true));
	
    // 🔥 Unlock **only** starting upgrades
    for (var i = 0; i < ds_list_size(global.upgrade_pool); i++) {
        var upgrade = ds_list_find_value(global.upgrade_pool, i);
		
		
        if (upgrade.unlocked) ds_list_add(global.unlocked_upgrades, upgrade);
    }
}


function get_random_upgrade() {
    var roll = irandom(99);

    var rarity;
    if (roll < 50) rarity = 1; // 50% common
    else if (roll < 80) rarity = 2; // 30% uncommon
    else if (roll < 95) rarity = 3; // 15% rare
    else rarity = 4; // 5% epic/legendary

    // 🎯 Pick a random upgrade of that rarity
    var candidates = ds_list_create();
    for (var i = 0; i < ds_list_size(global.unlocked_upgrades); i++) {
        var upgrade = ds_list_find_value(global.unlocked_upgrades, i);
        if (upgrade.rarity == rarity) ds_list_add(candidates, upgrade);
    }

    if (ds_list_size(candidates) > 0) {
        var chosen = ds_list_find_value(candidates, irandom(ds_list_size(candidates) - 1));
        ds_list_destroy(candidates);
        return chosen;
    }

    ds_list_destroy(candidates);
    return ds_list_find_value(global.unlocked_upgrades, irandom(ds_list_size(global.unlocked_upgrades) - 1)); // Default pick
}

function apply_upgrade(upgrade) {
	
	var _self = obj_game_control;
	
	if !(upgrade)
	{
		global.all_stats_maxed = true;
		return;
		
	}
	
    if (upgrade.level < upgrade.max_level) {
        upgrade.level+=5;

        // 🔥 Apply Effects Based on Level
        switch (upgrade.effect) {
            case "more_red": global.color_spawn_weight[BLOCK.RED] += upgrade.level; break;
			case "more_green": global.color_spawn_weight[BLOCK.GREEN] += upgrade.level; break;
			case "more_yellow": global.color_spawn_weight[BLOCK.YELLOW] += upgrade.level; break;
			case "more_pink": global.color_spawn_weight[BLOCK.PINK] += upgrade.level; break;
			case "more_purple": global.color_spawn_weight[BLOCK.PURPLE] += upgrade.level; break;
			case "more_orange": global.color_spawn_weight[BLOCK.ORANGE] += upgrade.level; break;
			case "more_light_blue": global.color_spawn_weight[BLOCK.LIGHTBLUE] += upgrade.level; break;
			case "more_blue": global.color_spawn_weight[BLOCK.BLUE] += upgrade.level; break;
            case "more_bombs": adjust_powerup_weights(POWERUP.BOMB, upgrade.level); break;
			case "more_multi": adjust_powerup_weights(POWERUP.MULTI_2X, upgrade.level); break;
			case "more_bows": adjust_powerup_weights(POWERUP.BOW, upgrade.level); break;
			case "more_exp": adjust_powerup_weights(POWERUP.EXP, upgrade.level); break;
			case "more_hearts": adjust_powerup_weights(POWERUP.HEART, upgrade.level); break;
			case "more_timers": adjust_powerup_weights(POWERUP.TIMER, upgrade.level); break;
			case "more_wild_potions": adjust_powerup_weights(POWERUP.WILD_POTION, upgrade.level); break;
            //case "crit_chance": _self.crit_chance_mod += 5; break;
            //case "gold_pickup_mod": _self.gold_pickup_mod += 10; break;
        }
    }
}

function unlock_upgrade(_effect, _cost) {
    if (global.gold >= _cost) {
        global.gold -= _cost;

        for (var i = 0; i < ds_list_size(global.upgrade_pool); i++) {
            var upgrade = ds_list_find_value(global.upgrade_pool, i);
            if (upgrade.effect == _effect && !upgrade.unlocked) {
                upgrade.unlocked = true;
                ds_list_add(global.unlocked_upgrades, upgrade);
                return true; // ✅ Success
            }
        }
    }
    return false; // ❌ Not enough gold or already unlocked
}

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
        case "more_bows":  return ds_map_find_value(global.powerup_weights, POWERUP.BOW);
        case "more_exp":   return ds_map_find_value(global.powerup_weights, POWERUP.EXP);
        case "more_hearts": return ds_map_find_value(global.powerup_weights, POWERUP.HEART);
        case "more_money": return ds_map_find_value(global.powerup_weights, POWERUP.MONEY);
        case "more_fire": return ds_map_find_value(global.powerup_weights, POWERUP.FIRE);
        case "more_ice": return ds_map_find_value(global.powerup_weights, POWERUP.ICE);
        case "more_timers": return ds_map_find_value(global.powerup_weights, POWERUP.TIMER);
        case "more_feather": return ds_map_find_value(global.powerup_weights, POWERUP.FEATHER);
        case "more_wild_potions": return ds_map_find_value(global.powerup_weights, POWERUP.WILD_POTION);

        // 🐢 **Game Speed Modifier**
        case "extra_time": return obj_game_control.game_speed_default;

        // ❌ Default (If No Stat Exists)
        default: return "N/A";
    }
}


/// @function get_upgrade_sprite(effect)
/// @desc Returns the correct sprite for an upgrade, based on the block or powerup it affects.
function get_upgrade_sprite(effect) {
    switch (effect) {
        case "more_red":        return sprite_for_gem(BLOCK.RED);
        case "more_yellow":     return sprite_for_gem(BLOCK.YELLOW);
        case "more_green":      return sprite_for_gem(BLOCK.GREEN);
        case "more_pink":       return sprite_for_gem(BLOCK.PINK);
        case "more_light_blue": return sprite_for_gem(BLOCK.LIGHTBLUE);
        case "more_purple":     return sprite_for_gem(BLOCK.PURPLE);
        case "more_orange":     return sprite_for_gem(BLOCK.ORANGE);
		case "more_blue":       return sprite_for_gem(BLOCK.BLUE);
        case "more_bombs":      return spr_powerup_bomb;
        case "more_multi":      return spr_powerup_2x_multi;
        case "more_bows":       return spr_powerup_destroy_to_right;
        case "more_exp":        return spr_powerup_exp;
        case "more_hearts":     return spr_powerup_heart;
        case "more_money":      return spr_powerup_money;
        case "more_timers":     return spr_powerup_timer;
        case "more_wild_potions": return spr_powerup_wild_potion;

        default: return spr_none; // If no matching sprite, use a placeholder
    }
}

