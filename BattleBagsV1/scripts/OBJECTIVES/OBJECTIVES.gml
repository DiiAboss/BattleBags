// Script Created By DiiAboss AKA Dillon Abotossaway

// ========= ENUMS =========
enum OBJECTIVE_TYPE {
    BREAK_COLOR,
    GET_COMBO,
    MATCH_SIZE,
    CLEAR_LINES,
    MATCHES_IN_MOVES,
    KEEP_BELOW_ROW,
    MATCH_SPECIAL,
    DESTROY_SPECIAL,
    COMBO_IN_MOVES,
    TIMED_CHALLENGE
}

enum OBJECTIVE_LEVEL {
    LEVEL_1 = 1,
    LEVEL_2 = 2,
    LEVEL_3 = 3,
    LEVEL_4 = 4
}

enum EVENT_TYPE {
    NONE,
    BUG_SWARM,
    COLD_SNAP,
    LOOSE_GROUND,
    MINOR_BATTLE
}

// ========= OBJECTIVE CONSTRUCTOR =========
function Objective(_type, _target, _data = undefined, _reward = undefined, _level = OBJECTIVE_LEVEL.LEVEL_1, _sprite = spr_none, _ep = 5) constructor {
    type = _type;            // Objective type
    target = _target;        // Target number to achieve
    progress = 0;            // Current progress
    data = _data;            // Optional extra data (e.g., color, move count)
    reward = _reward;        // Reward function for completion
    level = _level;          // Difficulty level
    sprite = _sprite;        // Sprite to display
    ep = _level * _ep;       // Energy points awarded (scales with level)
    completed = false;       // Status of completion
    completion_time = 0;     // When objective was completed (for animation)
    moves_start = 0;         // Starting move count for move-limited objectives
    current_cycle = 0;       // For tracking cycles in cycle-based objectives
    
    // Extra data for specific objective types
    extra = {
        moves_left: 0,       // For MATCHES_IN_MOVES
        matches_made: 0,     // For MATCHES_IN_MOVES
        cycles_below: 0,     // For KEEP_BELOW_ROW
        event_related: false // Whether this objective is part of an event
    };
    
    // Animation properties
    animation = {
        scale: 1,
        alpha: 1,
        complete_flash: 0
    };
    
    // Check if completed
    check_completion = function() {
        if (progress >= target && !completed) {
            completed = true;
            completion_time = current_time;
            trigger_reward();
            
            // Increment the completed objectives counter
            with (obj_objective_manager) {
                completed_objectives++;
                total_ep_gained += other.ep;
                
                // Check if we hit milestone (every 5 objectives)
                if (completed_objectives mod 5 == 0) {
                    bonus_ep = completed_objectives * 2; // Bonus scales with progress
                    total_ep_gained += bonus_ep;
                    show_bonus_notification = true;
                    bonus_notification_time = current_time;
                }
            }
        }
    };
    
    // Trigger reward when completed
    trigger_reward = function() {
        if (!is_undefined(reward)) {
            reward();
        }
        
        // Add EP to game resource
        with (obj_game_control) {
            energy_points += other.ep;
        }
    };
    
    // Update the objective (for animation, time-based checking)
    update = function() {
        // Animation handling for completed objectives
        if (completed) {
            var time_since_completion = current_time - completion_time;
            if (time_since_completion < 1000) {
                // Flash effect
                animation.complete_flash = 0.5 + sin(time_since_completion * 0.02) * 0.5;
                animation.scale = 1 + sin(time_since_completion * 0.01) * 0.1;
            } else {
                animation.complete_flash = 0;
                animation.scale = 1;
            }
        }
        
        // Handle move-based objectives
        if (type == OBJECTIVE_TYPE.MATCHES_IN_MOVES || type == OBJECTIVE_TYPE.COMBO_IN_MOVES) {
            // Check if we've run out of moves
            with (obj_game_control) {
                if (moves - other.moves_start >= other.data) {
                    other.progress = 0; // Failed the challenge
                }
            }
        }
        
        // Handle cycle-based objectives (KEEP_BELOW_ROW)
        if (type == OBJECTIVE_TYPE.KEEP_BELOW_ROW) {
            current_cycle++;
            
            // Check if all blocks are below the target row
            var all_below = true;
            with (obj_game_control) {
                // Logic to check if blocks exceed row limit goes here
                // This depends on your board implementation
                all_below = !blocks_above_row(other.data);
            }
            
            if (all_below) {
                extra.cycles_below++;
            } else {
                extra.cycles_below = 0; // Reset if blocks go too high
            }
            
            // Update progress
            progress = extra.cycles_below;
        }
    };
}

