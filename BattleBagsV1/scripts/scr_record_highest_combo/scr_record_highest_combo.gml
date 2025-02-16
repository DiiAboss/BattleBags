// Script Created By DiiAboss AKA Dillon Abotossaway
///@function   
///
///@description
///
///@param {id} _self
///@param {real} combo
///
///@return
function record_highest_combo(_self, combo)
{
	if (combo > _self.highest_max_combo)
	{
		_self.highest_max_combo = combo;
        obj_game_manager.player_stats.highest_combo = combo;
	}	
}