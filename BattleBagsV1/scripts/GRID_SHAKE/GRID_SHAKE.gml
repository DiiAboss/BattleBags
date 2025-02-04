function process_grid_shake(grid_shake_enabled)
{
	if (grid_shake_enabled)
	{
		global.grid_shake_amount = 1;
	}
	else
	{

		if (global.grid_shake_amount > 0) {
		    global.grid_shake_amount *= 0.9; // Slowly decay the shake
		}
		else
		{
			global.grid_shake_amount = 0;
		}
	}
}