// ========= OBJECTIVE PROGRESS FUNCTIONS =========
function objective_progress(type, data = undefined, amount = 1) {
    with (obj_objective_manager) {
        for (var s = 0; s < array_length(objective_stacks); s++) {
            if (!stack_unlocked[s]) continue;
            
            // Only process the active objective for each stack
            if (active_objectives[s] == -1) continue;
            
            var obj = objective_stacks[s][active_objectives[s]];
            
            // Skip if not matching type or already completed
            if (obj.type != type || obj.completed) continue;
            
            // Check if this is a bug swarm objective
            var is_bug_swarm = (obj.type == OBJECTIVE_TYPE.DESTROY_SPECIAL || obj.type == OBJECTIVE_TYPE.MATCH_SPECIAL) && 
                              (!is_undefined(obj.data) && obj.data == BLOCK.BUG);
            
            // If it's a bug swarm objective, set the special_event flag
            if (is_bug_swarm && !obj_game_control.special_event) {
                obj_game_control.special_event = true;
                obj_game_control.special_event_type = EVENT_TYPE.BUG_SWARM;
            }
            
            // Type-specific progress updates
            switch (type) {
                case OBJECTIVE_TYPE.GET_COMBO:
                case OBJECTIVE_TYPE.MATCH_SIZE:
                    // For these types, we track max value
                    if (amount > obj.progress) {
                        obj.progress = amount;
                    }
                    break;
                    
                case OBJECTIVE_TYPE.MATCHES_IN_MOVES:
                    // Track matches made within move limit
                    obj.extra.matches_made += amount;
                    obj.progress = obj.extra.matches_made;
                    break;
                    
                case OBJECTIVE_TYPE.COMBO_IN_MOVES:
                    // Track max combo within move limit
                    if (amount > obj.progress) {
                        obj.progress = amount;
                    }
                    break;
                    
                case OBJECTIVE_TYPE.MATCH_SPECIAL:
                case OBJECTIVE_TYPE.DESTROY_SPECIAL:
                    // For special blocks (bugs, ice), check if data matches
                    if (!is_undefined(data) && data == obj.data) {
                        obj.progress += amount;
                    }
                    break;
                    
                case OBJECTIVE_TYPE.BREAK_COLOR:
                    // Check if block color matches objective
                    if (is_undefined(data) || obj.data == data) {
                        obj.progress += amount;
                    }
                    break;
                    
                default:
                    // Default behavior - increment progress
                    obj.progress += amount;
                    break;
            }
            
            // Check if objective is completed
            obj.check_completion();
            
            // If it's completed and it's a bug swarm objective, set the completed flag
            if (obj.completed && is_bug_swarm) {
                obj_game_control.special_event_finished = true;
            }
            
            // If it's completed, mark it for removal (will be processed in step event)
            if (obj.completed) {
                stack_needs_update[s] = true;
                update_stack_timer[s] = current_time;
            }
        }
        
        // Also process event objectives if active
        if (current_event != EVENT_TYPE.NONE) {
            for (var i = 0; i < array_length(event_objectives); i++) {
                var obj = event_objectives[i];
                
                // Skip if not matching type or already completed
                if (obj.type != type || obj.completed) continue;
                
                // Check if this is a bug swarm objective
                var is_bug_swarm = (obj.type == OBJECTIVE_TYPE.DESTROY_SPECIAL || obj.type == OBJECTIVE_TYPE.MATCH_SPECIAL) && 
                                  (!is_undefined(obj.data) && obj.data == BLOCK.BUG);
                
                // If it's a bug swarm objective, set the special_event flag
                if (is_bug_swarm && !obj_game_control.special_event) {
                    obj_game_control.special_event = true;
                    obj_game_control.special_event_type = EVENT_TYPE.BUG_SWARM;
                }
                
                // Type-specific progress updates (same as above)
                switch (type) {
                    case OBJECTIVE_TYPE.GET_COMBO:
                    case OBJECTIVE_TYPE.MATCH_SIZE:
                        if (amount > obj.progress) {
                            obj.progress = amount;
                        }
                        break;
                    
                    case OBJECTIVE_TYPE.MATCHES_IN_MOVES:
                        obj.extra.matches_made += amount;
                        obj.progress = obj.extra.matches_made;
                        break;
                    
                    case OBJECTIVE_TYPE.COMBO_IN_MOVES:
                        if (amount > obj.progress) {
                            obj.progress = amount;
                        }
                        break;
                    
                    case OBJECTIVE_TYPE.MATCH_SPECIAL:
                    case OBJECTIVE_TYPE.DESTROY_SPECIAL:
                        if (!is_undefined(data) && data == obj.data) {
                            obj.progress += amount;
                        }
                        break;
                    
                    case OBJECTIVE_TYPE.BREAK_COLOR:
                        if (is_undefined(data) || obj.data == data) {
                            obj.progress += amount;
                        }
                        break;
                    
                    default:
                        obj.progress += amount;
                        break;
                }
                
                // Check if objective is completed
                obj.check_completion();
                
                // If it's completed and it's a bug swarm objective, set the completed flag
                if (obj.completed && is_bug_swarm) {
                    obj_game_control.special_event_finished = true;
                }
            }
        }
    }
}


