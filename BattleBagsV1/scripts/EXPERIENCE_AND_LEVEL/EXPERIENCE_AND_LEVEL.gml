/// @function process_experience_points(_self, amount, increment_speed)
/// @description Gradually increases experience points toward a target value
/// and levels up when the experience bar is full.
/// - _self: The object (or global struct) whose experience is being updated.
/// - amount: The total XP to add.
/// - increment_speed: The speed factor (default = 0.01).
function process_experience_points(_self, amount, increment_speed = 2) 
{
	if (amount > 0)
	{
	    // Gradual XP increment
	    var diff = _self.experience_points + amount;

	    if (abs(diff) < 1) {
	        _self.experience_points = _self.target_experience_points;
	        _self.target_experience_points = 0;
	    } 
	    else 
		{
	        var delta = diff * increment_speed;

	        if (abs(delta) < 1) {
	            delta = sign(delta) * 1;
	        }
	        _self.experience_points += delta;
			_self.target_experience_points -= delta;
	    }

	    process_level_up(_self);
	}
}

/// @function process_level_up(_self)
/// @description Handles leveling up and queues up multiple upgrades if needed.
function process_level_up(_self)
{
    var levels_gained = 0;
	
    // **Check for multiple Level Ups**
    while (_self.experience_points >= _self.max_experience_points) {
        _self.experience_points -= _self.max_experience_points; // Carry over excess XP
        _self.level += 1;
        levels_gained += 1; //  Track levels gained
		//game_speed_default += 0.05;

        // **Recalculate max XP for the next level**
        _self.max_experience_points = _self.max_exp_mod + ((_self.max_exp_level_mod * _self.level) + (_self.level * _self.level)) - _self.level;
        
        // If the target XP was exceeded, keep processing until all XP is accounted for
        if (_self.target_experience_points <= _self.experience_points) {
            _self.target_experience_points = 0;
        }
    }

    // ✅ Store total levels gained but **don't trigger upgrade menu yet**
    _self.target_level += levels_gained;
}