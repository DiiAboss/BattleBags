/// @function AIBoardController
/// @param {struct} player The player struct
/// @returns {struct} Controller struct
function AIBoardController(player) constructor {
    self.player = player;
    self.inputQueue = ds_queue_create();
    self.swap_cooldown = 0;
    self.decision_log = [];
    self.last_decision = "none";
    self.current_action = "idle";  // Current state: idle, moving, swapping
    self.target_x = -1;            // Target x position
    self.target_y = -1;            // Target y position
    self.move_timer = 0;           // Timer for movement
    self.move_delay = 8;           // Delay between moves
    self.action_delay = 20;        // Delay after reaching target before swapping
    self.swap_after_move = false;  // Whether to swap after reaching target
    self.move_history = [];        // Array to track recent moves to avoid repetition
    self.safe_moves = 0;           // Counter to track safe moves
    self.scan_timer = 0;           // Timer for board scanning
    self.scan_delay = 60;          // How often to scan the board (in frames)
    self.current_match = undefined; // Current match we're working on
    
    // Game constants - will be picked up from player/controller later
    self.top_playable_row = 4;
    self.bottom_playable_row = 20;
    self.width = 8;
    
    // Main AI thinking function
    tick = function() {
        // Wait for AI delay
        if (player.ai_delay > 0) {
            player.ai_delay--;
            return;
        }
        
        // If we have swap cooldown, decrement it
        if (self.swap_cooldown > 0) {
            self.swap_cooldown--;
            return;
        }
        
        // Don't act if player is swapping or something is falling
        if (player.swap_in_progress) {
            return;
        }
        
        // Check if any blocks are falling or if matches are being processed
        var blocks_moving = false;
        for (var col = 0; col < 8; col++) {
            for (var row = 4; row <= 20; row++) {
                if (player.grid[col, row].falling || player.grid[col, row].popping) {
                    blocks_moving = true;
                    break;
                }
            }
            if (blocks_moving) break;
        }
        
        // If blocks are moving, wait
        if (blocks_moving) {
            return;
        }
        
        // Get current position
        var curX = player.hovered_block[0];
        var curY = player.hovered_block[1];
        
        // Detect if position has unexpectedly changed (jumped)
        if (self.current_action == "moving" && 
            self.last_position_x != undefined && 
            self.last_position_y != undefined) {
            
            // Check if position changed more than 1 step
            var dx = abs(curX - self.last_position_x);
            var dy = abs(curY - self.last_position_y);
            
            if ((dx > 1 && dx < 7) || dy > 1) { 
                // Position jumped unexpectedly, reset to idle and plan new move
                self.current_action = "idle";
                self.last_decision = "POSITION JUMPED to " + string(curX) + "," + string(curY) + " - resetting";
                array_push(self.decision_log, self.last_decision);
                if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            }
        }
        
        // Store current position for next frame
        self.last_position_x = curX;
        self.last_position_y = curY;
        
        // Safety check for valid position
        if (curX < 0 || curX >= self.width || curY < self.top_playable_row || curY > self.bottom_playable_row) {
            // Reset to a safe position
            if (self.safe_moves < 3) {
                // Try moving to center
                player.hovered_block[0] = 4;
                player.hovered_block[1] = 12;
                self.safe_moves++;
                
                self.last_decision = "RESET to safe position 4,12";
                array_push(self.decision_log, self.last_decision);
                if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
                
                self.current_action = "idle";
                return;
            } else {
                // If we've tried several times, just stay where we are
                self.safe_moves = 0;
                curX = clamp(curX, 0, self.width-1);
                curY = clamp(curY, self.top_playable_row, self.bottom_playable_row);
                player.hovered_block[0] = curX;
                player.hovered_block[1] = curY;
            }
        } else {
            // We're in a valid position, reset safe moves counter
            self.safe_moves = 0;
        }
        
        // Periodically scan the board for potential matches
        self.scan_timer++;
        if (self.scan_timer >= self.scan_delay || self.current_match == undefined) {
            self.scan_timer = 0;
            scanBoardForMatches();
        }
        
        // State machine for AI behavior
        switch(self.current_action) {
            case "idle":
                // Only plan new moves if we're idle
                planNextMove();
                break;
                
            case "moving":
                // We're in the process of moving to a target
                self.move_timer++;
                
                if (self.move_timer >= self.move_delay) {
                    self.move_timer = 0;
                    
                    // Check if we've reached the target
                    if (curX == self.target_x && curY == self.target_y) {
                        // We've arrived!
                        self.last_decision = "ARRIVED at " + string(curX) + "," + string(curY);
                        array_push(self.decision_log, self.last_decision);
                        if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
                        
                        if (self.swap_after_move) {
                            self.current_action = "pre_swap";
                            self.move_timer = 0;
                        } else {
                            self.current_action = "idle";
                        }
                    } else {
                        // Take one step toward the target
                        moveOneStep();
                    }
                }
                break;
                
            case "pre_swap":
                // Wait before swapping
                self.move_timer++;
                
                if (self.move_timer >= self.action_delay) {
                    self.move_timer = 0;
                    
                    // Try to swap at current position
                    trySwap();
                    
                    // Back to idle
                    self.current_action = "idle";
                    self.swap_after_move = false;
                    
                    // Clear current match after trying it
                    self.current_match = undefined;
                }
                break;
        }
    }
    
    // Scan the board for matches
    scanBoardForMatches = function() {
        // Only scan if we don't already have a match to process
        if (self.current_match == undefined) {
            // Have the scanner search for matches
            if (player.ai_scanner.scanBoard()) {
                // Get the next match
                self.current_match = player.ai_scanner.getNextMatch();
                
                self.last_decision = "FOUND MATCH at " + string(self.current_match.x) + "," + string(self.current_match.y) + " (" + self.current_match.match_type + ")";
                array_push(self.decision_log, self.last_decision);
                if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            }
        }
    }
    
    // Plan the next move using match data if available
    planNextMove = function() {
        // Reset inputs
        player.input.Up = false;
        player.input.Down = false;
        player.input.Left = false;
        player.input.Right = false;
        
        // If we have a match to process, go to that position
        if (self.current_match != undefined) {
            self.target_x = self.current_match.x;
            self.target_y = self.current_match.y;
            
            self.last_decision = "MOVING TO MATCH at " + string(self.target_x) + "," + string(self.target_y);
            array_push(self.decision_log, self.last_decision);
            if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            
            self.current_action = "moving";
            self.move_timer = 0;
            self.swap_after_move = true;
            return;
        }
        
        // If no match is available, just randomly explore
        var pos_x = irandom_range(1, self.width - 3);  // 1-5 to avoid edges
        var pos_y = irandom_range(self.top_playable_row + 2, self.bottom_playable_row - 2); // Stay away from top/bottom
        
        self.last_decision = "EXPLORING at " + string(pos_x) + "," + string(pos_y);
        array_push(self.decision_log, self.last_decision);
        if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
        
        self.target_x = pos_x;
        self.target_y = pos_y;
        self.current_action = "moving";
        self.move_timer = 0;
        self.swap_after_move = true;
    }
    
    // Move one step toward the target
    moveOneStep = function() {
        var curX = player.hovered_block[0];
        var curY = player.hovered_block[1];
        
        // Reset all input flags
        player.input.Up = false;
        player.input.Down = false;
        player.input.Left = false;
        player.input.Right = false;
        
        // Avoid moving to edges
        if (self.target_y <= self.top_playable_row + 1) {
            self.target_y = self.top_playable_row + 2;
        }
        if (self.target_y >= self.bottom_playable_row - 1) {
            self.target_y = self.bottom_playable_row - 2;
        }
        
        // Move ONE STEP at a time - prioritize horizontal movement first
        if (curX < self.target_x) {
            // Move right
            player.input.Right = true;
        } else if (curX > self.target_x) {
            // Move left
            player.input.Left = true;
        } else if (curY < self.target_y) {
            // Move down
            player.input.Down = true;
        } else if (curY > self.target_y) {
            // Move up
            player.input.Up = true;
        }
    }
    
    // Try to swap at current position
    trySwap = function() {
        var pos_x = player.hovered_block[0];
        var pos_y = player.hovered_block[1];
        
        // Check if position is valid for a swap
        if (pos_x < 0 || pos_x >= self.width - 1 || pos_y < self.top_playable_row || pos_y > self.bottom_playable_row) return;
        
        // Check if blocks are valid for swapping
        var block1 = player.grid[pos_x, pos_y];
        var block2 = player.grid[pos_x+1, pos_y];
        
        if (block1.type >= 0 && block2.type >= 0 && 
            !block1.falling && !block2.falling &&
            !block1.popping && !block2.popping &&
            !block1.is_big && !block2.is_big) {
            
            // Log the swap
            self.last_decision = "SWAP at " + string(pos_x) + "," + string(pos_y);
            array_push(self.decision_log, self.last_decision);
            if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            
            // Perform the swap
            player.input.ActionPress = true;
            player.input.ActionKey = true;
            
            // Set cooldown
            self.swap_cooldown = 10;
        }
    }
    
    // Set difficulty level (1-5)
    set_difficulty = function(level) {
        level = clamp(level, 1, 5);
        player.ai_difficulty = level;
        
        // Adjust AI parameters based on difficulty
        switch(level) {
            case 1: // Easy
                player.ai_max_delay = 15;
                self.move_delay = 12;
                self.action_delay = 24;
                self.scan_delay = 120; // Scan less frequently at easy difficulty
                break;
            case 2: // Medium
                player.ai_max_delay = 10;
                self.move_delay = 10;
                self.action_delay = 20;
                self.scan_delay = 90;
                break;
            case 3: // Hard
                player.ai_max_delay = 8;
                self.move_delay = 8;
                self.action_delay = 16;
                self.scan_delay = 60;
                break;
            case 4: // Expert
                player.ai_max_delay = 6;
                self.move_delay = 6;
                self.action_delay = 12;
                self.scan_delay = 45;
                break;
            case 5: // Master
                player.ai_max_delay = 4;
                self.move_delay = 4;
                self.action_delay = 8;
                self.scan_delay = 30; // Scan very frequently at master difficulty
                break;
        }
    }
    
    // Clean up data structures
    cleanup = function() {
        ds_queue_destroy(inputQueue);
    }
}






