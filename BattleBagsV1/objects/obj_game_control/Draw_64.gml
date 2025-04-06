/// @description

if !global.paused
{
    for (var _b = 0; _b < array_length(big_block_types_on_grid) - 1; _b ++)
    {
        draw_text(128, 256 + (32 * _b), string(big_block_types_on_grid[_b]));
    } 
}

draw_text_heading_font(browser_width * 0.66, 128, "Energy Points: " + string(energy_points), 0.5, c_green, c_red, c_blue, c_yellow, 1);

var d_time = draw_next_event_timer(self, next_event_timer);
var d_time_max = draw_next_event_timer(self, next_event_timer_max);

draw_text_heading_font(browser_width * 0.33, 64, "NEXT EVENT: " + string(d_time) + " /// " + string(d_time_max), 0.33);

var draw_y_start = 600;
draw_ui_elements(self, draw_y_start);


var con_len = array_length(consumable_array);
var upg_array = array_length(upgrade_array);

draw_text(10, window_get_height() * 0.8, "CONSUMABLES: ")
draw_text(window_get_width() * 0.40, 50, "UPGRADES: ")
if (con_len > 0)
{
    for (var c = 0; c < con_len; c++)
    {
        draw_sprite(consumable_array[c].sprite, 0, 256 + (32 * c), window_get_height() * 0.8);
    }    
}

if (upg_array > 0)
{
    for (var c = 0; c < upg_array; c++)
    {
        draw_sprite(upgrade_array[c].sprite, 0, window_get_width() * 0.5 + (32 * c), 50);
    }    
}

//draw_spawn_rates(self);