// ========= HELPER FUNCTIONS =========
function block_name(block_type) {
    switch (block_type) {
        case BLOCK.RED: return "Red";
        case BLOCK.YELLOW: return "Yellow";
        case BLOCK.GREEN: return "Green";
        case BLOCK.BLUE: return "Blue";
        case BLOCK.PURPLE: return "Purple";
        case BLOCK.LIGHTBLUE: return "Light Blue";
        case BLOCK.ORANGE: return "Orange";
        case BLOCK.PINK: return "Pink";
        case BLOCK.GREY: return "Grey";
        case BLOCK.WHITE: return "White";
        case BLOCK.BLACK: return "Black";
        case BLOCK.BUG: return "Bug";
        case BLOCK.ICE: return "Ice";
        default: return "Random";
    }
}

function add_objective_to_stack(_objective, _stack_index = 0) {
    with (obj_objective_manager) {
        if (_stack_index >= array_length(objective_stacks)) {
            // Create a new stack if it doesn't exist
            array_push(objective_stacks, []);
            array_push(stack_unlocked, false);
            array_push(active_objectives, -1);
            array_push(stack_needs_update, false);
            array_push(update_stack_timer, 0);
            array_push(stack_x_offsets, 0);
            array_push(stack_y_offsets, 0);
        }
        
        // Add objective to the specified stack
        array_push(objective_stacks[_stack_index], _objective);
        
        // If this is the first objective in the stack, make it active
        if (array_length(objective_stacks[_stack_index]) == 1) {
            active_objectives[_stack_index] = 0;
        }
    }
}

function unlock_objective_stack(_stack_index) {
    with (obj_objective_manager) {
        if (_stack_index < array_length(stack_unlocked)) {
            stack_unlocked[_stack_index] = true;
            
            // Make sure to activate the first objective in stack
            if (array_length(objective_stacks[_stack_index]) > 0 && active_objectives[_stack_index] == -1) {
                active_objectives[_stack_index] = 0;
            }
        }
    }
}

