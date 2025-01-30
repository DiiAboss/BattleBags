function freeze_block(_self, _x, _y)
{
	var freeze_x = _x;
    var freeze_y = _y;

    var gem = _self.grid[freeze_x, freeze_y];

    if (gem.type != -1) { // Ensure it's a valid block
        gem.frozen = true;
        gem.freeze_timer = room_speed * 5; // 5 seconds
    }
}