/// @description


// TODO: Research Room where players can just play normally and gain gold for completing objectives.

// TODO: Players Lounge: Room where players can play gambling minigames for gold.

// TODO: Game Loop : Player picks a location on map, 

// Player moves to that location, 
// Completes the objective at the location, 
// Players gets an upgrade, 
// Then chooses a new spot to goto until the player feels like the game is getting to hard (the engine is constantly speeding up), 
// Then returns home, player converts their EP for gold and surrenders all their upgrades aquiared during the run.
// Player upgrades factory to allow for easier progression on overworld map.

// TODO: Create the general that will give some orders as a tutorial

// TODO: EVENTS: BATTLES, COLLECTS, SWARMS, 

player_stats = 
{
    player_name:        0,
    player_level:       0,
	highest_combo:      0,
	enemies_defeated:   0,
	blocks_destroyed:   0,
	longest_run:        0,
    highest_score:      0,
    player_inventory:   [],
}


stats =
{
    ep_gain:        1,
    ep_combo_multi: 1.1,
    gold_per_coin:  1,
    shop_price:     1,
    objective_ep_gain: 1,
    overworld_speed: 0.05,
	overheat_rate: 1,
	overheat_cooldown: 0.25,
	conveyor_speed: 1,
	shift_speed: 1,
	max_combo_timer: 60,
}

number_of_drones = 2;
drone_array = [];

for (var d = 0; d < number_of_drones; d++)
{
	array_push(drone_array, new Drone(self, d, -1, -1));
    drone_array[d].player = noone;
	
	drone_array[d].x += (room_width * 0.75) + (128*d);
}

mod_stats = 
{
    ep_gain:        1,
    ep_combo_multi: 1,
    gold_per_coin:  1,
    shop_price:     1,
    objective_ep_gain: 1,
    overworld_speed: 1,
	overheat_rate: 1,
	overheat_cooldown: 0.25,
	conveyor_speed: 1,
	shift_speed: 1,
	max_combo_timer: 1,
    
}
can_2x2 = true;
diagonal_matches = false;

depth = -99;

town_pos = [960, 560];

current_run =
{
    overworld_x: 960,
    overworld_y: 560,
    dir: 0,
    start_x: 960,
    start_y: 560,
    target_x: 1152,
    target_y: 512,
    travel_speed: 0.25,
    total_time: 0,
    travel_progress: 0,
}

event = noone;
event_start = false;


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
generate_debug_upgrades();


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

time_left = 999;

//instance_create_layer(1366, 840,"pop_ups", obj_announceWindow);
