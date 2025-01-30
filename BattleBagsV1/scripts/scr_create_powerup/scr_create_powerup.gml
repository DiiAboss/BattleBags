enum POWERUP 
{
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
	FEATHER  = 11
	
}

function create_powerup(_powerup = -1, _chance = 0) {
	
	var _sprite = spr_powerup_1;
	var _dir = choose(0, 90, 180, 270);
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
		
		default:
		   _sprite = spr_none;
		break;
		
	}
    return {
        powerup: _powerup, // Power-up type (e.g., 0 for bomb, 1 for rainbow, etc.)
		sprite: _sprite,
		chance: _chance,
		dir: _dir,
		size: 1
    };
}
