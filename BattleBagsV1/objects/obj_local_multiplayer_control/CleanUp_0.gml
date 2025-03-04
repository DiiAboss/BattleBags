/// @description


cleanup_ai_players(self);

for (var i = 0; i < ds_list_size(global.player_list); i++) {
    var player = ds_list_find_value(global.player_list, i);
    ds_list_destroy(player.pop_list);
}

ds_list_destroy(global.player_list);
