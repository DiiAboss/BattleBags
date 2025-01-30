function create_gem(_type = -99, _powerup = create_powerup(irandom(3))) {
	
	if (_type == -99) { // If generating a new random gem
		_type = weighted_random_gem(self);
    }
	
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
		shake_timer: 0,    // New property for shaking effect
		color: _color,
		fall_delay: 0,
		max_fall_delay: 10, 
		freeze_timer: 0,   // 🔥 New: Countdown to thaw
        frozen: false,      // 🔥 New: Flag for frozen state
		damage: 1,
		combo_multiplier: 1,
		pop_speed: 1,
		explode_on_four: false,
		explode_on_five: false,
		explode_on_six: false
    };
}

