enum POWERUP 
{
	NONE     = -1,
	SWORD    = 0,
	BOW      = 1,
	BOMB     = 2,
	MULTI_2X = 3,
	EXP      = 4,
	HEART    = 5,
	MONEY    = 6,
	POISON   = 7,
	FIRE     = 8,
	ICE      = 9,
	TIMER    = 10,
	FEATHER  = 11,
	WILD_POTION = 12,
	
}

// Total probability pool
var TOTAL_CHANCE = 100;

function adjust_powerup_weights(powerup, increase_amount) {
    // Ensure powerup exists in the map
    if (ds_map_exists(global.powerup_weights, powerup)) {
        var current_weight = ds_map_find_value(global.powerup_weights, powerup);
        ds_map_replace(global.powerup_weights, powerup, current_weight + increase_amount);
    }
}



// Power-up weight map (higher value = more frequent)
global.powerup_weights = ds_map_create();
ds_map_add(global.powerup_weights, POWERUP.BOMB, 10);
ds_map_add(global.powerup_weights, POWERUP.MULTI_2X, 0);
ds_map_add(global.powerup_weights, POWERUP.BOW, 0);
ds_map_add(global.powerup_weights, POWERUP.EXP, 1);
ds_map_add(global.powerup_weights, POWERUP.HEART, 1);
ds_map_add(global.powerup_weights, POWERUP.MONEY, 1);
ds_map_add(global.powerup_weights, POWERUP.POISON, 0);
ds_map_add(global.powerup_weights, POWERUP.FIRE, 0);
ds_map_add(global.powerup_weights, POWERUP.ICE, 0);
ds_map_add(global.powerup_weights, POWERUP.TIMER, 0);
ds_map_add(global.powerup_weights, POWERUP.FEATHER, 0);
ds_map_add(global.powerup_weights, POWERUP.WILD_POTION, 0); // Very rare

// ✅ Dynamically calculate NONE chance
var sum_chances = 0;
var keys = ds_map_find_first(global.powerup_weights);
while (keys != undefined) {
    sum_chances += ds_map_find_value(global.powerup_weights, keys);
    keys = ds_map_find_next(global.powerup_weights, keys);
}

// ✅ Ensure we don’t exceed TOTAL_CHANCE
var chance_none = max(0, TOTAL_CHANCE - sum_chances);
ds_map_add(global.powerup_weights, POWERUP.NONE, chance_none);



function create_powerup(_powerup = -1, _chance = 25) {
	
	var _sprite = spr_powerup_1;
	var _dir = choose(0, 90, 180, 270);
	var _bomb_tracker = false;
	switch (_powerup)
	{
		case POWERUP.SWORD:
			_sprite = spr_powerup_1;
		break;
		case POWERUP.BOW:
		    switch (_dir)
			{
				case 0:
					_sprite = spr_powerup_destroy_to_right;
				break;
				case 90:
					_sprite = spr_powerup_destroy_to_up;
				break;
				case 180:
					_sprite = spr_powerup_destroy_to_left;
				break;
				case 270:
					_sprite = spr_powerup_destroy_to_down;
				break;
			}
			
		break;
		case POWERUP.BOMB:
			_sprite = spr_powerup_bomb;
			_bomb_tracker = true;
		break;
		case POWERUP.MULTI_2X:
			_sprite = spr_powerup_2x_multi;
		break;
		case POWERUP.EXP:
			_sprite = spr_powerup_exp;
		break;
		case POWERUP.HEART:
			_sprite = spr_powerup_heart;
		break;
		case POWERUP.MONEY:
			_sprite = spr_powerup_money;
		break;
		case POWERUP.POISON:
			_sprite = spr_powerup_poison;
		break;
		case POWERUP.FIRE:
			_sprite = spr_powerup_fire;
		break;
		case POWERUP.ICE:
			_sprite = spr_powerup_ice;
		break;
		case POWERUP.TIMER:
			_sprite = spr_powerup_timer;
		break;
		case POWERUP.FEATHER:
			_sprite = spr_powerup_feather;
		break;
		case POWERUP.WILD_POTION:
			_sprite = spr_powerup_wild_potion;
		break;
		
		default:
		   _sprite = spr_none;
		break;
		
	}
    return {
        powerup: _powerup, // Power-up type (e.g., 0 for bomb, 1 for rainbow, etc.)
		sprite: _sprite,
		chance: _chance,
		dir: _dir,
		size: 1,
		bomb_tracker: _bomb_tracker,
		bomb_level: 1,
		color: c_white
    };
}


function weighted_random_powerup() {
    var powerup_list = ds_list_create();
    
    // Add power-ups to list based on weights
    var map_keys = ds_map_find_first(global.powerup_weights);
    while (map_keys != undefined) {
        var powerup = map_keys;
        var weight = ds_map_find_value(global.powerup_weights, powerup);
        
        for (var i = 0; i < weight; i++) {
            ds_list_add(powerup_list, powerup);
        }

        map_keys = ds_map_find_next(global.powerup_weights, map_keys);
    }

    // ✅ Select a random power-up from the weighted list
    var selected_powerup_type = ds_list_find_value(powerup_list, irandom(ds_list_size(powerup_list) - 1));
    
    ds_list_destroy(powerup_list);
    
    // ✅ If NONE was selected, return -1 (no power-up)
    if (selected_powerup_type == POWERUP.NONE) {
        return -1;
    }

    return create_powerup(selected_powerup_type);
}
