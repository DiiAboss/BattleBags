// ------------------------------------------------------
// Color Spawn Weight System
// ------------------------------------------------------



    //GAME_OVER   = -404,
    //RANDOM      = -99,
    //MEGA        = -3,
    //NONE        = -1,
    //RED         = 0,
    //YELLOW      = 1,
    //GREEN       = 2,
    //PINK        = 3,
    //PURPLE      = 4,
    //LIGHTBLUE   = 5,
    //ORANGE      = 6,
    //BLUE        = 7,
    //GREY        = 8,
    //WHITE       = 9,
    //BLACK       = 10,
    //WILD        = 11,
    //PUZZLE_1    = 12,
    //CURSE       = 13,
    //COLOR_BOMB  = 14,
    //bUG         = 15


function block_spawn_weight_manager() constructor 
{
    start_weight = 12.5;
    
    total_blocks = 16;
    block_weight_array   = array_create(total_blocks, 0);
    default_weight_array = array_create(total_blocks, 0);
    mod_weight_array     = array_create(total_blocks, 0);
    block_range_array    = array_create(total_blocks, 0);
    
    block_weight_array[BLOCK.RED]       = start_weight;
    block_weight_array[BLOCK.YELLOW]    = start_weight;
    block_weight_array[BLOCK.GREEN]     = start_weight;
    block_weight_array[BLOCK.PINK]      = start_weight;
    block_weight_array[BLOCK.PURPLE]    = start_weight;
    block_weight_array[BLOCK.LIGHTBLUE] = start_weight;
    block_weight_array[BLOCK.ORANGE]    = start_weight;
    block_weight_array[BLOCK.BLUE]      = start_weight;
    block_weight_array[BLOCK.BUG]       = 2;
    
    var _total = 0;
    for (var i = 0; i < total_blocks; i++)
    {
        
        mod_weight_array[i] = 1;
        default_weight_array[i] = block_weight_array[i];
        
        block_range_array[i] = _total + block_weight_array[i];
        
        _total += block_weight_array[i];
    } 
    
    total = _total;
    
    
    get_block_spawn_rate = function(_type)
    {
        return default_weight_array[_type] * mod_weight_array[_type];
    }
    
    get_block_spawn_percent = function(_type)
    {
        
    }
    
    update_block_weights = function()
    {
        var _total = 0;
        for (var i = 0; i < total_blocks; i++)
        {
            block_weight_array[i] = _total + (default_weight_array[i] * mod_weight_array[i]);
            _total += block_weight_array[i];
        }
    }
    
    get_random_block = function()
    {
        var rand_num = irandom(total);
        for (var i = 1; i < total_blocks; i++)
        {
            if (rand_num < block_range_array[i] && rand_num > block_range_array[i-1]) return i;
        }
        // If we get to none of the blocks above, goto block_range_array[0]
        return BLOCK.RED;
    }
    
    set_block_spawn_weight = function(_type, value)
    {

    }
}

function weighted_random_block(player) 
{
    return player.block_spawn_rates.get_random_block();
}






// LEGACY for multi
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
        array_push(global.color_spawn_weight, 5);
        array_push(global.color_spawn_weight, 5);
    }
    else {
        number_of_block_types = game_control_object.number_of_block_types;
        global.color_spawn_weight = array_create(number_of_block_types, spawn_rate);
    }
    
}
