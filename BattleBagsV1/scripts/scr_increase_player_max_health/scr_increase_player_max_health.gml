// Script Created By DiiAboss AKA Dillon Abotossaway
///@function   
///
///@description
///
///@param {id} _self
///@param {real} _amount
///
///@return
function increase_player_max_hearts(_self, _amount){
	
	
	_self.total_hearts += _amount;
	var amount = _self.total_hearts * _self.health_per_heart;
	
	_self.max_player_health = amount;
}