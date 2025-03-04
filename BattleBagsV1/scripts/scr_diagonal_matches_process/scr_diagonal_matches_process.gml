	 function diagonal_match_process(_self, enabled = false)
	 {
	    if (enabled) {
	         //**↘ Diagonal Matches (Top-Left to Bottom-Right)**
	        for (var j = 0; j < _self.height - 2; j++) {
	            for (var i = 0; i < _self.width - 1; i++) {
	                var match_count = 1;
	                var _x = i, _y = j;
	                while (_x + 1 < _self.width && _y + 1 < _self.height && can_match(_self.grid[_x, _y], _self.grid[_x + 1, _y + 1])) {
	                    match_count++;
	                    _x++; _y++;
	                }
	                if (match_count >= 3) mark_diagonal_match(_self.marked_for_removal, i, j, match_count, "↘");
	            }
	        }
		
	        //**↙ Diagonal Matches (Top-Right to Bottom-Left)**
	        for (var j = 0; j < _self.height - 2; j++) {
	            for (var i = _self.width - 1; i >= 2; i--) {
	                var match_count = 1;
	                var _x = i, _y = j;

	                while (_x - 1 >= 0 && _y + 1 < _self.height && can_match(_self.grid[_x, _y], _self.grid[_x - 1, _y + 1])) {
	                    match_count++;
	                    _x--; _y++;
	                }

	                if (match_count >= 3) mark_diagonal_match(_self.marked_for_removal, i, j, match_count, "↙");
	            }
	        }
	    }
	 }