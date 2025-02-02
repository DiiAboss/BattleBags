/// @description Create Upgrade Menu
array_size = 3;
upgrade = array_create(array_size);


global.upgrade_positions = array_create(array_size); // Store button positions

var x_start = (room_width / 2) - (384 * 1);
var y_start = 300;

// ✅ Select 3 random upgrades from the global list
for (var i = 0; i < array_size; i++) {
    var index = irandom(ds_list_size(global.upgrades) - 1);
    upgrade[i] = global.upgrades[| index];

    // ✅ Store button positions for clicking
    global.upgrade_positions[i] = {
        x: x_start + (i * 384),  // Spaced horizontally
        y: y_start,
        width: 256,
        height: 256
    };
}


depth = -99;