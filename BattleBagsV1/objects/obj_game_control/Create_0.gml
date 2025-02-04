

randomize();
FPS = 60;
mega_blocks = ds_list_create();


total_blocks_destroyed = 0;
total_combo_counter = 0;
highest_max_combo   = 0;
total_damage_dealt  = 0;


global.swap_queue = { active: false, ax: -1, ay: -1, bx: -1, by: -1 };

// ------------------------------------------------------
// Adjustable Stats
// ------------------------------------------------------
game_speed_default = 1;
game_speed_start   = game_speed_default;

global.modifier = game_speed_default / game_speed_start;

game_speed_combo_modifier = 0.5;
game_speed_increase_modifier = 2;
game_speed_fight_for_your_life_modifier = 0;

global.gameSpeed = game_speed_default;

global.enemy_timer_game_speed = 1;

global.player_total_level = 1;
global.player_level = 1;

level = 1;
target_level = 0;

target_experience_points = 0;
experience_points = 0;

max_exp_mod = 50;
max_exp_level_mod = 10;

max_experience_points = max_exp_mod + ((max_exp_level_mod * level) + (level * level)) - level;

fight_for_your_life = false;

// Set to player hearts of 3 x 4 pieces (hearts will only heal a pieace of health now)


timer_block_slow_down = 0;

lose_life_max_timer = FPS * global.modifier * 3;
lose_life_timer     = 0;

health_per_heart = 4;

total_hearts = 3;

max_hearts = total_hearts * health_per_heart;
max_player_health = max_hearts;
player_health     = max_player_health;


highest_points = 0;
total_points   = 0;

total_upgrades = 0;

money_this_round = 0;
total_money = 0;

matches_this_round = 0;
total_matches = 0;

total_time = 0;
time_in_seconds = total_time * FPS;
global.gold	= 0;

time_in_minutes = floor(time_in_seconds / 60);

draw_time = string(time_in_minutes) + ":" + string(floor(time_in_seconds % 60));

diagonal_matches = false;

// ------------------------------------------------------
// Global Variables & Game State
// ------------------------------------------------------
global.combo_x = -1;
global.combo_y = -1;
global.paused = false;


global.grid_shake_amount = 0; // Grid shake intensity
// ------------------------------------------------------
// Block Types
// ------------------------------------------------------




global_shape_function_init();


combo_timer = 0;
max_combo_timer = 30;

// ✅ Initialize Global Upgrade System
global.upgrades_list = ds_list_create(); // Stores all upgrades
global.selected_upgrades = array_create(3, -1); // Stores 3 upgrades per level-up
global.target_level = 0; // Tracks pending level-ups
global.in_upgrade_menu = false; // Tracks if menu is open

// ✅ Populate the upgrade list
generate_all_upgrades();


global.enemy_attack_queue = ds_list_create();


spawn_rows = 6; // Number of initial rows to spawn
width = 8;
height = 16;

// ------------------------------------------------------
// Swap Mechanics
// ------------------------------------------------------
swap_in_progress = false;
global.needs_match_check = false;
swap_info = {
    from_x: -1, from_y: -1, to_x: -1, to_y: -1,
    progress: 0, speed: 0.1
};

// ------------------------------------------------------
// Board Setup
// ------------------------------------------------------
global.gemSize = 64;
WILD_BLOCK = -2;
offset = 32;
board_x_offset = 128;

max_shake_timer = 30;

global.topmost_row = height - 1;
global.pop_list = ds_list_create();

global.lastSwapX = -1;
global.lastSwapY = -1;
player_level = 0;
combo = 0;
numberOfGemTypes = 8;
darken_alpha = 0;
gem_size = 64;
global_y_offset = 0;

total_multiplier_next = 1;

global.fall_timer = 0;

global.in_upgrade_menu = false;

// ------------------------------------------------------
// Create The Grid
// ------------------------------------------------------

create_gem_spawn_rates(self);
initialize_game_board(self, width, height, spawn_rows);

// ------------------------------------------------------
// Gem Selection Variables
// ------------------------------------------------------
selected_x = -1;
selected_y = -1;
dragged = false;



// ------------------------------------------------------
// Timers & Speeds
// ------------------------------------------------------
spawn_timer = 60 / global.gameSpeed;
shift_speed = 0.1 * global.gameSpeed;
shift_timer = 0;
