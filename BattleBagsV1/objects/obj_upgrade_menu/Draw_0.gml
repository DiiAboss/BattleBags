/// @description Insert description here
// You can write your code in this editor
draw_set_color(c_black);
draw_rectangle(100, 100, room_width - 100, room_height - 100, false);
draw_set_color(c_white);
draw_text(room_width / 2, 120, "Choose an Upgrade");

var y_offset = 160;

// ✅ Display 3 Random Upgrades

for (var i = 0; i < array_size; i++) {
    draw_text(room_width / 2, y_offset, string(i+1) + ". " + upgrade[i].name + " - " + upgrade[i].desc);
    y_offset += 40;

    
}

