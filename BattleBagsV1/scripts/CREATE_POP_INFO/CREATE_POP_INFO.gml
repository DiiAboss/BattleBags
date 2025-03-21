function create_pop_info(_self, gem, _x, _y)
		{
    
        var global_y_offset = _self.global_y_offset;
     
          // ✅ Send the block to pop_list (Now applies to normal and transformed blocks)
          var pop_info = {
              x: _x,
              y: _y,
              gem_type: gem.type,
              timer: 0,
              start_delay: 0,
              scale: 1.0,
              popping: true,
              powerup: gem.powerup,
              dir: gem.dir,
              offset_x: gem.offset_x,
              offset_y: gem.offset_y,
              color: gem.color,
              y_offset_global: global_y_offset,
              match_size: 0,
              match_points: 0,
              bomb_tracker: false, // Flag to mark this pop as bomb‐generated
              bomb_level: 0,
              img_number: gem.img_number,
              is_big: false,  // if this is set to true, the big blocks level behind remnants, could be used for upgrades.
          };
    
			return pop_info;
		}