function generate_objective(_level, _event_type = EVENT_TYPE.NONE) {
    var obj;
    
    // If this is an event-specific objective
    if (_event_type != EVENT_TYPE.NONE) {
        switch (_event_type) {
            case EVENT_TYPE.BUG_SWARM:
                var rand = irandom(1);
                if (rand == 0) {
                    obj = new Objective(
                        OBJECTIVE_TYPE.DESTROY_SPECIAL, 
                        20, 
                        BLOCK.BUG, 
                        undefined, 
                        _level, 
                        spr_none, 
                        8
                    );
                } else {
                    obj = new Objective(
                        OBJECTIVE_TYPE.MATCH_SPECIAL, 
                        4, 
                        BLOCK.BUG, 
                        undefined, 
                        _level, 
                        spr_none, 
                        10
                    );
                }
                obj.extra.event_related = true;
                return obj;
                
            case EVENT_TYPE.COLD_SNAP:
                var rand = irandom(1);
                if (rand == 0) {
                    obj = new Objective(
                        OBJECTIVE_TYPE.DESTROY_SPECIAL, 
                        10, 
                        BLOCK.ICE, 
                        undefined, 
                        _level, 
                        spr_none, 
                        8
                    );
                } else {
                    obj = new Objective(
                        OBJECTIVE_TYPE.MATCH_SPECIAL, 
                        5, 
                        BLOCK.ICE, 
                        undefined, 
                        _level, 
                        spr_none, 
                        10
                    );
                }
                obj.extra.event_related = true;
                return obj;
                
            case EVENT_TYPE.LOOSE_GROUND:
                var rand = irandom(1);
                if (rand == 0) {
                    obj = new Objective(
                        OBJECTIVE_TYPE.TIMED_CHALLENGE, 
                        60, // 60 seconds
                        "survive", 
                        undefined, 
                        _level, 
                        spr_none, 
                        12
                    );
                } else {
                    obj = new Objective(
                        OBJECTIVE_TYPE.GET_COMBO, 
                        5, 
                        undefined, 
                        undefined, 
                        _level, 
                        spr_none, 
                        10
                    );
                }
                obj.extra.event_related = true;
                return obj;
                
            case EVENT_TYPE.MINOR_BATTLE:
                // Battle-specific objectives
                // You can implement these as needed
                break;
        }
    }
    
    // Standard objectives based on level
    var objective_type = irandom(2); // Choose one of 5 objective types
    
    switch (_level) {
        case OBJECTIVE_LEVEL.LEVEL_1:
            switch (objective_type) {
                case 0: // Break color
                    var color = irandom_range(BLOCK.RED, BLOCK.PURPLE);
                    obj = new Objective(
                        OBJECTIVE_TYPE.BREAK_COLOR, 
                        10, 
                        color, 
                        undefined, 
                        _level
                    );
                    break;
                case 1: // Combo
                    obj = new Objective(
                        OBJECTIVE_TYPE.GET_COMBO, 
                        3, 
                        undefined, 
                        undefined, 
                        _level
                    );
                    break;
                case 2: // Match size
                    obj = new Objective(
                        OBJECTIVE_TYPE.MATCH_SIZE, 
                        5, 
                        undefined, 
                        undefined, 
                        _level
                    );
                    break;
                case 3: // Matches in moves
                    obj = new Objective(
                        OBJECTIVE_TYPE.MATCHES_IN_MOVES, 
                        3, 
                        10, // 10 moves
                        undefined, 
                        _level
                    );
                    // Record starting move count
                    obj.moves_start = obj_game_control.moves;
                    obj.extra.moves_left = 10;
                    break;
                case 4: // Combo in moves
                    obj = new Objective(
                        OBJECTIVE_TYPE.COMBO_IN_MOVES, 
                        4, 
                        10, // 10 moves
                        undefined, 
                        _level
                    );
                    // Record starting move count
                    obj.moves_start = obj_game_control.moves;
                    obj.extra.moves_left = 10;
                    break;
            }
            break;
            
        case OBJECTIVE_LEVEL.LEVEL_2:
            switch (objective_type) {
                case 0: // Break color
                    var color = irandom_range(BLOCK.RED, BLOCK.PURPLE);
                    obj = new Objective(
                        OBJECTIVE_TYPE.BREAK_COLOR, 
                        15, 
                        color, 
                        undefined, 
                        _level
                    );
                    break;
                case 1: // Combo
                    obj = new Objective(
                        OBJECTIVE_TYPE.GET_COMBO, 
                        5, 
                        undefined, 
                        undefined, 
                        _level
                    );
                    break;
                case 2: // Match size
                    obj = new Objective(
                        OBJECTIVE_TYPE.MATCH_SIZE, 
                        6, 
                        undefined, 
                        undefined, 
                        _level
                    );
                    break;
                case 3: // Matches in moves
                    obj = new Objective(
                        OBJECTIVE_TYPE.MATCHES_IN_MOVES, 
                        4, 
                        10, // 10 moves
                        undefined, 
                        _level
                    );
                    // Record starting move count
                    obj.moves_start = obj_game_control.moves;
                    obj.extra.moves_left = 10;
                    break;
                case 4: // Keep below row
                    obj = new Objective(
                        OBJECTIVE_TYPE.KEEP_BELOW_ROW, 
                        10, // 10 cycles
                        obj_game_control.bottom_row - 7, // Row to stay below
                        undefined, 
                        _level
                    );
                    break;
            }
            break;
            
        case OBJECTIVE_LEVEL.LEVEL_3:
            switch (objective_type) {
                case 0: // Break color
                    var color = irandom_range(BLOCK.RED, BLOCK.PURPLE);
                    obj = new Objective(
                        OBJECTIVE_TYPE.BREAK_COLOR, 
                        20, 
                        color, 
                        undefined, 
                        _level
                    );
                    break;
                case 1: // Combo
                    obj = new Objective(
                        OBJECTIVE_TYPE.GET_COMBO, 
                        7, 
                        undefined, 
                        undefined, 
                        _level
                    );
                    break;
                case 2: // Match size
                    obj = new Objective(
                        OBJECTIVE_TYPE.MATCH_SIZE, 
                        7, 
                        undefined, 
                        undefined, 
                        _level
                    );
                    break;
                case 3: // Matches in moves
                    obj = new Objective(
                        OBJECTIVE_TYPE.MATCHES_IN_MOVES, 
                        5, 
                        10, // 10 moves
                        undefined, 
                        _level
                    );
                    // Record starting move count
                    obj.moves_start = obj_game_control.moves;
                    obj.extra.moves_left = 10;
                    break;
                case 4: // Keep below row
                    obj = new Objective(
                        OBJECTIVE_TYPE.KEEP_BELOW_ROW, 
                        10, // 10 cycles
                        obj_game_control.bottom_row - 5, // Row to stay below
                        undefined, 
                        _level
                    );
                    break;
            }
            break;
            
        case OBJECTIVE_LEVEL.LEVEL_4:
            switch (objective_type) {
                case 0: // Break color
                    var color = irandom_range(BLOCK.RED, BLOCK.PURPLE);
                    obj = new Objective(
                        OBJECTIVE_TYPE.BREAK_COLOR, 
                        20, 
                        color, 
                        undefined, 
                        _level
                    );
                    break;
                case 1: // Combo
                    obj = new Objective(
                        OBJECTIVE_TYPE.GET_COMBO, 
                        10, 
                        undefined, 
                        undefined, 
                        _level
                    );
                    break;
                case 2: // Match size
                    // For level 4, we need 2 matches of 7 or more
                    // This is a special case we'll need to handle
                    obj = new Objective(
                        OBJECTIVE_TYPE.MATCH_SIZE, 
                        2, // Need 2 matches of size 7+
                        7,  // Size of 7+
                        undefined, 
                        _level
                    );
                    break;
                case 3: // Matches in moves
                    obj = new Objective(
                        OBJECTIVE_TYPE.MATCHES_IN_MOVES, 
                        5, 
                        8, // 8 moves
                        undefined, 
                        _level
                    );
                    // Record starting move count
                    obj.moves_start = obj_game_control.moves;
                    obj.extra.moves_left = 8;
                    break;
                case 4: // Keep below row
                    obj = new Objective(
                        OBJECTIVE_TYPE.KEEP_BELOW_ROW, 
                        10, // 10 cycles
                        obj_game_control.bottom_row - 3, // Row to stay below
                        undefined, 
                        _level
                    );
                    break;
            }
            break;
    }
    
    return obj;
}

