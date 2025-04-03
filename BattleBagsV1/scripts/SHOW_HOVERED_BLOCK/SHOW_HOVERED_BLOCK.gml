function show_hovered_block_data(enabled, block, _x, _y, draw_x = 10, draw_y = room_height - 64)
{
    if !(enabled) return;
    draw_text(draw_x, draw_y,
        "Hovering: (" + string(_x) + ", " + string(_y) +
        ") | Type: " + string(block.type) + 
        " | Powerup: " + string(block.powerup)
    );        
}
