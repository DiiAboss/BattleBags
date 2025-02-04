function process_powerup(_self, _x, _y, gem, total_multiplier) {
    if (gem.powerup == -1) return; // No power-up, do nothing
	
    // 🔥 Convert multiplier to level (max level 5)
    var level = clamp(ln(total_multiplier) / ln(2), 1, 5); // Maps 2→1, 4→2, 8→3, 16→4, 32+→5

    switch (gem.powerup.powerup) {
        case POWERUP.SWORD:
            // 💥 **Destroy the entire row & column**
            for (var offset = 0; offset < level; offset++) {
                destroy_blocks_in_direction_from_point(_self, _x + offset, _y, 1, 0);
                destroy_blocks_in_direction_from_point(_self, _x - offset, _y, -1, 0);
                destroy_blocks_in_direction_from_point(_self, _x, _y + offset, 0, 1);
                destroy_blocks_in_direction_from_point(_self, _x, _y - offset, 0, -1);
            }
            break;

        case POWERUP.BOW:
            // 💥 **Destroy same direction row below it for each level**
            for (var offset = 0; offset < level; offset++) {
                switch (gem.powerup.dir) {
                    case 0:   destroy_blocks_in_direction_from_point(_self, _x + offset, _y, 1, 0); break; // Right
                    case 90:  destroy_blocks_in_direction_from_point(_self, _x, _y - offset, 0, -1); break; // Up
                    case 180: destroy_blocks_in_direction_from_point(_self, _x - offset, _y, -1, 0); break; // Left
                    case 270: destroy_blocks_in_direction_from_point(_self, _x, _y + offset, 0, 1); break; // Down
                }
            }
            break;

        case POWERUP.BOMB:
            // 💣 **Explode in larger areas based on level**
            activate_bomb_gem(_self, _x, _y, level);
            break;

        case POWERUP.EXP:
            // ⭐ **Grant extra experience (scales infinitely)**
            var _experience_points = ((_self.max_experience_points * 0.05) * total_multiplier);
			    var px = (_x * _self.gem_size) + _self.board_x_offset;
                var py = (_y * _self.gem_size) + _self.global_y_offset;
			var _point_obj = instance_create_depth(px, py, depth-99, obj_experience_point);
			_point_obj.value = _experience_points;
            break;

        case POWERUP.HEART:
            // **Heal infinitely without cap**
			if (_self.player_health < _self.max_player_health)
			{
				_self.player_health += total_multiplier;
			}
			else
			{
				_self.player_health = _self.max_player_health;
			}
            break;

        case POWERUP.MONEY:
            // 💰 **Grant points infinitely**
            _self.total_points += 50 * total_multiplier;
            break;

        case POWERUP.POISON:
            // ☠️ **Reduce health scaled by level (not infinite)**
            _self.player_health -= level;
            break;

        case POWERUP.FIRE:
            // 🔥 **Ignite area based on level (max 5)**
            for (var dx = -level; dx <= level; dx++) {
                for (var dy = -level; dy <= level; dy++) {
                    if (dx == 0 && dy == 0) continue;
                    var nx = _x + dx;
                    var ny = _y + dy;
                    if (nx >= 0 && nx < _self.width && ny >= 0 && ny < _self.height) {
                        _self.grid[nx, ny].popping = true;
                    }
                }
            }
            break;

        case POWERUP.ICE:
            // ❄️ **Freeze surrounding blocks (max level 5)**
            freeze_block(_self, _x, _y, level);
            break;

        case POWERUP.TIMER:
            // ⏳ **Slow down the game (max level 5)**
				_self.timer_block_slow_down += 30 * level;
            break;

        case POWERUP.FEATHER:
            // **Remove gravity effect for short time**
            for (var j = 0; j < _self.height; j++) {
                for (var i = 0; i < _self.width; i++) {
                    _self.grid[i, j].falling = false;
                }
            }
            break;

        case POWERUP.WILD_POTION:
            // 🌀 **Spawn wild blocks infinitely (no level cap)**
            spawn_wild_block(_self, total_multiplier);
            break;
    }
}