// Function to fill a stack with objectives of a specific level
function fill_objective_stack(_stack_index, _level, _count = 3) {
    with (obj_objective_manager) {
        // Clear existing objectives in this stack
        objective_stacks[_stack_index] = [];
        
        // Add new objectives
        for (var i = 0; i < _count; i++) {
            var obj = generate_objective(_level);
            array_push(objective_stacks[_stack_index], obj);
        }
        
        // Set the first objective as active
        if (array_length(objective_stacks[_stack_index]) > 0) {
            active_objectives[_stack_index] = 0;
        } else {
            active_objectives[_stack_index] = -1;
        }
    }
}

// Function to trigger a special event
function trigger_event(_event_type) {
    with (obj_objective_manager) {
        current_event = _event_type;
        event_start_time = current_time;
        
        // Clear previous event objectives
        event_objectives = [];
        
        // Generate event-specific objectives
        var event_obj_count = 2; // Number of event objectives to create
        for (var i = 0; i < event_obj_count; i++) {
            var obj = generate_objective(current_difficulty, _event_type);
            array_push(event_objectives, obj);
        }
    }
}

// Function to end active event
function end_event() {
    with (obj_objective_manager) {
        if (current_event != EVENT_TYPE.NONE) {
            current_event = EVENT_TYPE.NONE;
            event_objectives = [];
        }
    }
}

