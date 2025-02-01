

function create_gem(_type = -99, _powerup = weighted_random_powerup()) {
	
	if (_type == -99) { // If generating a new random gem
		_type = weighted_random_gem(self);
    }
	
if (irandom(100) > ds_map_find_value(global.powerup_weights, _powerup)) {
    _powerup = create_powerup(POWERUP.NONE, 0);
}
	
	var _dir = choose(0, 90, 180, 270);
	var _bomb_level = 1;
	var _bomb_tracker = false;
	
	if (_powerup != -1) {
		_dir = _powerup.dir;
		_bomb_level = _powerup.bomb_level;
		_bomb_tracker = _powerup.bomb_tracker;
	}
	else
	{
		_powerup = create_powerup(POWERUP.NONE, 0);
	}
	
	var _color = c_white;
	
	switch(_type) {
		case BLOCK.RED: _color = c_red; break;
		case BLOCK.YELLOW: _color = c_yellow; break;
		case BLOCK.GREEN: _color = c_lime; break;
		case BLOCK.PINK: _color = c_fuchsia; break;
		case BLOCK.PURPLE: _color = c_purple; break;
		case BLOCK.LIGHTBLUE: _color = c_silver; break;
		case BLOCK.ORANGE: _color = c_orange; break;
		case BLOCK.BLACK: _color = c_black; break;
		case BLOCK.MEGA: _color = c_white; break;
	}
	
    return {
        type: _type,       
        powerup: _powerup, 
        locked: false,     
        offset_x: 0,       
        offset_y: 0,       
        fall_target: -1,   
		falling: false,
		shake_timer: 0,    
		color: _color,
		fall_delay: 0,
		max_fall_delay: 10, 
		freeze_timer: 0,   
        frozen: false,      
		damage: 1,
		combo_multiplier: 1,
		pop_speed: 1,
		explode_on_four: false,
		explode_on_five: false,
		explode_on_six: false,
		popping: false,
		pop_timer: 0,
		group_id: -1,
		dir: _dir,
		is_enemy_block: false,
		bomb_tracker: _bomb_tracker,
		bomb_level: _bomb_level
    };
}


