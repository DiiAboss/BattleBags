function create_pop_info(_self, gem, _x, _y, _startx, _starty, blocks_destroyed, points_awarded)
		{
			return {
			x: _x,
            y: _y,
            gem_type: gem.type,
            timer: 0,
            start_delay: max(abs(_x - _startx), abs(_y - _starty)) * 5, // Wave effect
            scale: 1.0,
            popping: true,
            powerup: gem.powerup,
            offset_x: gem.offset_x,
            offset_y: gem.offset_y,
            color: gem.color,
            y_offset_global: _self.global_y_offset,
            match_size: blocks_destroyed,
            match_points: points_awarded,
			bomb_tracker: false,
			bomb_level: 1,
			dir: gem.dir,
			img_number: gem.img_number,
                is_big: false,	
			}
		}