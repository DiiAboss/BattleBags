function all_pops_finished() 
{
    if (ds_list_size(global.pop_list) == 0) return true; 

	// Ensure all gems have fully scaled before dropping blocks
	for (var i = 0; i < ds_list_size(global.pop_list); i++) {
	    var pop_data = ds_list_find_value(global.pop_list, i);
	    if (pop_data.scale < 1.1) return false; 
	}
	return true;
}