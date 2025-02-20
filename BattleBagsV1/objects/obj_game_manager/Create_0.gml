/// @description

player_stats = 
{
	highest_combo: 0,
	enemies_defeated: 0,
	blocks_destroyed: 0,
	longest_run: 0,
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

enum DATA_TYPE
{
    CREATE_HOST,
    JOIN_HOST,
    STOP_HOST,
    POSITION,
    KEY_PRESS,
    DEBUG,
    GET_HOSTS,
    LEAVE_HOST,
    PLAYER_STATS,
    START_GAME,
    SWAP_POSITION,
}

// LOCAL MULTIPLAYER
max_players = 2;  // Set the number of players


player = array_create(max_players, PLAYER_CONTROLLER.NONE);
player[0] = PLAYER_CONTROLLER.MOUSE;

player_controls = [INPUT.KEYBOARD, INPUT.NONE];
devices = array_create(12, -1);