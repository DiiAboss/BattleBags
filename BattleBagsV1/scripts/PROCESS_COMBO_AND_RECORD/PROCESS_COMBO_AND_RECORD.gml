function process_combo_timer_and_record_max(_self)
{
	
	// ✅ Ensure combo resets **ONLY when no movement remains**
	if (!blocks_still_moving(_self)){
		if (_self.combo_timer < _self.max_combo_timer)
		{
			_self.combo_timer ++;
		}
		else
		{
			record_highest_combo(self, _self.combo);
			_self.combo = 0;
			_self.combo_timer = _self.max_combo_timer;
		}
	}
	else
	{
		_self.combo_timer = 0;
	}
}