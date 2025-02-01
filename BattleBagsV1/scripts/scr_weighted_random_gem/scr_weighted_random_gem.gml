// ------------------------------------------------------
// Color Spawn Weight System
// ------------------------------------------------------

function create_gem_spawn_rates(spawn_rate = 4)
{
	global.color_spawn_weight = array_create(numberOfGemTypes, spawn_rate);
}

function weighted_random_gem(_self) {
    var total_weight = 0;

    // ✅ Calculate total weight
    for (var i = 0; i < _self.numberOfGemTypes; i++) {
        total_weight += global.color_spawn_weight[i];
    }

    // ✅ Select a random number within total weight
    var rand = irandom(total_weight - 1);
    var cumulative_weight = 0;

    for (var i = 0; i < _self.numberOfGemTypes; i++) {
        cumulative_weight += global.color_spawn_weight[i];

        if (rand < cumulative_weight) {
            return i; // ✅ Return selected color type
        }
    }
    
    return 0; // Default to first color (should never happen)
}