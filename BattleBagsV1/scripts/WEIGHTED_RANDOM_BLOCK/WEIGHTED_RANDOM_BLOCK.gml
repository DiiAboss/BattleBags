// ------------------------------------------------------
// Color Spawn Weight System
// ------------------------------------------------------
function block_spawn_weight_manager() constructor 
{
    total = 0;
    
    red         = 0;
    yellow      = 0;
    green       = 0;
    pink        = 0;
    purple      = 0;
    lightblue   = 0;
    orange      = 0;
    blue        = 0;
    
    grey        = 0;
    white       = 0;
    black       = 0;
    wild        = 0;
    puzzle_1    = 0;
    
    curse       = 0;
    
    color_bomb  = 0;
    bug         = 0;
    
    total = red+yellow+green+pink+purple+lightblue+orange+blue+grey+white+black+wild+puzzle_1+curse+color_bomb+bug;
    
    
    get_block_spawn_percent = function(_type)
    {
        switch (_type)
        {
            case BLOCK.RED: return (red / total) * 100;
            case BLOCK.YELLOW: return (yellow / total) * 100;
            case BLOCK.GREEN: return (green / total) * 100;
            case BLOCK.PINK: return (pink / total) * 100;
            case BLOCK.PURPLE: return (purple / total) * 100;
            case BLOCK.LIGHTBLUE: return (lightblue / total) * 100;
            case BLOCK.ORANGE: return (orange / total) * 100;
            case BLOCK.BLUE: return (blue / total) * 100;
            case BLOCK.CURSE: return (curse / total) * 100;
            case BLOCK.BUG: return (bug / total) * 100;
            case BLOCK.PUZZLE_1: return (puzzle_1 / total) * 100;
            default: 
                show_debug_message("get_block_spawn_percent() -> BLOCK NOT FOUND!... ARE YOU USING BLOCK.<TYPE> to access? e.g. BLOCK.RED, BLOCK.CURSE, etc.");
                return -404;
        }
    }
    
    
    
    set_block_spawn_weight = function(_type, value)
    {
        switch (_type)
        {
            case BLOCK.RED:
                total -= red;
                red = value;
                total += red;
            break;
            case BLOCK.YELLOW:
                total -= yellow;
                red = value;
                total += yellow;
            break;
            case BLOCK.GREEN:
                total -= green;
                red = value;
                total += green;
            break;
            case BLOCK.PINK:
                total -= pink;
                red = value;
                total += pink;
            break;
            case BLOCK.PURPLE:
                total -= purple;
                red = value;
                total += purple;
            break;
            case BLOCK.LIGHTBLUE:
                total -= lightblue;
                red = value;
                total += lightblue;
            break;
            case BLOCK.ORANGE:
                total -= orange;
                red = value;
                total += orange;
            break;
            case BLOCK.BLUE:
                total -= blue;
                red = value;
                total += blue;
            break;
            case BLOCK.CURSE:
                total -= curse;
                red = value;
                total += curse;
            break;
            case BLOCK.BUG:
                total -= bug;
                red = value;
                total += bug;
            break;
            case BLOCK.PUZZLE_1:
                total -= puzzle_1;
                red = value;
                total += puzzle_1;
            break;
            default: 
                show_debug_message("set_block_spawn_weight() -> BLOCK NOT FOUND!... ARE YOU USING BLOCK.<TYPE> to access? e.g. BLOCK.RED, BLOCK.CURSE, etc.")    
            break;
        }
    }
}

function create_spawn_rate(_type, _rate)
{
    return {
        type: _type,
        rate: _rate,
        level: 1,
    }
}


function create_block_spawn_rates(game_control_object, spawn_rate = 12)
{
    var number_of_block_types = 8;
    var single_player = instance_exists(obj_game_control);
    global.block_spawn_rates = array_create(0);
    array_push(global.block_spawn_rates, create_spawn_rate(BLOCK.RED, spawn_rate));
    if (single_player)
    {
        number_of_block_types = game_control_object.number_of_block_types;
        global.color_spawn_weight = array_create(number_of_block_types, spawn_rate);
        array_push(global.color_spawn_weight, 0);
        array_push(global.color_spawn_weight, 0);
        array_push(global.color_spawn_weight, 0);
        array_push(global.color_spawn_weight, 0);
        array_push(global.color_spawn_weight, 0);
        array_push(global.color_spawn_weight, 0);
        array_push(global.color_spawn_weight, 25);
        array_push(global.color_spawn_weight, 25);
    }
    else {
        number_of_block_types = game_control_object.number_of_block_types;
        global.color_spawn_weight = array_create(number_of_block_types, spawn_rate);
    }
	
}

function weighted_random_block(game_control_object) 
{
    game_control_object = obj_game_control;
    var total_weight = 0;
    var number_of_block_types = array_length(global.color_spawn_weight);
    
    var single_player = instance_exists(obj_game_control);
    var spawn_rates = 12.5;
    
    if (single_player)
    {
        number_of_block_types = game_control_object.number_of_block_types;
        
        var next_block = irandom(number_of_block_types + 4);
        
        if (next_block > number_of_block_types)
        {
            return BLOCK.BUG;
        }
        
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