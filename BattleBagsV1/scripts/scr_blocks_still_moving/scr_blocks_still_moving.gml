
function are_playable_blocks_settled(_self){
    
	var width = _self.width;
    var height = _self.height;
    var settled = false;
	var bottom_row = _self.bottom_playable_row;

    for (var i = 0; i < width; i++) 
	{	
        for (var j = 0; j <= bottom_row; j++) 
		{
	        
			var gem = _self.grid[i, j];
			
			if (is_block_popping(gem)) gem.fall_delay = 1;
			
			if (!is_block_empty(gem) && !is_block_enemy(gem))
			{
		        // Ensure falling, popping, OR movement offsets are considered
		        if (!is_block_falling(gem) || !is_block_popping(gem)) 
				{
					settled = true;
				}
			}
		}
	}
    return settled;
}

function is_playable_block_settled(block)
{
	var settled = false;
	if !is_block_empty(block)
	&& !is_block_falling(block)
	&& !is_block_enemy(block)
	&& !is_block_popping(block)
	{
		settled = true;
	}
	return settled;
}

function is_block_empty(block)
{
	return block.type == BLOCK.NONE;
}

function is_block_falling(block)
{
	return block.falling || block.fall_delay < block.max_fall_delay;
}

function is_block_popping(block)
{
	return block.popping;
}

function is_block_enemy(block)
{
	return block.is_enemy_block;
}