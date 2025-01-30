function destroy_block(_self, _x, _y) {
    _self.grid[_x, _y] = create_gem(-1); // Replace with an empty gem
    _self.gem_y_offsets[_x, _y] = 0;
    //update_topmost_row();
}