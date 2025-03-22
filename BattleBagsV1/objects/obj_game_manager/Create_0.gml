/// @description

player_stats = 
{
	highest_combo: 0,
	enemies_defeated: 0,
	blocks_destroyed: 0,
	longest_run: 0,
    highest_score: 0,
}


//  Console State
console_active = false;
console_input = "";
console_history = [];
max_history = 10; // Limit history size

//  Visual Settings
console_x = 10;
console_y = room_height / 2;
console_width = 200;
console_height = 200;
console_alpha = 0.75;

randomize();

for (var i = 0; i < 10; i++) {
    var upg = generate_upgrade();
    if (!is_undefined(upg)) {
        show_debug_message("Upgrade: " + upg.name + " [" + upg.rarity + "]");
        for (var m = 0; m < array_length(upg.mods); m++) {
            var _mod = upg.mods[m];
            var polarity_text = (_mod.polarity == POLARITY.POSITIVE) ? "Positive" : "Negative";
            show_debug_message(" - Mod: " + _mod.name 
                + ", Rarity: " + string(_mod.rarity) 
                + ", Polarity: " + polarity_text
                + ", Effect: " + _mod.desc 
                + " by " + string(_mod.value * 100) + "%");
        }
    } else {
        show_debug_message("Upgrade generation failed - struct not found or incomplete.");
    }
}

//show_debug_overlay(true);
input = new Input();  // Controller support

input_delay = 0;

total_gold = 0;

game_mode = -1;

enum PLAYER_CONTROLLER
{
    MOUSE = 99,
    NONE  = -1
}

enum DATA_TYPE {
    CREATE_HOST = 0,
    JOIN_HOST = 1,
    STOP_HOST = 2,
    POSITION = 3,
    KEY_PRESS = 4,
    DEBUG = 5,
    GET_HOSTS = 6,
    LEAVE_HOST = 7,
    SEND_PLAYER_STATS = 8,
    START_GAME = 9,
    SWAP_POSITION = 10,
    GET_PLAYER_STATS = 11,
    GET_NEW_PLAYERS = 12,
    HEARTBEAT = 13,
    CREATE_LOBBY = 14,
    FIND_MATCH = 15,
    CANCEL_MATCHMAKING = 16,
}

// LOCAL MULTIPLAYER
max_players = 2;  // Set the number of players


player = array_create(max_players, PLAYER_CONTROLLER.NONE);
player[0] = PLAYER_CONTROLLER.MOUSE;

player_controls = [INPUT.KEYBOARD, INPUT.NONE];
devices = array_create(12, -1);

randomize();