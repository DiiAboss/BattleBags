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
    
    total_blocks = 17;
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
    block_weight_array[BLOCK.COIN]      = start_weight;
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
    
    
    draw_spawn_rates = function(_x = 20, _y = 20, _width = 300, _height = 20, _spacing = 25, _draw_text = true)
    {
        // Block names array for display labels
        var block_names = [
            "RED", "YELLOW", "GREEN", "PINK", "PURPLE", 
            "LIGHTBLUE", "ORANGE", "BLUE", "COIN", "BUG"
        ];
        
        // Block colors array for visual representation
        var block_colors = [
            c_red, c_yellow, c_lime, c_fuchsia, c_purple, 
            c_aqua, c_orange, c_blue, c_yellow, c_black
        ];
        
        // Calculate total weight for percentages
        var _total_weight = 0;
        for (var i = 0; i < total_blocks; i++) {
            _total_weight += default_weight_array[i] * mod_weight_array[i];
        }
        
        // Save current drawing settings
        var _orig_color = draw_get_color();
        var _orig_alpha = draw_get_alpha();
        var _orig_halign = draw_get_halign();
        var _orig_valign = draw_get_valign();
        
        // Set text alignment
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        
        // Draw title
        draw_set_color(c_white);
        draw_text(_x, _y - _spacing, "Block Spawn Rates:");
        
        // Draw each block's spawn rate
        for (var i = 0; i < total_blocks; i++) {
            if (default_weight_array[i] <= 0) continue; // Skip blocks with no weight
            
            var _current_y = _y + (i * _spacing);
            var _current_weight = default_weight_array[i] * mod_weight_array[i];
            var _percent = (_current_weight / _total_weight) * 100;
            
            // Draw block color indicator
            var _color = (i < array_length(block_colors)) ? block_colors[i] : c_gray;
            draw_set_color(_color);
            draw_rectangle(_x, _current_y - 8, _x + 16, _current_y + 8, false);
            draw_set_color(c_black);
            draw_rectangle(_x, _current_y - 8, _x + 16, _current_y + 8, true);
            
            // Draw block name
            draw_set_color(c_white);
            var _name = (i < array_length(block_names)) ? block_names[i] : "BLOCK " + string(i);
            draw_text(_x + 24, _current_y, _name);
            
            // Draw weight bar
            var _bar_width = (_current_weight / start_weight) * (_width * 0.5);
            draw_set_color(_color);
            draw_set_alpha(0.7);
            draw_rectangle(_x + 100, _current_y - 6, _x + 100 + _bar_width, _current_y + 6, false);
            draw_set_alpha(1.0);
            draw_set_color(c_white);
            draw_rectangle(_x + 100, _current_y - 6, _x + 100 + _width * 0.5, _current_y + 6, true);
            
            // Draw percentage and actual weight
            if (_draw_text) {
                draw_set_halign(fa_right);
                draw_text(_x + 100 + _width * 0.5 + 50, _current_y, string_format(_percent, 1, 1) + "%");
                draw_text(_x + 100 + _width * 0.5 + 120, _current_y, "(" + string(_current_weight) + ")");
                draw_set_halign(fa_left);
            }
        }
        
        // Draw modifier indicators for blocks with modifiers
        draw_set_color(c_yellow);
        for (var i = 0; i < total_blocks; i++) {
            if (mod_weight_array[i] != 1) {
                var _current_y = _y + (i * _spacing);
                var _mod_text = "x" + string(mod_weight_array[i]);
                draw_text(_x + 100 + _width * 0.5 + 150, _current_y, _mod_text);
            }
        }
        
        // Restore original drawing settings
        draw_set_color(_orig_color);
        draw_set_alpha(_orig_alpha);
        draw_set_halign(_orig_halign);
        draw_set_valign(_orig_valign);
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
