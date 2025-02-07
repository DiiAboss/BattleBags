function spawn_2x2_block(_self, _x, _y, _type) {
    if (_x < 0 || _x >= _self.width - 1 || _y < 0 || _y >= _self.height) return;

    // ✅ Generate unique, non-zero group_id
    var group_id;
    group_id = irandom_range(1, 999999); // ✅ No -1 or 0


    var big_gem = create_gem(_type);
    big_gem.is_big     = true;
    big_gem.group_id   = group_id;
    big_gem.big_parent = [_x, _y];

    _self.grid[_x, _y] = big_gem;

    var child_gem        = create_gem(_type);
    child_gem.is_big     = true;
    child_gem.group_id   = group_id;
    child_gem.big_parent = [_x, _y];

    _self.grid[_x + 1, _y] = child_gem;
    _self.grid[_x, _y + 1] = child_gem;
    _self.grid[_x + 1, _y + 1] = child_gem;
    
}