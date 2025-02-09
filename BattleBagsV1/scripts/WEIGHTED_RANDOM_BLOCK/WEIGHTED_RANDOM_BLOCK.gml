// ------------------------------------------------------
// Color Spawn Weight System
// ------------------------------------------------------

function create_block_spawn_rates(game_control_object, spawn_rate = 12)
{
	global.color_spawn_weight = array_create(game_control_object.numberOfGemTypes, spawn_rate);
}

function weighted_random_block(game_control_object) {
    var total_weight = 0;

    // ✅ Calculate total weight
    for (var i = 0; i < game_control_object.numberOfGemTypes; i++) {
        total_weight += global.color_spawn_weight[i];
    }

    // ✅ Select a random number within total weight
    var rand = irandom(total_weight - 1);
    var cumulative_weight = 0;

    for (var i = 0; i < game_control_object.numberOfGemTypes; i++) {
        cumulative_weight += global.color_spawn_weight[i];

        if (rand < cumulative_weight) {
            return i; // ✅ Return selected color type
        }
    }
    
    return BLOCK.NONE; // Default to first color (should never happen)
}