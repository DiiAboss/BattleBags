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