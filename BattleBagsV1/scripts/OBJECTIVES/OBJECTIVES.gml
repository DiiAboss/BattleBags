// Script Created By DiiAboss AKA Dillon Abotossaway
enum OBJECTIVE_TYPE {
    BREAK_COLOR,
    GET_COMBO,
    MATCH_SIZE,
    CLEAR_LINES
}

function Objective(_type, _target, _data = undefined, _reward = undefined) constructor {
    type = _type;        // Objective type
    target = _target;    // Target number to achieve
    progress = 0;        // Current progress
    data = _data;        // Optional extra data (e.g., color)
    reward = _reward;    // Reward for completion
    completed = false;   // Status of completion

    // Check if completed
    check_completion = function() {
        if (progress >= target && !completed) {
            completed = true;
            trigger_reward();
        }
    };

    // Trigger reward when completed
    trigger_reward = function() {
        if (!is_undefined(reward)) {
            reward();
        }
    };
}


function objective_progress(type, data = undefined, amount = 1) {
    with (obj_objective_manager) {
        for (var i = 0; i < array_length(objectives); i++) {
            var obj = objectives[i];
            
            if (!obj.completed && obj.type == type && (is_undefined(data) || obj.data == data)) {
                if (obj.type == OBJECTIVE_TYPE.MATCH_SIZE || obj.type == OBJECTIVE_TYPE.GET_COMBO)
                {
                        obj.progress = amount;
                    
                }
                else {
                    obj.progress += amount;
                }
                
                
                obj.check_completion();
            }
        }
    }
}


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
        default: return "Random";
    }
}

function add_objective(_objective) {
    array_push(objectives, _objective);
}