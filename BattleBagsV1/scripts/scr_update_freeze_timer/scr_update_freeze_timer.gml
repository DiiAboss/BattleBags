function update_freeze_timer(_self) {
    var gem_size = _self.gem_size;
    var height   = _self.height;
    var width    = _self.width;
    
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            var gem = _self.grid[i, j];

            var _x = (i * gem_size) + _self.board_x_offset + _self.offset;
            var _y = (j * gem_size) + _self.offset + _self.global_y_offset + _self.gem_y_offsets[i, j];

            if (gem.frozen) {
                // ⏳ Reduce Freeze Timer
                gem.freeze_timer--;

                // 💬 Display Time Left in Seconds
                var time_left = ceil(gem.freeze_timer / room_speed);
                draw_text(_x + 8, _y - 16, string(time_left));

                // ❄️ If timer hits zero, thaw the block
                if (gem.freeze_timer <= 0) {
                    gem.frozen = false;
                    effect_create_depth(depth - 1, ef_spark, _x, _y, 1, c_blue);
                    effect_create_depth(depth - 1, ef_firework, _x, _y, 0.5, c_white);
                }
            }
        }
    }
}
