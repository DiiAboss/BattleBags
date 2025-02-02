function create_upgrade(_name, _desc, _effect, _level = -1) {
	
    var upgrade = {
        name: _name,
        desc: _desc,
        effect: _effect,
		level: get_upgrade_level()
    };
    return upgrade;
}


/// @function get_upgrade_sprite(effect)
/// @desc Returns the correct sprite for an upgrade, based on the block or powerup it affects.
function get_upgrade_sprite(effect) {
    switch (effect) {
        case "more_red": return sprite_for_gem(BLOCK.RED);
        case "more_yellow": return sprite_for_gem(BLOCK.YELLOW);
        case "more_green": return sprite_for_gem(BLOCK.GREEN);
        case "more_pink": return sprite_for_gem(BLOCK.PINK);
        case "more_light_blue": return sprite_for_gem(BLOCK.LIGHTBLUE);
        case "more_purple": return sprite_for_gem(BLOCK.PURPLE);
        case "more_orange": return sprite_for_gem(BLOCK.ORANGE);
		case "more_blue": return sprite_for_gem(BLOCK.BLUE);
        case "more_bombs": return spr_powerup_bomb;
        case "more_multi": return spr_powerup_2x_multi;
        case "more_bows": return spr_powerup_destroy_to_right;
        case "more_exp": return spr_powerup_exp;
        case "more_hearts": return spr_powerup_heart;
        case "more_money": return spr_powerup_money;
        case "more_timers": return spr_powerup_timer;
        case "more_wild_potions": return spr_powerup_wild_potion;

        default: return spr_none; // If no matching sprite, use a placeholder
    }
}



