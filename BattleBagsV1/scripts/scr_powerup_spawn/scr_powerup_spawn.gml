// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function powerup_spawn(_array)
{
	for (var i=0; i < array_length(_array) - 1; i++)
	{
		if (_array[i] != -1)
		{
			if (irandom(100) < (_array[i].chance))
			{
				return (_array[i].powerup)
			}
		}
		else
		{
			return (-1);
		}
	}
	return (-1);
}