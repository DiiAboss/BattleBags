// ========= CREATE EVENT =========
/// @description Initialize objective manager
// Core variables
objective_stacks = [[]];                // Array of objective stack arrays
active_objectives = [0];                // Index of active objective in each stack
stack_unlocked = [true];                // Which stacks are unlocked
unlocked_stack_count = 1;               // Number of stacks unlocked
max_stacks = 3;                         // Maximum number of stacks (excluding event stacks)
completed_objectives = 0;               // Total objectives completed
total_ep_gained = 0;                    // Total EP gained from objectives
current_difficulty = OBJECTIVE_LEVEL.LEVEL_1; // Current difficulty level
game_control = obj_game_control;        // Reference to game controller

// Stack update tracking
stack_needs_update = [false];           // Which stacks need to update
update_stack_timer = [0];               // Timers for stack updates (for animation)
stack_update_delay = 1000;              // Delay after completion before advancing (ms)

// Animation and UI variables
objective_spacing = 24;                 // Spacing for drawing objectives
panel_width = 260;                      // Width of objective panels
panel_height = 140;                     // Base height of panels
panel_padding = 10;                     // Padding inside panels
stack_spacing = 280;                    // Horizontal spacing between stacks
objective_base_x = 32;                  // Base X position
objective_base_y = 120;                 // Base Y position
current_shake = 0;                      // For screen shake effects
stack_x_offsets = [0];                  // Animation offsets for stacks
stack_y_offsets = [0];                  // Animation offsets for stacks

// Event system variables
current_event = EVENT_TYPE.NONE;        // Current active event
event_start_time = 0;                   // When event started
event_duration = 60 * 1000;             // Default event duration (60 seconds)
event_objectives = [];                  // Current event objectives
show_bonus_notification = false;        // Whether to show bonus EP notification
bonus_notification_time = 0;            // When bonus was awarded
bonus_ep = 0;                           // Amount of bonus EP awarded

// Initialize first stack with level 1 objectives
fill_objective_stack(0, OBJECTIVE_LEVEL.LEVEL_1, 3);