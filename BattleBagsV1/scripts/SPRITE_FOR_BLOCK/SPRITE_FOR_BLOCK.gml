// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function sprite_for_block(gem_type) {
    switch (gem_type) {
		case BLOCK.WILD:		return spr_Oshki;
        case BLOCK.RED:			return spr_red_gem;    // Red gem
        case BLOCK.YELLOW:		return spr_yellow_gem;   // Blue gem
        case BLOCK.GREEN:		return spr_green_gem;  // Green gem
        case BLOCK.PINK:		return spr_pink_gem; // Yellow gem
        case BLOCK.PURPLE:		return spr_purple_gem; // Purple gem
		case BLOCK.LIGHTBLUE:	return spr_lightblue_gem; // Purple gem
		case BLOCK.ORANGE:		return spr_orange_gem; // Purple gem
		case BLOCK.BLUE:		return spr_blue_gem; // Purple gem
		case BLOCK.BLACK:		return spr_black_gem; // Purple gem
		case BLOCK.MEGA:		return spr_black_gem_mega_1; // Purple gem
		case BLOCK.PUZZLE_1:    return spr_rune_gem_circle;
        default:
            return spr_enemy_gem_overlay;    // Default gem (in case of an invalid value)
    }
}