function process_grid_shake(grid_shake_enabled, grid_shake)
{
	if (grid_shake_enabled)
	{
		grid_shake = 1;
	}
	else
	{

		if (grid_shake > 0) {
		    grid_shake *= 0.9; // Slowly decay the shake
		}
		else
		{
			grid_shake = 0;
		}
	}
    
    return grid_shake;
}