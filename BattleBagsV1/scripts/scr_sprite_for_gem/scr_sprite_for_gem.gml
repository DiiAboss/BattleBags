// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function sprite_for_gem(gem_type) {
    switch (gem_type) {
		case -2:
			return spr_wild_gem;
        case 0:
            return spr_red_gem;    // Red gem
        case 1:
            return spr_yellow_gem;   // Blue gem
        case 2:
            return spr_green_gem;  // Green gem
        case 3:
            return spr_pink_gem; // Yellow gem
        case 4:
            return spr_purple_gem; // Purple gem
		case 5:
            return spr_lightblue_gem; // Purple gem
		case 6:
            return spr_orange_gem; // Purple gem
        default:
            return spr_red_gem;    // Default gem (in case of an invalid value)
    }
}