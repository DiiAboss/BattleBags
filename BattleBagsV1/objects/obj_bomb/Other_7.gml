// Instead of multiple similar effect calls
var effect_colors = [c_white, c_yellow, c_red];
var effect_types = [ef_firework, ef_explosion, ef_spark];

for (var i = 0; i < array_length(effect_types); i++) {
    for (var j = 0; j < array_length(effect_colors); j++) {
        var size = (j == 0) ? 3 : ((j == 1) ? 9 : 8);
        effect_create_depth(depth - 99, effect_types[i], x, y, size, effect_colors[j]);
    }
}

instance_destroy();