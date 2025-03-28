function create_pop_info(player, block, _x, _y)
		{
    
        var global_y_offset = player.global_y_offset;
     
          // ✅ Send the block to pop_list (Now applies to normal and transformed blocks)
          var pop_info = {
              x: _x,
              y: _y,
              gem_type: block.type,
              timer: 0,
              start_delay: 0,
              scale: 1.0,
              popping: true,
              powerup: block.powerup,
              dir: block.dir,
              offset_x: block.offset_x,
              offset_y: block.offset_y,
              color: block.color,
              y_offset_global: global_y_offset,
              match_size: 0,
              match_points: 0,
              bomb_tracker: false, // Flag to mark this pop as bomb‐generated
              bomb_level: 0,
              img_number: block.img_number,
              is_big: false,  // if this is set to true, the big blocks level behind remnants, could be used for upgrades.
          };
    
			return pop_info;
		}