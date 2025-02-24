// Script Created By DiiAboss AKA Dillon Abotossaway
///@function   
///
///@description
///
///@return
/// Function: Draw the grid
function draw_grid(_self) {
	
	var width = _self.width;
	var top_row = _self.top_playable_row;
	var bottom_row = _self.bottom_playable_row;
	var gem_size = _self.gem_size;
	
    for (var i = 0; i < width; i++) {
        var shake_intensity = calculate_shake(_self, i);

        for (var j = top_row; j <= bottom_row; j++) {
            var gem = _self.grid[i, j];

            if (gem.type == BLOCK.NONE) continue; // Skip empty slots

            var draw_x = _self.board_x_offset + (i * gem_size) + _self.offset + gem.offset_x;
            var draw_y = (j * gem_size) + _self.global_y_offset + gem.offset_y + _self.offset;

            // Apply shake and store the new values
            var new_pos = apply_shake_effect(self, draw_x, draw_y, shake_intensity, i);
            draw_x = new_pos[0];
            draw_y = new_pos[1];

            draw_gem(gem, draw_x, draw_y);
        }
    }
}
/// Function: Calculate shake intensity for a column
function calculate_shake(_self, i) {
    var max_shake = 2;
    var shake_intensity = 0;
	var top_row = _self.top_playable_row;
	
    if (global.topmost_row <= top_row) {
        for (var ii = 0; ii <= top_row; ii++) {
            if (_self.grid[i, ii].type != BLOCK.NONE) {
                return max_shake; // Apply full shake if danger row detected
            }
        }
    }
    return shake_intensity;
}

/// Function: Apply shake effect to gem positions
function apply_shake_effect(_self, _x, _y, shake_intensity, i) {
	
	var top_row = _self.top_playable_row;
	var xx = _x;
	var yy = _y;
	
    if (shake_intensity > 0 && i <= top_row) {
        xx += irandom_range(-shake_intensity, shake_intensity);
        yy += irandom_range(-shake_intensity, shake_intensity);
    }
    xx += _self.shake_x;
    yy += _self.shake_y;
	
	return[xx, yy];
	
}

/// Function: Draw a single gem
function draw_gem(gem, draw_x, draw_y) {
    var scale_x = gem.falling ? 0.95 : 1;
    var scale_y = gem.falling ? 1.05 : 1;

    if (gem.is_big) {
        if (gem.big_parent[0] == i && gem.big_parent[1] == j) {
            draw_sprite_ext(sprite_for_block(gem.type), 0, draw_x + 32, draw_y + 32, 2, 2, 0, c_white, 1);
        }
    } else {
        draw_sprite_ext(sprite_for_block(gem.type), gem.img_number, draw_x, draw_y, scale_x, scale_y, 0, c_white, 1);
    }

    // Special effects
    if (gem.powerup != -1) draw_sprite(gem.powerup.sprite, 0, draw_x, draw_y);
    if (gem.frozen) draw_sprite(spr_ice_cover, 0, draw_x, draw_y);
    if (gem.is_enemy_block) draw_sprite(spr_enemy_gem_overlay, 0, draw_x, draw_y);
}

/// Function: Draw hover effect on the selected block
function draw_hover_effect(_self) {
    if (_self.hovered_block[0] < 0 || _self.hovered_block[1] < 0) return;

    var hover_i = hovered_block[0];
    var hover_j = hovered_block[1];
	var width = _self.width;
	var height = _self.height;
	var gem_size = _self.gem_size;

    if (hover_i >= width || hover_j >= height) return;

    var hover_gem = _self.grid[hover_i, hover_j];
    if (hover_gem.type == BLOCK.NONE) return;

    var rect_x1 = _self.board_x_offset + (hover_i * gem_size);
    var rect_y1 = (hover_j * gem_size) + _self.global_y_offset;
    var rect_x2 = rect_x1 + gem_size;
    var rect_y2 = rect_y1 + gem_size;

    draw_set_alpha(0.3);
    draw_set_color(c_yellow);
    draw_rectangle(rect_x1, rect_y1, rect_x2, rect_y2, false);
    draw_set_color(c_white);
    draw_set_alpha(1.0);
}

/// Function: Draw UI elements
function draw_ui_elements() {
    draw_text(10, draw_y_start + 40, "TIME: " + string(draw_time));
    draw_text(10, draw_y_start + 60, "SPEED: " + string(game_speed_default));
    draw_text(10, draw_y_start + 100, "LEVEL: " + string(level));
    draw_text(10, draw_y_start + 120, "Combo: " + string(combo));
    draw_text(10, draw_y_start + 140, "cTimer: " + string(combo_timer));
}

/// Function: Draw the combo count
function draw_combo_count() {
    if (combo <= 1) return; // Only show if at least 2 matches happened

    draw_set_font(fnt_heading1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    var px = (combo_x * gem_size) + board_x_offset + (gem_size / 2);
    var py = (combo_y * gem_size) + global_y_offset + (gem_size / 2);

    draw_text_color(px, py, string(combo) + "x!", c_yellow, c_white, c_white, c_white, 1);

    draw_set_font(fnt_basic);
    draw_set_halign(fa_left);
}

/// Function: Draw attack preview box
function draw_preview_box() {
    var preview_x = board_x_offset + (width * gem_size) + 16;
    var preview_y = draw_y_start + 64;
    var preview_size = 256;
    var max_attacks_shown = 5;

    for (var i = 0; i < min(ds_list_size(global.enemy_attack_queue), max_attacks_shown); i++) {
        var attack_offset_y = preview_y + (i * (preview_size + 8));
        draw_rectangle(preview_x, attack_offset_y, preview_x + preview_size, attack_offset_y + preview_size, true);
    }
}
