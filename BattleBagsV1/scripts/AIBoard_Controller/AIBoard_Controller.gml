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

    self.match_attempts = 0; // Counter for tracking how many times we've tried a specific match
    self.recent_positions = ds_list_create();  // Track recent positions
   self.recent_position_limit = 2;  // How many recent positions to remember
   self.swap_variety_counter = 0;  // Track number of consecutive swaps at same position
    self.committed_to_match = false;
    self.commitment_target_x = -1;
    self.commitment_target_y = -1;
    
    self.failed_matches = ds_map_create();
    self.failed_match_limit = 2; // How many times to try before blacklisting
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
        
        self.topmost_row = player.topmost_row;
        
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
                        
                        self.current_action = "pre_swap";
                        self.move_timer = 0;
                    } else {
                        // Take one step toward the target
                        moveOneStep();
                    }
                }
                break;
                
            case "pre_swap":
                
                     // Reset all input flags before new move
                     player.input.Up = false;
                     player.input.Down = false;
                     player.input.Left = false;
                     player.input.Right = false;
            
                    trySwap();
                    
                    // Back to idle
                    self.current_action = "idle";
                    //self.swap_after_move = false;
                    
                    // Clear current match after trying it
                    self.current_match = undefined;
                //}
                break;
            
            
            case "vertical_bridge_fetch":
                handleVerticalBridgeFetch();
                break;
        }
        
        if (player.board_just_shifted) { // Every 5 seconds at 60 FPS
            // Clear out the failed matches map
            ds_map_clear(self.failed_matches);
            self.last_decision = "CLEARNING match blacklist due to shifting board";
            array_push(self.decision_log, self.last_decision);
            player.board_just_shifted = false;
            self.current_match = undefined;
        }
    }
    

    
    
    
    handleVerticalBridgeFetch = function() {
        var curX = player.hovered_block[0];
        var curY = player.hovered_block[1];
    
        var fetchY = self.current_match.fetch_from_y;
        var targetY = self.current_match.target_y;
    
        if (curY != fetchY) {
            self.target_x = curX; // Stay in column
            self.target_y = fetchY;
            moveOneStep();
            return;
        }
    
        // Arrived at fetch position, time to start swapping the block vertically
        if (fetchY < targetY) {
            player.input.Down = true;
        } else {
            player.input.Up = true;
        }
    
        //player.input.ActionPress = true;
    
        // Move fetch block closer to target
        if (fetchY < targetY) {
            self.current_match.fetch_from_y++;
        } else {
            self.current_match.fetch_from_y--;
        }
    
        // Once fetch block arrives at target, complete the move
        if (self.current_match.fetch_from_y == targetY) {
            self.current_action = "idle";
            self.current_match = undefined;
            self.last_decision = "VERTICAL BRIDGE MOVE COMPLETE";
            array_push(self.decision_log, self.last_decision);
        }
    }
    
    
    planNextMove = function() {
        self.current_match = findNearbyMatch(player.hovered_block[0], player.hovered_block[1], 5);
    
        if (self.current_match == undefined) {
            if (player.ai_scanner.scanBoard()) {
                self.current_match = player.ai_scanner.getNextMatch();
            }
        }
    
        if (self.current_match != undefined) {
            self.target_x = self.current_match.x;
            self.target_y = self.current_match.y;
            self.target_x = clamp(self.target_x, 0, self.width - 2); // Never allow cursor to overflow
            
            
            self.last_decision = "MOVING TO MATCH at " + string(self.target_x) + "," + string(self.target_y);
            array_push(self.decision_log, self.last_decision);
            if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
    
            self.current_action = "moving";
            self.move_timer = 0;
            self.swap_after_move = true;
            return;
        }
    
        // No match found — go explore
        exploreStrategically();
    }
    
    moveToCurrentMatch = function() {
        self.target_x = self.current_match.x;
        self.target_y = self.current_match.y;
        
        
        self.last_decision = "MOVING TO MATCH at " + string(self.target_x) + "," + string(self.target_y) +
                            " (" + self.current_match.match_type + ")";
        array_push(self.decision_log, self.last_decision);
        if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
    
        self.current_action = "moving";
        self.move_timer = 0;
        //self.swap_after_move = true;
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
            if (distance <= radius && !isRepeatedMatch){
                // Give a bonus to nearby matches
                match.score += (radius - distance + 1) * 5; // Reduced from 10 to make it less sticky
                
                // Track the best nearby match
                if (nearbyMatch == undefined || match.score > bestScore) {
                    nearbyMatch = match;
                    bestScore = match.score;
                }
            }
            else {
                return undefined;
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
            if (lastMatchAttempts > 2) {
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
        
        player.global_y_offset -= 2;
        return;
        
        if (player.ai_difficulty >= 3) {
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

        var mid_range = floor((self.bottom_playable_row - self.topmost_row) * 0.6);
        var pos_x = irandom_range(0, self.width - 2);
        var pos_y = irandom_range(self.topmost_row, self.topmost_row + mid_range);
        
        self.last_decision = "EXPLORING at " + string(pos_x) + "," + string(pos_y);
        array_push(self.decision_log, self.last_decision);
        if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
        
        self.target_x = pos_x;
        self.target_y = pos_y;
    }
    
    
    
    
    
    
    moveOneStep = function() {
        var curX = player.hovered_block[0];
        var curY = player.hovered_block[1];
    
        // Reset all input flags before new move (safety reset)
        player.input.Up = false;
        player.input.Down = false;
        player.input.Left = false;
        player.input.Right = false;
    
        // Safety bounds clamp (just in case target drifted out)
        self.target_y = clamp(self.target_y, self.top_playable_row, self.bottom_playable_row);
        self.target_x = clamp(self.target_x, 0, self.width - 1);
    
        var dx = self.target_x - curX;
        var dy = self.target_y - curY;
    
        // Evaluate column safety (don't walk into death)
        var currentColumnSafe = isColumnSafe(curX);
        var targetColumnSafe = isColumnSafe(self.target_x);
    
        if (!targetColumnSafe) {
            self.last_decision = "Target column UNSAFE at " + string(self.target_x);
            array_push(self.decision_log, self.last_decision);
            if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
    
            // Re-aim to nearest safe column
            self.target_x = findNearestSafeColumn(curX);
    
            if (self.target_x >= self.width - 1) {
                self.target_x = self.width - 2;  // Ensure space for 2-block cursor
            }
    
            dx = self.target_x - curX;  // Recalculate after adjustment
        }
    
        // Calculate how many steps to move this frame based on AI difficulty
        var maxSteps = clamp(abs(2 - player.ai_difficulty), 1, 3);  // Easy = 1, Master = 3
    
        // ** Horizontal Movement First **
        if (dx != 0) {
            var stepDirection = sign(dx);  // -1 for left, +1 for right
            var stepsToTake = min(abs(dx), maxSteps);
    
            for (var step = 0; step < stepsToTake; step++) {
                if (stepDirection > 0) {
                    player.input.Right = true;

                    curX++;  // Update our internal tracking
                } else {
                    player.input.Left = true;

                    curX--;
                }
            }
    
            // Log movement
            self.last_decision = "Moved HORIZONTALLY to " + string(curX) + "," + string(curY);
            array_push(self.decision_log, self.last_decision);
            if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
    
            return;  // Prioritize horizontal
        }
    
        // ** Vertical Movement if Horizontal Aligned **
        if (dy != 0) {
            var stepDirection = sign(dy);  // -1 for up, +1 for down
            var stepsToTake = min(abs(dy), maxSteps);
    
            for (var step = 0; step < stepsToTake; step++) {
                if (stepDirection > 0) {
                    player.input.Down = true;

                    curY++;
                } else {
                    player.input.Up = true;

                    curY--;
                }
            }
    
            // Log movement
            self.last_decision = "Moved VERTICALLY to " + string(curX) + "," + string(curY);
            array_push(self.decision_log, self.last_decision);
            if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
    
            return;  // Done for this frame
        }
    
        // Final arrival (fully aligned)
        self.last_decision = "ARRIVED at " + string(curX) + "," + string(curY);
        array_push(self.decision_log, self.last_decision);
        if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
    
        self.current_action = "idle";  // Ready for next AI step
    }
    
    
    
       
    
    
    
    
    isColumnSafe = function(col) {
        for (var row = self.top_playable_row; row < self.bottom_playable_row; row++) {
            var block = player.grid[col, row];
            //if (block.falling || block.popping) {
             //   return false;
            //}
        }
        return true;
    }
    
    findNearestSafeColumn = function(startCol) {
        var left = startCol - 1;
        var right = startCol + 1;
    
        while (left >= 0 || right < self.width) {
            if (left >= 0 && isColumnSafe(left)) return left;
            if (right < self.width && isColumnSafe(right)) return right;
            left--;
            right++;
        }
    
        // No safe column found — this should almost never happen
        return startCol; // Fall back to original (no better option)
    }
    
    
    
    
    trySwap = function() {
        var pos_x = player.hovered_block[0];
            var pos_y = player.hovered_block[1];
        
            var matchKey = string(pos_x) + "," + string(pos_y);
        
    
        // Check if position is valid for a swap
        if (pos_x < 0 || pos_x >= self.width - 1 || pos_y < self.top_playable_row || pos_y > self.bottom_playable_row) return;
    
        var block1 = player.grid[pos_x, pos_y];
        self.current_action = "idle";   // Done with this special move
        var block2 = undefined; // Depending on match type, block2 could be horizontal or vertical
        
        
        
        if (self.current_match != undefined) {
            // Horizontal swap (default behavior)
            if (pos_x + 1 > self.width - 1) return; // Safety check
            block2 = player.grid[pos_x + 1, pos_y];
        }
    
        
        if (block2 == undefined) return;
        if (block1.type == block2.type) return;
        
        if ((block1.type != BLOCK.NONE || block2.type != BLOCK.NONE) && 
            !block1.falling && !block2.falling &&
            !block1.popping && !block2.popping &&
            !block1.is_big && !block2.is_big) {
    
            self.last_decision = "SWAP at " + string(pos_x) + "," + string(pos_y);
            array_push(self.decision_log, self.last_decision);
            if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
    
            player.input.ActionPress = true;
            //input.ActionKey = true;
    
            self.swap_cooldown = 1;  // Adjust if you want quicker chaining
            //self.scan_delay = 1; // Scan very frequently at master difficulty
        }
    
   }
    
    
    function buildMovePlan(board) {
        var simulatedBoard = cloneBoard(board);
        var plan = [];
        var visited = ds_map_create();
        
        var queue = ds_queue_create();
    
        var initialState = {
            board: simulatedBoard,
            path: []
        };
    
        ds_queue_enqueue(queue, initialState);
        
        while (!ds_queue_empty(queue)) {
            var currentState = ds_queue_dequeue(queue);
            var currentBoard = currentState.board;
            var currentPath = currentState.path;
    
            if (isBoardCleared(currentBoard)) {
                plan = currentPath;
                break;
            }
            
            var validSwaps = findAllValidSwaps(currentBoard);
            
            for (var i = 0; i < array_length(validSwaps); i++) {
                var swap = validSwaps[i];
                var newBoard = cloneBoard(currentBoard);
                applySwap(newBoard, swap[0], swap[1]);
    
                var boardKey = boardToString(newBoard);
                if (!ds_map_exists(visited, boardKey)) {
                    ds_map_add(visited, boardKey, true);
    
                    var newPath = array_create(array_length(currentPath) + 1);
                    array_copy(newPath, 0, currentPath, 0, array_length(currentPath));
                    newPath[array_length(currentPath)] = swap; // Add new move to path
    
                    ds_queue_enqueue(queue, {board: newBoard, path: newPath});
                }
            }
        }
        
        ds_map_destroy(visited);
        ds_queue_destroy(queue);
        
        return plan;  // Final move sequence
    }
    
    function findAllValidSwaps(board) {
        var swaps = [];
        for (var _y = self.top_playable_row; _y <= self.bottom_playable_row; _y++) {
            for (var _x = 0; _x < self.width - 1; _x++) {
                if (canBlocksSwap(board[_x, _y], board[_x+1, _y])) {
                    array_push(swaps, [_x, _y]);
                }
            }
        }
        return swaps;
    }
    
    function canBlocksSwap(blockA, blockB) {
        if (blockA.type < 0 || blockB.type < 0) return false;
        if (blockA.falling || blockB.falling) return false;
        if (blockA.popping || blockB.popping) return false;
        return true;
    }
    
    function applySwap(board, x, y) {
        var temp = board[x, y];
        board[x, y] = board[x+1, y];
        board[x+1, y] = temp;
    }
    
    
    exploreStrategically = function() {
        var tallest_column = 0;
        var tallest_height = 0;
    
        for (var col = 0; col < self.width; col++) {
            var height = self.player.ai_scanner.getColumnHeight(col);
            if (height > tallest_height) {
                tallest_height = height;
                tallest_column = col;
            }
        }
    
        if (irandom(3) == 0) {
            self.target_x = tallest_column; // Bias toward tallest column 25% of the time
        } else {
            self.target_x = irandom_range(0, self.width - 2);
        }
    
        var mid_range = floor((self.bottom_playable_row - self.topmost_row) * 0.6);
        self.target_y = irandom_range(self.topmost_row, self.topmost_row + mid_range);
    
        self.last_decision = "EXPLORING at " + string(self.target_x) + "," + string(self.target_y);
        array_push(self.decision_log, self.last_decision);
        if (array_length(self.decision_log) > 10) array_delete(self.decision_log, 0, 1);
    
        self.current_action = "moving";
        self.move_timer = 0;
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
                player.ai_max_delay = 0;
                self.move_delay = 0;
                self.action_delay = 0;
                self.scan_delay = 10; // Scan very frequently at master difficulty
                break;
        }
    }
    
    // Clean up data structures
    cleanup = function() {
        ds_queue_destroy(inputQueue);
    }
}
