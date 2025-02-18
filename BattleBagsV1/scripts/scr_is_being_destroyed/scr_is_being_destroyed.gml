function is_being_destroyed(_x, _y) {
    for (var i = 0; i < ds_list_size(global.pop_list); i++) {
        var pop_data = ds_list_find_value(global.pop_list, i);
        if (pop_data.x == _x && pop_data.y == _y) {
            return true; // Found in the destruction list
        }
    }
    return false;
}

function is_being_destroyed_mp(player, _x, _y) {
    for (var i = 0; i < ds_list_size(player.pop_list); i++) {
        var pop_data = ds_list_find_value(player.pop_list, i);
        if (pop_data.x == _x && pop_data.y == _y) {
            return true; // Found in the destruction list
        }
    }
    return false;
}