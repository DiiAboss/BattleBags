// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function sprite_for_block(gem_type) {
    switch (gem_type) {
		case BLOCK.WILD:		return spr_Oshki;
        case BLOCK.RED:			return spr_red_clay_block;    // Red gem
        case BLOCK.YELLOW:		return spr_yellow_clay_block;   // Blue gem
        case BLOCK.GREEN:		return spr_green_clay_block;  // Green gem
        case BLOCK.PINK:		return spr_pink_moon_block; // Yellow gem
        case BLOCK.PURPLE:		return spr_purple_clay_block; // Purple gem
		case BLOCK.LIGHTBLUE:	return spr_lightblue_clay_block; // Purple gem
		case BLOCK.ORANGE:		return spr_orange_clay_block; // Purple gem
		case BLOCK.BLUE:		return spr_blue_clay_block; // Purple gem
		case BLOCK.BLACK:		return spr_gameOver; // Purple gem
		case BLOCK.MEGA:		return spr_black_gem_mega_1; // Purple gem
		case BLOCK.PUZZLE_1:    return spr_rune_gem_circle;
            
        case BLOCK.BUG:         return spr_enemy_fly;
            
        case BLOCK.COIN:        return spr_gold_coin;
        case BLOCK.COLOR_BOMB:  return spr_wild_gem;
        default:
            return spr_enemy_gem_overlay;    // Default gem (in case of an invalid value)
    }
}