//
///// @function AIBoardController
///// @param {struct} player The player struct
///// @returns {struct} Controller struct
//function AIBoardController(player) constructor {
    //self.player = player;
    //self.scanner = player.ai_scanner;
    //self.inputQueue = ds_queue_create();
    //self.swap_cooldown = 0;
    //self.decision_log = [];
    //self.last_decision = "none";
    //self.frames_since_last_match = 0;
    //self.current_action = "idle";  // Current state: idle, moving, swapping
    //self.target_x = -1;            // Target x position
    //self.target_y = -1;            // Target y position
    //self.move_timer = 0;           // Timer for movement
    //self.move_delay = 8;           // Delay between moves
    //self.action_delay = 20;        // Delay after reaching target before swapping
    //self.swap_after_move = false;  // Whether to swap after reaching target
    //self.optimal_choice_chance = 1.0; // Chance to make optimal decisions (adjusted by difficulty)
    //self.move_history = [];        // Array to track recent moves to avoid repetition
    //self.last_move_time = 0;       // Time since last move to avoid getting stuck
    //self.consecutive_bad_moves = 0; // Counter for consecutive moves that didn't result in matches
    //
    //// Main AI thinking function
    //tick = function() {
        //// Wait for AI delay
        //if (player.ai_delay > 0) {
            //player.ai_delay--;
            //return;
        //}
        //
        //// If we have swap cooldown, decrement it
        //if (self.swap_cooldown > 0) {
            //self.swap_cooldown--;
            //return;
        //}
        //
        //// Don't act if player is swapping or something is falling
        //if (player.swap_in_progress) {
            //return;
        //}
        //
        //// Get current position
        //var curX = player.hovered_block[0];
        //var curY = player.hovered_block[1];
        //
        //// Ensure we're in a valid position
        //if (curX < 0 || curX > 7 || curY < 4 || curY > 20) {
            //// Reset to a safe position if out of bounds
            //player.hovered_block[0] = 4;
            //player.hovered_block[1] = 12;
            //curX = 4;
            //curY = 12;
            //self.current_action = "idle";
            //self.target_x = -1;
            //self.target_y = -1;
            //return;
        //}
        //
        //// Increment time since last move to avoid getting stuck
        //self.last_move_time++;
        //
        //// If we're stuck for too long, force a reset
        //if (self.last_move_time > 120) {
            //self.current_action = "idle";
            //self.last_move_time = 0;
            //self.consecutive_bad_moves++;
        //}
        //
        //// State machine for AI behavior
        //switch(self.current_action) {
            //case "idle":
                //// Only plan new moves if we're idle
                //thinkAndPlan();
                //break;
                //
            //case "moving":
                //// We're in the process of moving to a target
                //self.move_timer++;
                //
                //if (self.move_timer >= self.move_delay) {
                    //self.move_timer = 0;
                    //
                    //// Check if we've reached the target
                    //if (curX == self.target_x && curY == self.target_y) {
                        //// We've arrived!
                        //self.last_decision = "ARRIVED at " + string(curX) + "," + string(curY);
                        //array_push(self.decision_log, self.last_decision);
                        //if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
                        //
                        //if (self.swap_after_move) {
                            //self.current_action = "pre_swap";
                            //self.move_timer = 0;
                        //} else {
                            //self.current_action = "idle";
                        //}
                        //
                        //// Reset the stuck counter
                        //self.last_move_time = 0;
                    //} else {
                        //// Take one step toward the target
                        //moveOneStep();
                    //}
                //}
                //break;
                //
            //case "pre_swap":
                //// Wait before swapping
                //self.move_timer++;
                //
                //if (self.move_timer >= self.action_delay) {
                    //self.move_timer = 0;
                    //
                    //// Try to swap at current position
                    //trySwap();
                    //
                    //// Back to idle
                    //self.current_action = "idle";
                    //self.swap_after_move = false;
                //}
                //break;
        //}
    //}
    //
    //// Think and plan the next move using enhanced decision making
    //thinkAndPlan = function() {
        //// Reset inputs
        //player.input.Up = false;
        //player.input.Down = false;
        //player.input.Left = false;
        //player.input.Right = false;
        //
        //// Check if any blocks are falling or if matches are being processed
        //var blocks_moving = false;
        //for (var col = 0; col < 8; col++) {
            //for (var row = 4; row <= 20; row++) {
                //if (player.grid[col, row].falling || player.grid[col, row].popping) {
                    //blocks_moving = true;
                    //break;
                //}
            //}
            //if (blocks_moving) break;
        //}
        //
        //// If blocks are moving, wait
        //if (blocks_moving) {
            //self.frames_since_last_match = 0;
            //return;
        //}
        //
        //// Occasionally make a sub-optimal move based on difficulty level
        //if (random(1.0) > self.optimal_choice_chance) {
            //// Make a sub-optimal move sometimes based on difficulty
            //var pos_x = irandom(6);
            //var pos_y = irandom_range(8, 18);
            //
            //self.last_decision = "SUB-OPTIMAL MOVE at " + string(pos_x) + "," + string(pos_y);
            //array_push(self.decision_log, self.last_decision);
            //if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            //
            //startMoveTo(pos_x, pos_y, true);
            //return;
        //}
        //
        //// Priority 0: If we've made too many bad moves, try a more random approach to break out of patterns
        //if (self.consecutive_bad_moves > 5) {
            //var pos_x = irandom(6);
            //var pos_y = irandom_range(4, 20);
            //
            //self.last_decision = "PATTERN BREAK after " + string(self.consecutive_bad_moves) + " bad moves";
            //array_push(self.decision_log, self.last_decision);
            //if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            //
            //startMoveTo(pos_x, pos_y, true);
            //self.consecutive_bad_moves = 0;
            //return;
        //}
        //
        //// Priority 1: Use look-ahead for best move (at higher difficulties)
        //if (player.ai_difficulty >= 3) { // Only for Hard and above
            //var bestMove = findBestMove();
            //
            //if (bestMove.found) {
                //self.last_decision = "PRIORITY 1: BEST MOVE ANALYSIS at " + string(bestMove.pos_x) + "," + string(bestMove.pos_y);
                //array_push(self.decision_log, self.last_decision);
                //if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
                //
                //startMoveTo(bestMove.pos_x, bestMove.pos_y, true);
                //self.frames_since_last_match = 0;
                //return;
            //}
        //}
        //
        //// Priority 2: Find direct swap matches
        //var swapMatch = findDirectSwapMatch();
        //if (swapMatch.found) {
            //self.last_decision = "PRIORITY 2: DIRECT MATCH at " + string(swapMatch.pos_x) + "," + string(swapMatch.pos_y);
            //array_push(self.decision_log, self.last_decision);
            //if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            //
            //startMoveTo(swapMatch.pos_x, swapMatch.pos_y, true);
            //self.frames_since_last_match = 0;
            //return;
        //}
        //
        //// Priority 3: Look for chain reactions
        //var chainMove = scanner.findChainReaction();
        //if (chainMove.found) {
            //self.last_decision = "PRIORITY 3: CHAIN REACTION at " + string(chainMove.pos_x) + "," + string(chainMove.pos_y);
            //array_push(self.decision_log, self.last_decision);
            //if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            //
            //startMoveTo(chainMove.pos_x, chainMove.pos_y, true);
            //self.frames_since_last_match = 0;
            //return;
        //}
        //
        //// Priority 4: Find potential vertical matches
        //var potentialMatch = scanner.findPotentialVerticalMatch();
        //if (potentialMatch.found) {
            //self.last_decision = "PRIORITY 4: POTENTIAL MATCH at " + string(potentialMatch.pos_x) + "," + string(potentialMatch.pos_y);
            //array_push(self.decision_log, self.last_decision);
            //if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            //
            //startMoveTo(potentialMatch.pos_x, potentialMatch.pos_y, true);
            //self.frames_since_last_match = 0;
            //return;
        //}
        //
        //// Priority 5: Find horizontal match potentials
        //var hMatchPotential = scanner.findHorizontalMatchPotential();
        //if (hMatchPotential.found) {
            //self.last_decision = "PRIORITY 5: H-MATCH POTENTIAL from " + string(hMatchPotential.from_x) + "," + string(hMatchPotential.from_y);
            //array_push(self.decision_log, self.last_decision);
            //if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            //
            //startMoveTo(hMatchPotential.from_x, hMatchPotential.from_y, true);
            //self.frames_since_last_match = 0;
            //return;
        //}
        //
        //// Priority 6: Find moves that create cascades (flatten the stack)
        //var flattenMove = scanner.findStackFlatteningMove();
        //if (flattenMove.pos_x != flattenMove.dx) { // Check if a valid move was found
            //self.last_decision = "PRIORITY 6: FLATTEN STACK at " + string(flattenMove.pos_x) + "," + string(flattenMove.pos_y);
            //array_push(self.decision_log, self.last_decision);
            //if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            //
            //startMoveTo(flattenMove.pos_x, flattenMove.pos_y, true);
            //self.frames_since_last_match = 0;
            //return;
        //}
        //
        //// If nothing found, increment search counter
        //self.frames_since_last_match++;
        //
        //// If we've searched for a while without finding anything, try random moves
        //if (self.frames_since_last_match > 60) {
            //// Select a somewhat reasonable position for a random swap
            //var pos_x = irandom(6); // Keep within bounds for swap
            //var pos_y = irandom_range(10, 16); // Middle of the board
            //
            //self.last_decision = "RANDOM MOVE at " + string(pos_x) + "," + string(pos_y);
            //array_push(self.decision_log, self.last_decision);
            //if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            //
            //startMoveTo(pos_x, pos_y, true);
            //self.consecutive_bad_moves++;
            //return;
        //}
        //
        //// Otherwise, scan another area
        //var pos_x = irandom(6);
        //var pos_y = irandom_range(8, 16);
        //
        //self.last_decision = "EXPLORING at " + string(pos_x) + "," + string(pos_y);
        //array_push(self.decision_log, self.last_decision);
        //if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
        //
        //startMoveTo(pos_x, pos_y, false);
    //}
    //
    //// Start moving to a target position
    //startMoveTo = function(pos_x, pos_y, swap_after) {
        //// Ensure target is within valid range
        //self.target_x = clamp(pos_x, 0, 7);
        //self.target_y = clamp(pos_y, 4, 20);
        //
        //// Check for potential move repetition
        //var moveAlreadyMade = false;
        //for (var i = 0; i < array_length(self.move_history); i++) {
            //var move = self.move_history[i];
            //if (move.x == self.target_x && move.y == self.target_y && move.swap == swap_after) {
                //moveAlreadyMade = true;
                //break;
            //}
        //}
        //
        //// If we're repeating moves too much, try a slightly different position
        //if (moveAlreadyMade && random(1.0) < 0.7) {
            //self.target_x = clamp(self.target_x + irandom_range(-1, 1), 0, 7);
            //self.target_y = clamp(self.target_y + irandom_range(-1, 1), 4, 20);
            //self.last_decision += " (MODIFIED to avoid repetition)";
        //}
        //
        //// Add this move to history
        //var newMove = {x: self.target_x, y: self.target_y, swap: swap_after};
        //array_push(self.move_history, newMove);
        //
        //// Keep history at a reasonable size
        //if (array_length(self.move_history) > 10) {
            //array_delete(self.move_history, 0, 1);
        //}
        //
        //// Log the decision
        //self.last_decision = "PLANNING MOVE to " + string(self.target_x) + "," + string(self.target_y);
        //array_push(self.decision_log, self.last_decision);
        //if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
        //
        //// Set flags for movement
        //self.current_action = "moving";
        //self.move_timer = 0;
        //self.swap_after_move = swap_after;
    //}
    //
    //// Move one step toward the target
    //moveOneStep = function() {
        //var curX = player.hovered_block[0];
        //var curY = player.hovered_block[1];
        //
        //// Reset all input flags
        //player.input.Up = false;
        //player.input.Down = false;
        //player.input.Left = false;
        //player.input.Right = false;
        //
        //// Move ONE STEP at a time - prioritize horizontal movement first
        //if (curX < self.target_x) {
            //// Move right
            //player.input.Right = true;
        //} else if (curX > self.target_x) {
            //// Move left
            //player.input.Left = true;
        //} else if (curY < self.target_y) {
            //// Move down
            //player.input.Down = true;
        //} else if (curY > self.target_y) {
            //// Move up
            //player.input.Up = true;
        //}
    //}
    //
    //// Try to swap at current position
    //trySwap = function() {
        //var pos_x = player.hovered_block[0];
        //var pos_y = player.hovered_block[1];
        //
        //// Only swap if we have a valid block selected and one to the right
        //if (pos_x < 7) {
            //if (player.grid[pos_x, pos_y].type != BLOCK.NONE && 
                //player.grid[pos_x+1, pos_y].type != BLOCK.NONE && 
                //!player.grid[pos_x, pos_y].is_big && 
                //!player.grid[pos_x+1, pos_y].is_big &&
                //!player.grid[pos_x, pos_y].falling &&
                //!player.grid[pos_x+1, pos_y].falling &&
                //!player.grid[pos_x, pos_y].popping &&
                //!player.grid[pos_x+1, pos_y].popping) {
                //
                //// Log the swap
                //self.last_decision = "SWAP at " + string(pos_x) + "," + string(pos_y);
                //array_push(self.decision_log, self.last_decision);
                //if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
                //
                //// Perform the swap
                //player.input.ActionPress = true;
                //player.input.ActionKey = true;
                //
                //// Set cooldown
                //self.swap_cooldown = 10;
                //self.frames_since_last_match = 0;
            //}
        //}
    //}
    //
    //// Find adjacent blocks that when swapped create an immediate match
    //findDirectSwapMatch = function() {
        //var grid = player.grid;
        //var min_row = 4;
        //var max_row = 20;
        //var result = { found: false, pos_x: 0, pos_y: 0 };
        //
        //// Check all valid positions for potential swaps
        //for (var row = min_row; row <= max_row; row++) {
            //for (var col = 0; col < 7; col++) { // Only check positions with a block to the right
                //var block1 = grid[col, row];
                //var block2 = grid[col+1, row];
                //
                //// Skip if either block can't be swapped
                //if (block1.type < 0 || block2.type < 0 || 
                    //block1.falling || block2.falling ||
                    //block1.popping || block2.popping ||
                    //block1.is_big || block2.is_big) {
                    //continue;
                //}
                //
                //// Test swap these blocks
                //var tempType = block1.type;
                //block1.type = block2.type;
                //block2.type = tempType;
                //
                //// Check for matches after swapping
                //var matchFound = false;
                //
                //// Check for vertical match for first block
                //if (row >= min_row + 2) {
                    //if (block1.type == grid[col, row-1].type && block1.type == grid[col, row-2].type) {
                        //matchFound = true;
                    //}
                //}
                //
                //if (row <= max_row - 2) {
                    //if (block1.type == grid[col, row+1].type && block1.type == grid[col, row+2].type) {
                        //matchFound = true;
                    //}
                //}
                //
                //if (row >= min_row + 1 && row <= max_row - 1) {
                    //if (block1.type == grid[col, row-1].type && block1.type == grid[col, row+1].type) {
                        //matchFound = true;
                    //}
                //}
                //
                //// Check for vertical match for second block
                //if (row >= min_row + 2) {
                    //if (block2.type == grid[col+1, row-1].type && block2.type == grid[col+1, row-2].type) {
                        //matchFound = true;
                    //}
                //}
                //
                //if (row <= max_row - 2) {
                    //if (block2.type == grid[col+1, row+1].type && block2.type == grid[col+1, row+2].type) {
                        //matchFound = true;
                    //}
                //}
                //
                //if (row >= min_row + 1 && row <= max_row - 1) {
                    //if (block2.type == grid[col+1, row-1].type && block2.type == grid[col+1, row+1].type) {
                        //matchFound = true;
                    //}
                //}
                //
                //// Check for horizontal matches
                //// For first block
                //if (col >= 2) {
                    //if (block1.type == grid[col-1, row].type && block1.type == grid[col-2, row].type) {
                        //matchFound = true;
                    //}
                //}
                //
                //if (col >= 1 && col+1 < 7) {
                    //if (block1.type == grid[col-1, row].type && block1.type == grid[col+2, row].type) {
                        //matchFound = true;
                    //}
                //}
                //
                //// For second block
                //if (col+1 <= 5) {
                    //if (block2.type == grid[col+2, row].type && block2.type == grid[col+3, row].type) {
                        //matchFound = true;
                    //}
                //}
                //
                //// Restore original block types
                //block1.type = block2.type;
                //block2.type = tempType;
                //
                //if (matchFound) {
                    //result.found = true;
                    //result.pos_x = col;
                    //result.pos_y = row;
                    //
                    //// Prioritize based on row height (lower is better)
                    //if (random(1.0) < 0.7) {
                        //return result; // Return immediately in most cases
                    //}
                //}
            //}
        //}
        //
        //return result;
    //}
    //
    //// Find the best move using board evaluation
    //findBestMove = function() {
        //var bestScore = -9999;
        //var bestMove = { found: false, pos_x: 0, pos_y: 0 };
        //
        //// Try all possible horizontal swaps and evaluate
        //for (var col = 0; col < 7; col++) {
            //for (var row = 4; row <= 20; row++) {
                //var block1 = player.grid[col, row];
                //var block2 = player.grid[col+1, row];
                //
                //// Skip invalid blocks
                //if (block1.type < 0 || block2.type < 0 || 
                    //block1.falling || block2.falling ||
                    //block1.popping || block2.popping ||
                    //block1.is_big || block2.is_big) {
                    //continue;
                //}
                //
                //// Temporarily swap
                //var tempType = block1.type;
                //block1.type = block2.type;
                //block2.type = tempType;
                //
                //// Evaluate this board state
                //var _score = scanner.evaluateBoard();
                //
                //// Bonus for lower rows (better for clearing)
                //_score += (row / 20) * 20;
                //
                //// Bonus for central columns (more flexible)
                //_score += (1 - abs(col - 3.5) / 3.5) * 15;
                //
                //// Check if this is the best move so far
                //if (_score > bestScore) {
                    //bestScore = _score;
                    //bestMove.found = true;
                    //bestMove.pos_x = col;
                    //bestMove.pos_y = row;
                //}
                //
                //// Undo swap
                //block1.type = block2.type;
                //block2.type = tempType;
            //}
        //}
        //
        //// Only consider it "found" if the score is actually good
        //if (bestScore <= 0) {
            //bestMove.found = false;
        //}
        //
        //return bestMove;
    //}
    //
    //// Set difficulty level (1-5)
    //set_difficulty = function(level) {
        //level = clamp(level, 1, 5);
        //player.ai_difficulty = level;
        //
        //// Adjust AI parameters based on difficulty
        //switch(level) {
            //case 1: // Easy
                //player.ai_max_delay = 15;
                //self.move_delay = 12;
                //self.action_delay = 24;
                //// Easy AI randomly chooses suboptimal moves 50% of the time
                //self.optimal_choice_chance = 0.5;
                //break;
            //case 2: // Medium
                //player.ai_max_delay = 10;
                //self.move_delay = 10;
                //self.action_delay = 20;
                //// Medium AI chooses optimal moves 70% of the time
                //self.optimal_choice_chance = 0.7;
                //break;
            //case 3: // Hard
                //player.ai_max_delay = 8;
                //self.move_delay = 8;
                //self.action_delay = 16;
                //// Hard AI chooses optimal moves 85% of the time
                //self.optimal_choice_chance = 0.85;
                //break;
            //case 4: // Expert
                //player.ai_max_delay = 6;
                //self.move_delay = 6;
                //self.action_delay = 12;
                //// Expert AI chooses optimal moves 95% of the time
                //self.optimal_choice_chance = 0.95;
                //break;
            //case 5: // Master
                //player.ai_max_delay = 4;
                //self.move_delay = 4;
                //self.action_delay = 8;
                //// Master AI always chooses optimal moves
                //self.optimal_choice_chance = 1.0;
                //break;
        //}
    //}
    //
    //// Clean up data structures
    //cleanup = function() {
        //ds_queue_destroy(inputQueue);
    //}
//}
//