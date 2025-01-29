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
