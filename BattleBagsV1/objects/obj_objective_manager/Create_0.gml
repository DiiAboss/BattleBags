/// @description

objectives = array_create(0);
objective_spacing = 24;  // spacing for drawing
objective_x = 16;        // X position left of the board
objective_y = 200;       // Starting Y position

game_control = obj_game_control;


// Break 25 red blocks objective
add_objective(new Objective(OBJECTIVE_TYPE.BREAK_COLOR, 25, BLOCK.RED, function() {
    game_control.gold += 10; // example reward
}));

// Get a 10x combo objective
add_objective(new Objective(OBJECTIVE_TYPE.GET_COMBO, 10, undefined, function() {
    game_control.gold += 10; // example reward
}));

// Match 5 blocks objective
add_objective(new Objective(OBJECTIVE_TYPE.MATCH_SIZE, 5, undefined, function() {
    game_control.gold += 10;
}));

// Clear 10 lines objective
add_objective(new Objective(OBJECTIVE_TYPE.CLEAR_LINES, 10, undefined, function() {
    game_control.gold += 10;
}));