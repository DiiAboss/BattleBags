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
    // At the top with your other variables
    self.match_attempts = 0; // Counter for tracking how many times we've tried a specific match
    self.recent_positions = ds_list_create();  // Track recent positions
   self.recent_position_limit = 5;  // How many recent positions to remember
   self.swap_variety_counter = 0;  // Track number of consecutive swaps at same position
    self.committed_to_match = false;
    self.commitment_target_x = -1;
    self.commitment_target_y = -1;
    
    self.failed_matches = ds_map_create();
    self.failed_match_limit = 3; // How many times to try before blacklisting
    self.cleanup_timer = 0;
    
    // Game constants - will be picked up from player/controller later
    self.top_playable_row = 4;
    self.bottom_playable_row = 20;
    self.width = 8;
    
    self.topmost_row = 0;
    
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
        //if (player.swap_in_progress) {
            //return;
        //}
        
        self.topmost_row = player.topmost_row;
        
        //// Check if any blocks are falling or if matches are being processed
        //var blocks_moving = false;
        //for (var col = 0; col < 8; col++) {
            //for (var row = 4; row <= 20; row++) {
                //if (player.grid[col, row].falling || player.grid[col, row].popping) {
                    //blocks_moving = true;
                    ////break;
                //}
            //}
            ////if (blocks_moving) break;
        //}
        
        // If blocks are moving, wait
        //if (blocks_moving) {
            //return;
        //}
        
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
            
            //if ((dx > 1 && dx < 7) || dy > 1) { 
                //// Position jumped unexpectedly, reset to idle and plan new move
                //self.current_action = "idle";
                //self.last_decision = "POSITION JUMPED to " + string(curX) + "," + string(curY) + " - resetting";
                //array_push(self.decision_log, self.last_decision);
                //if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            //}
        }
        
        // Store current position for next frame
        self.last_position_x = curX;
        self.last_position_y = curY;
        
        // Safety check for valid position
        if (curX < 0 || curX > self.width - 1 || curY < self.top_playable_row || curY > self.bottom_playable_row) {
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
                curY = clamp(curY, self.topmost_row, self.bottom_playable_row);
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
        
        
        self.cleanup_timer++;
        if (self.cleanup_timer > 300) { // Every 5 seconds at 60 FPS
            self.cleanup_timer = 0;
            
            // Clear out the failed matches map
            ds_map_clear(self.failed_matches);
            self.last_decision = "CLEARNING match blacklist due to shifting board";
            array_push(self.decision_log, self.last_decision);
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
                
                self.last_decision = "sbfm: FOUND MATCH at " + string(self.current_match.x) + "," + string(self.current_match.y) + " (" + self.current_match.match_type + ")";
                array_push(self.decision_log, self.last_decision);
                if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            }
        }
    }
    
    
    
    planNextMove = function() {
        // Reset inputs
        player.input.Up = false;
        player.input.Down = false;
        player.input.Left = false;
        player.input.Right = false;
        
        // Scan for matches (this will populate the match queue)
        scanBoardForMatches();
        
        // Look for a match near the current position first
        var curX = player.hovered_block[0];
        var curY = player.hovered_block[1];
        var nearbyMatch = undefined;//findNearbyMatch(curX, curY, 10); // Search within 2 blocks
        
        //if (nearbyMatch != undefined) {
            //// Use the nearby match instead of the best overall match
            //self.current_match = nearbyMatch;
            //
            //self.last_decision = "USING NEARBY MATCH at " + string(self.current_match.x) + "," + string(self.current_match.y);
            //array_push(self.decision_log, self.last_decision);
            //if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
        //} else if (self.current_match == undefined) {
            //// If no nearby match and no current match, get the best match from the queue
            //self.current_match = player.ai_scanner.getNextMatch();
        //}
        
        // If we have a match, go to it
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
        
        
        
        
        randomize();
        // If no match is available, randomly explore
        var pos_x = irandom_range(0, self.width - 2);
        var pos_y = irandom_range(self.topmost_row, self.bottom_playable_row - 4);
        if (irandom(10) < 3) player.input.ActionPress = true;
        random_set_seed(player.random_seed);
        
        
        
        
        
        
        self.last_decision = "EXPLORING at " + string(pos_x) + "," + string(pos_y);
        array_push(self.decision_log, self.last_decision);
        if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
        
        self.target_x = pos_x;
        self.target_y = pos_y;
        self.current_action = "moving";
        self.move_timer = 0;
        self.swap_after_move = true;
    }
    
    // Add this helper function to find matches near the current position
    // Add this to your findNearbyMatch function
    findNearbyMatch = function(centerX, centerY, radius) {
        // Create a temporary queue to store matches while we search
        var tempQueue = ds_queue_create();
        var nearbyMatch = undefined;
        var bestScore = -1;
        
        // Track which positions we've examined recently
        static lastMatchPositions = [];
        static lastMatchAttempts = 0;
        
        // Get all matches from the scanner's queue
        while (!ds_queue_empty(player.ai_scanner.match_queue)) {
            var match = ds_queue_dequeue(player.ai_scanner.match_queue);
            
            // Check if this is a match we've recently tried multiple times
            var positionKey = string(match.x) + "," + string(match.y);
            var isRepeatedMatch = false;
            
            for (var i = 0; i < array_length(lastMatchPositions); i++) {
                if (lastMatchPositions[i] == positionKey) {
                    isRepeatedMatch = true;
                    break;
                }
            }
            
            // Calculate Manhattan distance to this match
            var distance = abs(match.x - centerX) + abs(match.y - centerY);
            
            // Prioritize matches within radius and with good scores, but avoid repeated matches
            if (distance <= radius && !isRepeatedMatch) {
                // Give a bonus to nearby matches
                match.score += (radius - distance + 1) * 5; // Reduced from 10 to make it less sticky
                
                // Track the best nearby match
                if (nearbyMatch == undefined || match.score > bestScore) {
                    nearbyMatch = match;
                    bestScore = match.score;
                }
            }
            
            // Save all matches in our temp queue
            ds_queue_enqueue(tempQueue, match);
        }
        
        // Restore all matches to the original queue
        while (!ds_queue_empty(tempQueue)) {
            var match = ds_queue_dequeue(tempQueue);
            ds_queue_enqueue(player.ai_scanner.match_queue, match);
        }
        
        // Clean up
        ds_queue_destroy(tempQueue);
        
        // Record this match position if we found one
        if (nearbyMatch != undefined) {
            var positionKey = string(nearbyMatch.x) + "," + string(nearbyMatch.y);
            
            // Check if it's a match we've tried before
            var matchExists = false;
            for (var i = 0; i < array_length(lastMatchPositions); i++) {
                if (lastMatchPositions[i] == positionKey) {
                    lastMatchAttempts++;
                    matchExists = true;
                    break;
                }
            }
            
            if (!matchExists) {
                // Add to position history
                array_push(lastMatchPositions, positionKey);
                if (array_length(lastMatchPositions) > 5) {
                    array_delete(lastMatchPositions, 0, 1); // Keep only the 5 most recent
                }
                lastMatchAttempts = 1;
            }
            
            // If we've tried the same position too many times, force exploration
            if (lastMatchAttempts > 3) {
                self.last_decision = "ABANDONING repeated match at " + positionKey + " after " + string(lastMatchAttempts) + " attempts";
                array_push(self.decision_log, self.last_decision);
                if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
                
                // Clear the repetition counter
                lastMatchAttempts = 0;
                
                // Return no match to force exploration
                return undefined;
            }
        }
        
        return nearbyMatch;
    }
    
    
    
    exploreStrategically = function() {
        // For higher difficulties, use strategic exploration
        if (player.ai_difficulty >= 3) {
            
            var check_edges = irandom(10) < 3; // 30% chance to check edges
            
            if (check_edges) {
                // Choose one of the edge columns to explore
                var edge_choice = irandom(1);
                var explore_col = edge_choice == 0 ? 0 : self.width - 1;
                var explore_row = irandom_range(self.topmost_row, self.bottom_playable_row - 2);
                
                self.target_x = explore_col;
                self.target_y = explore_row;
                
                self.last_decision = "EXPLORING EDGE at " + string(explore_col) + "," + string(explore_row);
                array_push(self.decision_log, self.last_decision);
                if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            } else {
            
               // Find the tallest column and go there
               var tallest_col = -1;
               var max_height = 0;
               var second_tallest_col = -1;
               var second_max_height = 0;
               
               for (var col = 0; col < self.width; col++) {
                   var height = 0;
                   for (var row = self.topmost_row; row <= self.bottom_playable_row; row++) {
                       if (player.grid[col, row].type != BLOCK.NONE) {
                           height = self.bottom_playable_row - row + 1;
                           break;
                       }
                   }
                   
                   if (height > max_height) {
                       second_tallest_col = tallest_col;
                       second_max_height = max_height;
                       max_height = height;
                       tallest_col = col;
                   } else if (height > second_max_height) {
                       second_max_height = height;
                       second_tallest_col = col;
                   }
               }
               
               // Check if we're stuck in a loop
               if (tallest_col >= 0) {
                   var target_row = self.bottom_playable_row - max_height + 1;
                   target_row = max(target_row, self.topmost_row + 1);
                   
                   // Generate position key
                   var pos_key = string(tallest_col) + "," + string(target_row);
                   
                   // Check if this position is in our recent list
                   var position_is_recent = false;
                   for (var i = 0; i < ds_list_size(self.recent_positions); i++) {
                       if (ds_list_find_value(self.recent_positions, i) == pos_key) {
                           position_is_recent = true;
                           break;
                       }
                   }
                   
                   // If we've visited this position recently, try something else
                   if (position_is_recent && self.swap_variety_counter > 2) {
                       // Try the second tallest column instead
                       if (second_tallest_col >= 0) {
                           tallest_col = second_tallest_col;
                           target_row = self.bottom_playable_row - second_max_height + 1;
                           target_row = max(target_row, self.topmost_row);
                           self.swap_variety_counter = 0;
                       } else {
                           // Or try a random position in middle of the board
                           tallest_col = irandom_range(0, self.width - 1);
                           target_row = irandom_range(self.topmost_row, self.bottom_playable_row);
                           self.swap_variety_counter = 0;
                       }
                   } else if (position_is_recent) {
                       // Same position, but try a different row of the tall column
                       target_row = target_row + 1;
                       if (target_row > self.bottom_playable_row - 1) {
                           target_row = self.topmost_row;
                       }
                       self.swap_variety_counter++;
                   } else {
                       // New position, reset counter
                       self.swap_variety_counter = 0;
                   }
                   
                   // Update target
                   self.target_x = tallest_col;
                   self.target_y = target_row;
                   
                   // Add to recent positions
                   ds_list_add(self.recent_positions, string(self.target_x) + "," + string(self.target_y));
                   if (ds_list_size(self.recent_positions) > self.recent_position_limit) {
                       ds_list_delete(self.recent_positions, 0);
                   }
                   
                   self.last_decision = "EXAMINING TALL COLUMN at " + string(self.target_x) + "," + string(self.target_y);
                   array_push(self.decision_log, self.last_decision);
                   if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
               } else {
                   // Fall back to semi-random exploration
                   strategicRandomExplore();
               }
            }
           } else {
               // Lower difficulties just use random exploration
               strategicRandomExplore();
           }
           
           self.current_action = "moving";
           self.move_timer = 0;
           self.swap_after_move = true;
       }
    
    
    
    
    // Make sure to clean up the list in your cleanup function
    cleanup = function() {
        ds_queue_destroy(inputQueue);
        ds_list_destroy(recent_positions);
    }
    
    
    
    
    // More strategic random exploration
    strategicRandomExplore = function() {
        // Focus on the middle rows where most matches happen
        var mid_range = floor((self.bottom_playable_row - self.topmost_row) * 0.6);
        var pos_x = irandom_range(0, self.width - 1);
        var pos_y = irandom_range(self.topmost_row, self.topmost_row + mid_range);
        
        self.last_decision = "EXPLORING at " + string(pos_x) + "," + string(pos_y);
        array_push(self.decision_log, self.last_decision);
        if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
        
        self.target_x = pos_x;
        self.target_y = pos_y;
    }
    
    
    
    // Move one step toward the target
    // Add path planning to moveOneStep
    moveOneStep = function() {
        var curX = player.hovered_block[0];
        var curY = player.hovered_block[1];
        
        // Reset all input flags
        player.input.Up = false;
        player.input.Down = false;
        player.input.Left = false;
        player.input.Right = false;
        
        // Safety bounds checking
        if (self.target_y <= self.topmost_row + 1) {
            self.target_y = self.topmost_row + 1;
        }
        if (self.target_y >= self.bottom_playable_row) {
            self.target_y = self.bottom_playable_row;
        }
        
        // For higher difficulties, use more direct pathing
        if (player.ai_difficulty >= 4) {
            // Calculate Manhattan distance in both directions
            var dx = self.target_x - curX;
            var dy = self.target_y - curY;
            
            // Choose the optimal direction based on which one gets us closer
            if (abs(dx) >= abs(dy) && dx != 0) {
                // Move horizontally first if that's the longer dimension
                if (dx > 0) player.input.Right = true;
                else player.input.Left = true;
            } else if (dy != 0) {
                // Move vertically if that's the longer dimension
                if (dy > 0) player.input.Down = true;
                else player.input.Up = true;
            }
        } else {
            // Lower difficulties use simpler movement (existing code)
            if (curX < self.target_x) {
                player.input.Right = true;
            } else if (curX > self.target_x) {
                player.input.Left = true;
            } else if (curY < self.target_y) {
                player.input.Down = true;
            } else if (curY > self.target_y) {
                player.input.Up = true;
            }
        }
    }
    
    
    
    trySwap = function() {
        var pos_x = player.hovered_block[0];
        var pos_y = player.hovered_block[1];
        
        // Check if position is valid for a swap
        if (pos_x < 0 || pos_x > self.width - 1 || pos_y < self.top_playable_row || pos_y > self.bottom_playable_row) return;
        
        // Check if blocks are valid for swapping
        var block1 = player.grid[pos_x, pos_y];
        var block2 = player.grid[pos_x+1, pos_y];
        
        //if (self.current_match!= undefined && self.current_match.match_type == "bridge") {
            //var fetchX = self.current_match.fetch_from_x;
            //var targetX = self.current_match.x;
        //
            //if (fetchX < targetX) {
                //player.input.Left = true;
            //} else {
                //player.input.Right = true;
            //}
        //
            //player.input.ActionPress = true;
        //}
        
        
        if ((block1.type != BLOCK.NONE || block2.type != BLOCK.NONE) && 
            !block1.falling && !block2.falling &&
            !block1.popping && !block2.popping &&
            !block1.is_big && !block2.is_big) {
            
            // Check if this swap would create a match
            var creates_match = false;
            
            //// Only do this check if your game has the checkForMatch function
            //if (variable_struct_exists(self, "checkForMatch")) {
                //var type1 = block1.type;
                //var type2 = block2.type;
                //
                //// Temporarily swap
                //block1.type = type2;
                //block2.type = type1;
                //
                //// Check for match
                //creates_match = checkForMatch(pos_x, pos_y) || checkForMatch(pos_x+1, pos_y);
                //
                //// Swap back
                //block1.type = type1;
                //block2.type = type2;
            //}
            
            // Always attempt the swap, even if we're not sure it creates a match
            // (this handles cases where your game might have match detection logic we can't access)
            self.last_decision = "SWAP at " + string(pos_x) + "," + string(pos_y);
            array_push(self.decision_log, self.last_decision);
            if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
            
            // Perform the swap
            player.input.ActionPress = true;
            player.input.ActionKey = true;
            
            // Set cooldown (shorter if it creates a match, so we can find follow-up matches quicker)
            self.swap_cooldown = creates_match ? 5 : 10;
        }
    }
    
    
    
    // Helper function to check if a swap would create a match
    checkForMatch = function(col, row) {
        var grid = player.grid;
        var blockType = grid[col, row].type;
        
        if (blockType != BLOCK.NONE) return false;
        
        // Check horizontal matches
        var horizontalCount = 1;
        
        // Count to the left
        for (var c = col - 1; c >= 0; c--) {
            if (grid[c, row].type == blockType) {
                horizontalCount++;
            } else {
                break;
            }
        }
        
        // Count to the right
        for (var c = col + 1; c < self.width; c++) {
            if (grid[c, row].type == blockType) {
                horizontalCount++;
            } else {
                break;
            }
        }
        
        if (horizontalCount >= 3) return true;
        
        // Check vertical matches
        var verticalCount = 1;
        
        // Count upward
        for (var r = row - 1; r >= self.topmost_row; r--) {
            if (grid[col, r].type == blockType) {
                verticalCount++;
            } else {
                break;
            }
        }
        
        // Count downward
        for (var r = row + 1; r <= self.bottom_playable_row; r++) {
            if (grid[col, r].type == blockType) {
                verticalCount++;
            } else {
                break;
            }
        }
        
        return verticalCount >= 3;
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
                player.ai_max_delay = 2;
                self.move_delay = 2;
                self.action_delay = 4;
                self.scan_delay = 10; // Scan very frequently at master difficulty
                break;
        }
    }
    
    // Clean up data structures
    cleanup = function() {
        ds_queue_destroy(inputQueue);
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
            player.ai_max_delay = 2;
            self.move_delay = 2;
            self.action_delay = 4;
            self.scan_delay = 10; // Scan very frequently at master difficulty
            break;
    }
}