// Function to advance to the next objective in a stack
function advance_stack_objective(_stack_index) {
    with (obj_objective_manager) {
        if (_stack_index < 0 || _stack_index >= array_length(objective_stacks)) return;
        
        var stack = objective_stacks[_stack_index];
        var current_index = active_objectives[_stack_index];
        
        // Remove the completed objective
        if (current_index != -1 && current_index < array_length(stack)) {
            array_delete(stack, current_index, 1);
        }
        
        // If no more objectives in stack, generate new ones with increased difficulty
        if (array_length(stack) == 0) {
            var next_difficulty = min(current_difficulty + 1, OBJECTIVE_LEVEL.LEVEL_4);
            
            // Generate new objectives for this stack
            for (var i = 0; i < 3; i++) {
                var obj = generate_objective(next_difficulty);
                array_push(stack, obj);
            }
            
            // Add screen shake for new set
            current_shake = 3;
            
            // Add animation to the stack
            stack_x_offsets[_stack_index] = random_range(-5, 5);
            stack_y_offsets[_stack_index] = random_range(-5, 5);
            
            // If this is stack 0 and we only have 1 stack unlocked, unlock the second stack
            if (_stack_index == 0 && unlocked_stack_count == 1 && max_stacks > 1) {
                unlocked_stack_count = 2;
                stack_unlocked[1] = true;
                
                // Make sure stack 1 exists and has objectives
                if (array_length(objective_stacks) <= 1) {
                    objective_stacks[1] = [];
                    active_objectives[1] = -1;
                    stack_needs_update[1] = false;
                    update_stack_timer[1] = 0;
                    stack_x_offsets[1] = 0;
                    stack_y_offsets[1] = 0;
                }
                
                if (array_length(objective_stacks[1]) == 0) {
                    fill_objective_stack(1, current_difficulty);
                }
            }
        }
        
        // Set the new active objective to the first in stack
        if (array_length(stack) > 0) {
            active_objectives[_stack_index] = 0;
        } else {
            active_objectives[_stack_index] = -1;
        }
    }
}

// Function to add a priority objective to a stack (inserting at position 0)
function add_priority_objective(_stack_index, _event_type = EVENT_TYPE.BUG_SWARM) {
    with (obj_objective_manager) {
        if (_stack_index < 0 || _stack_index >= array_length(objective_stacks)) return;
        
        // Generate a special event objective
        var priority_obj = generate_objective(current_difficulty, _event_type);
        
        // Mark it as a special priority objective
        priority_obj.extra.priority = true;
        
        // Insert the new objective at the beginning of the stack (position 0)
        array_insert(objective_stacks[_stack_index], 0, priority_obj);
        
        // Set the new objective as active
        active_objectives[_stack_index] = 0;
        
        // Add animation effects to highlight the change
        stack_x_offsets[_stack_index] = random_range(-5, 5);
        stack_y_offsets[_stack_index] = random_range(-5, 5);
        current_shake = 3;
    }
}


function trigger_bug_swarm() {
    // First trigger the event itself
    trigger_event(EVENT_TYPE.BUG_SWARM);
    
    // Then add a priority objective to the first active stack
    for (var s = 0; s < array_length(obj_objective_manager.stack_unlocked); s++) {
        if (obj_objective_manager.stack_unlocked[s]) {
            add_priority_objective(s, EVENT_TYPE.BUG_SWARM);
            break; // Just add to the first unlocked stack we find
        }
    }
    
    // Apply any gameplay effects for bug swarm event
    with (obj_game_control) {
        bug_swarm_active = true;
        bug_spawn_rate = 0.2; // 20% chance per new block
    }
    
    // Show notification to player
    // show_notification("Bug Swarm!", "Bugs are infesting your factory!");
}