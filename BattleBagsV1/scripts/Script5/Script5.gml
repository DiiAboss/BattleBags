// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
enum POWERUP 
{
	SWORD = 0,
	BOW   = 1,
	BOMB  = 2
}

function create_powerup(_powerup = -1, _chance = 0) {
	
	var _sprite = spr_powerup_1;
	switch (_powerup)
	{
		case POWERUP.SWORD:
			_sprite = spr_powerup_1;
		break;
		case POWERUP.BOW:
			_sprite = spr_powerup_2;
		break;
		case POWERUP.BOMB:
			_sprite = spr_powerup_3;
		break;
		default:
		   _sprite = spr_none;
		break;
		
	}
    return {
        powerup: _powerup, // Power-up type (e.g., 0 for bomb, 1 for rainbow, etc.)
		sprite: _sprite,
		chance: _chance
    };
}


function create_gem(_type, _powerup = create_powerup(irandom(3))) {
	
	var _color = c_white;
	
	switch(_type)
	{
		case 0:
		_powerup = -1;
		_color = c_red;
		break;
		case 1:
		_powerup = -1;
		_color = c_yellow;
		break;
		case 2:
		_powerup = -1;
		_color = c_lime;
		break;
		case 3:
		_color = c_fuchsia;
		break;
		case 4:
		_color = c_purple;
		break;
		case 5:
		_color = c_silver;
		break;
		case 6:
		_color = c_red;
		break;
		case 7:
		_color = c_orange;
		break;
	}
	
    return {
        type: _type,       // Gem type (e.g., 0 for red, 1 for blue, etc.)
        powerup: _powerup, // Power-up type (e.g., 0 for bomb, 1 for rainbow, etc.)
        locked: false,     // Whether the gem is locked
        offset_x: 0,       // Horizontal offset for animations
        offset_y: 0,       // Vertical offset for animations
        fall_target: -1,   // Target row for falling animations
		falling: false,
		shake_timer: 0,  // New property for shaking effect
		color: _color
    };
}

