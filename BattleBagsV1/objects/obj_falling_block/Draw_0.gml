/// @description
// Draw Event:
// Get the correct sprite based on block type
var sprite;
switch(block_type) {
    case 0: sprite = spr_red_clay_block; break;
    case 1: sprite = spr_yellow_clay_block; break;
    case 2: sprite = spr_green_clay_block; break;
    case 3: sprite = spr_pink_moon_block; break;
    case 4: sprite = spr_purple_clay_block; break;
    case 5: sprite = spr_lightblue_clay_block; break;
    case 6: sprite = spr_orange_clay_block; break;
    case 7: sprite = spr_blue_clay_block; break;
    default: sprite = spr_red_clay_block; break;
}

// Draw the sprite with current alpha
draw_sprite_ext(sprite, 0, x, y, image_xscale, image_yscale, image_angle, c_white, alpha);