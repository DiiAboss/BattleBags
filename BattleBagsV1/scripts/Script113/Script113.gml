// New script: LOBBY_SYSTEM.gml
/// @function create_lobby
/// @param {string} lobby_name - Name for the new lobby
/// @param {int} max_players - Maximum number of players allowed
/// @param {struct} settings - Game settings like difficulty, etc.
function create_lobby(lobby_name, max_players, settings) {
    with (obj_client) {
        var data = ds_map_create();
        ds_map_add(data, "type", DATA_TYPE.CREATE_LOBBY);
        ds_map_add(data, "lobbyName", lobby_name);
        ds_map_add(data, "maxPlayers", max_players);
        ds_map_add(data, "settings", settings);
        
        send_map_over_UDP(self, data, DATA_TYPE.CREATE_LOBBY);
    }
}

/// @function find_ranked_match
/// @param {string} player_id - Player's unique identifier
/// @param {int} rating - Player's current skill rating
function find_ranked_match(player_id, rating) {
    with (obj_client) {
        is_in_matchmaking = true;
        
        var data = ds_map_create();
        ds_map_add(data, "type", DATA_TYPE.FIND_MATCH);
        ds_map_add(data, "playerId", player_id);
        ds_map_add(data, "rating", rating);
        
        send_map_over_UDP(self, data, DATA_TYPE.FIND_MATCH);
    }
}