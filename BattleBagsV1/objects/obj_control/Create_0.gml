
// Adjstable stats

global.gameSpeed = 3;



//-----------------------------------
// BLOCKS
//-----------------------------------
enum BLOCK 
{
	RED = 0
		
}

swap_in_progress = false;
global.needs_match_check = false;
// ----------------------------------
// 1. Setting up the board
// ----------------------------------
global.gemSize = 64;

WILD_BLOCK = -2;
swap_in_progress = false;

swap_info = {
    from_x: -1,
    from_y: -1,
    to_x: -1,
    to_y: -1,
    progress: 0,
    speed: 0.1
};

offset = 32;
board_x_offset = 128;

width = 8;
height = 17;
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


powerups = array_create(7, -1);



powerups[0] = create_powerup(POWERUP.SWORD);
powerups[1] = create_powerup(POWERUP.BOW);
powerups[2] = create_powerup(POWERUP.BOMB);

for (var i = 0; i < array_length(powerups) - 1; i++)
{
	if (powerups[i] != -1)
	{
		powerups[i].chance = 10;
	}
}

// ----------------------------------
// 2. CREATE THE GRID
// ----------------------------------
grid = array_create(width);
for (var i = 0; i < width; i++) {
    grid[i] = array_create(height);
    for (var j = 0; j < height; j++) {
        grid[i][j] = create_gem(-1); // Initialize all cells as empty gems
    }
}
global.fall_timer = 0;
// ----------------------------------
// 3. CREATE GEM OFFSET ARRAYS
// ----------------------------------
gem_x_offsets = array_create(width);
gem_y_offsets = array_create(width);
for (var i = 0; i < width; i++) {
    gem_x_offsets[i] = array_create(height, 0);
    gem_y_offsets[i] = array_create(height, 0);
}

// ----------------------------------
// 4. GEM SELECTION
// ----------------------------------
selected_x = -1;
selected_y = -1;
dragged = false;

// ----------------------------------
// 5. INITIAL GEM SPAWN ROWS
// ----------------------------------
locked = array_create(width);
for (var i = 0; i < width; i++) {
    locked[i] = array_create(height, false);
}
spawn_rows = 6; // Number of initial rows of gems to spawn
// Spawn random gems in the bottom rows
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

// ----------------------------------
// 6. TIMERS & SPEED
// ----------------------------------
spawn_timer = 60 / global.gameSpeed;
shift_speed = 0.1 * global.gameSpeed;
shift_timer = 0;
