

randomize();
FPS = 60;

// ------------------------------------------------------
// Adjustable Stats
// ------------------------------------------------------
game_speed_default = 3;
game_speed_combo_modifier = 0.5;
game_speed_increase_modifier = 2;
game_speed_fight_for_your_life_modifier = 0.1;
global.gameSpeed = game_speed_default;

global.player_total_level = 1;
global.player_level = 1;

fight_for_your_life = false;

max_player_health = 10;
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

// ------------------------------------------------------
// Global Variables & Game State
// ------------------------------------------------------
global.combo_x = -1;
global.combo_y = -1;
global.selected_upgrades = array_create(3, -1); // Stores 3 upgrades at a time
global.upgrade_selected = false; // Tracks if upgrades were selected
global.paused = false;


global.grid_shake_amount = 0; // Grid shake intensity
// ------------------------------------------------------
// Block Types
// ------------------------------------------------------
enum BLOCK {
    WILD = -2, NONE = -1, RED = 0, YELLOW = 1, GREEN = 2, PINK = 3, PURPLE = 4,
    LIGHTBLUE = 5, ORANGE = 6, GREY = 7, WHITE = 8, BLACK = 9
}

// ------------------------------------------------------
// Shape Templates (Stored in DS Map)
// ------------------------------------------------------
global.shape_templates = ds_map_create();
ds_map_add(global.shape_templates, "square_3x3", [
    [1, 1, 1],
    [1, 1, 1],
    [1, 1, 1]
]);
ds_map_add(global.shape_templates, "line_1x3", [
    [1, 1, 1]
]);
ds_map_add(global.shape_templates, "block_2x3", [
    [1, 1, 1],
    [1, 1, 1]
]);
ds_map_add(global.shape_templates, "cross", [
    [0, 1, 0],
    [1, 1, 1],
    [0, 1, 0]
]);
ds_map_add(global.shape_templates, "x_shape", [
    [1, 0, 1],
    [0, 1, 0],
    [1, 0, 1]
]);

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

width = 8;
height = 16;
global.topmost_row = height - 1;
global.pop_list = ds_list_create();

global.lastSwapX = -1;
global.lastSwapY = -1;
player_level = 0;
combo = 0;
numberOfGemTypes = 7;
darken_alpha = 0;
gem_size = 64;
global_y_offset = 0;

// ------------------------------------------------------
// Color Spawn Weight System
// ------------------------------------------------------
global.color_spawn_weight = array_create(numberOfGemTypes, 4);

// ------------------------------------------------------
// Powerups System
// ------------------------------------------------------
powerups = array_create(7, -1);
powerups[0] = create_powerup(POWERUP.SWORD);
powerups[1] = create_powerup(POWERUP.BOW);
powerups[2] = create_powerup(POWERUP.BOMB);

for (var i = 0; i < array_length(powerups) - 1; i++) {
    if (powerups[i] != -1) {
        powerups[i].chance = 10;
    }
}

// ------------------------------------------------------
// Create The Grid
// ------------------------------------------------------
grid = array_create(width);
for (var i = 0; i < width; i++) {
    grid[i] = array_create(height);
    for (var j = 0; j < height; j++) {
        grid[i][j] = create_gem(-1); // Initialize all cells as empty
    }
}

global.fall_timer = 0;

// ------------------------------------------------------
// Create Gem Offset Arrays
// ------------------------------------------------------
gem_x_offsets = array_create(width);
gem_y_offsets = array_create(width);
for (var i = 0; i < width; i++) {
    gem_x_offsets[i] = array_create(height, 0);
    gem_y_offsets[i] = array_create(height, 0);
}

// ------------------------------------------------------
// Gem Selection Variables
// ------------------------------------------------------
selected_x = -1;
selected_y = -1;
dragged = false;

// ------------------------------------------------------
// Initial Gem Spawn Rows
// ------------------------------------------------------
locked = array_create(width);
for (var i = 0; i < width; i++) {
    locked[i] = array_create(height, false);
}

spawn_rows = 6; // Number of initial rows to spawn
spawn_rows = min(spawn_rows, height);
for (var i = 0; i < width; i++) {
    for (var j = height - spawn_rows; j < height; j++) {
        grid[i][j] = create_gem(irandom(numberOfGemTypes - 1));
    }
}

// Ensure the entire grid is valid
for (var i = 0; i < width; i++) {
    for (var j = 0; j < height; j++) {
        if (is_undefined(grid[i][j]) || !is_struct(grid[i][j])) {
            grid[i][j] = create_gem(-1);
        }
    }
}

// ------------------------------------------------------
// Timers & Speeds
// ------------------------------------------------------
spawn_timer = 60 / global.gameSpeed;
shift_speed = 0.1 * global.gameSpeed;
shift_timer = 0;
