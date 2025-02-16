// ------------------------------------------------------
// Color Spawn Weight System
// ------------------------------------------------------

function create_block_spawn_rates(game_control_object, spawn_rate = 12)
{
    var number_of_block_types = 8;
    var single_player = instance_exists(obj_game_control);
    
    if (single_player)
    {
        number_of_block_types = game_control_object.numberOfGemTypes;
        global.color_spawn_weight = array_create(number_of_block_types, spawn_rate);
    }
	
}

function weighted_random_block(game_control_object) 
{
    var total_weight = 0;
    var number_of_block_types = 8;
    
    var single_player = instance_exists(obj_game_control);
    var spawn_rates = 12.5;
    
    if (single_player)
    {
        number_of_block_types = game_control_object.numberOfGemTypes;
        
        // ✅ Calculate total weight
        for (var i = 0; i < number_of_block_types; i++) {
            total_weight += global.color_spawn_weight[i];
        }
    
        // ✅ Select a random number within total weight
        var rand = irandom(total_weight - 1);
        var cumulative_weight = 0;
    
        for (var i = 0; i < number_of_block_types; i++) {
            cumulative_weight += global.color_spawn_weight[i];
    
            if (rand < cumulative_weight) {
                return i; // ✅ Return selected color type
            }
        }
    }
    
    else 
    {
        total_weight = number_of_block_types * spawn_rates;
        
        // ✅ Select a random number within total weight
        var rand = irandom(total_weight - 1);
        var cumulative_weight = 0;
        
    
        for (var i = 0; i < number_of_block_types; i++) {
            cumulative_weight += spawn_rates;
    
            if (rand < cumulative_weight) {
                return i; // ✅ Return selected color type
            }
       }
    }
    
    return BLOCK.NONE; // Default to first color (should never happen)
}