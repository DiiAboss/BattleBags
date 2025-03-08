/// @function AIBoardScanner
/// @param {struct} player The player struct
/// @returns {struct} Scanner struct
function AIBoardScanner(player) constructor {
    // Core scanner properties
    self.player = player;
    self.match_queue = ds_queue_create();
    self.top_playable_row = 4;
    self.bottom_playable_row = 20;
    self.width = 8;
    self.columnHeights = array_create(self.width, 0);
    self.heights_dirty = true;
    self.balance_queue = ds_queue_create();
    self.leveling_mode = false;
    

    
        /// Main board scanning function
    scanBoard = function(levelingMode = false) {
        if (self.heights_dirty) {
            calculateColumnHeights();
            self.heights_dirty = false;
        }
        
        // Clear previous matches
        ds_queue_clear(self.match_queue);
        var columnHeights = self.columnHeights;
        
        // Determine effective top row
        var effective_top_row = max(self.top_playable_row, player.topmost_row);
        
        scanHorizontalMatches(effective_top_row);
        scanVerticalMatches(effective_top_row);
        scanColumnTowers();
        scanMatches(effective_top_row);
        
        if ds_queue_empty(self.match_queue)
        {
            scanPotentialPairs();
        }
        
        
        show_grid_in_debug();
            
        
        return !ds_queue_empty(self.match_queue);
    }
    

    /// This function should be called whenever the grid changes due to new blocks or popping.
    function calculateColumnHeights() {
        for (var col = 0; col < self.width; col++) {
            self.columnHeights[col] = getColumnHeight(col);
        }
    }
    
    function getColumnHeight(col) {
        var height = 0;
    
        for (var row = self.top_playable_row; row <= self.bottom_playable_row; row++) {
            if (player.grid[col, row].type != BLOCK.NONE) {
                height = self.bottom_playable_row - row + 1;
                break;
            }
        }
    
        return height;
    }
    
    show_grid_in_debug = function(enabled = true)
    {
        if !enabled return;
        for (var row = self.top_playable_row; row <= self.bottom_playable_row; row++) {
            var str = "ROW: " +string(row)
            for (var col = 0; col < self.width - 1; col++) {
                var _add = player.grid[col, row].type >= 0 ? string(player.grid[col, row].type) : "e";
                str += "[" + _add + "]";
            }
            show_debug_message(str);
            } 
        show_debug_message("");
    }
    
    /// Get the next best match from the queue
    getNextMatch = function() {
        if (ds_queue_empty(self.match_queue)) return undefined;
        
        var bestMatch = undefined;
        var bestScore = -999;

        
        // Create a temporary queue to preserve original order
        var tempQueue = ds_queue_create();
        
        // Find the highest scoring match
        while (!ds_queue_empty(self.match_queue)) {
            var match = ds_queue_dequeue(self.match_queue);
            if (bestMatch == undefined || match.score > bestScore) {
                bestMatch = match;
                bestScore = match.score;
            }
            ds_queue_enqueue(tempQueue, match);
        }

        // Restore the original queue
        while (!ds_queue_empty(tempQueue)) {
            ds_queue_enqueue(self.match_queue, ds_queue_dequeue(tempQueue));
        }
        ds_queue_destroy(tempQueue);

        return bestMatch;
    }

    /// Cleanup function to destroy queue
    cleanup = function() {
        if (ds_exists(self.match_queue, ds_type_queue)) {
            ds_queue_destroy(self.match_queue);
        }
        if (ds_exists(self.balance_queue , ds_type_queue)) {
                    ds_queue_destroy(self.balance_queue );
                }

    }

    /// Scan for horizontal matches
    scanHorizontalMatches = function(effective_top_row) {
        var grid = player.grid;
        randomize();
        var rand = irandom(10);
        
        
        for (var row = effective_top_row; row < self.bottom_playable_row - 1; row++) {
            for (var col = 0; col < self.width - 1; col++) {
                // Skip if blocks cannot be swapped
                var currentBlock = grid[col, row];
                var rightBlock = grid[col+1, row];
                
                if (currentBlock.type < 0 || rightBlock.type < 0 || 
                    currentBlock.falling || rightBlock.falling ||
                    currentBlock.popping || rightBlock.popping) {
                    continue;
                }
                
                // Various horizontal match patterns
                // Pattern: 1 2 1 1 -> after swap: 1 1 2 1
                if (col > 0 && col+2 < self.width - 1) {
                    if (currentBlock.type == grid[col-1, row].type && 
                        currentBlock.type == grid[col+2, row].type &&
                        !grid[col-1, row].falling && !grid[col-1, row].popping &&
                        !grid[col+2, row].falling && !grid[col+2, row].popping) {
                        
                        var dangerScore = max(0, self.bottom_playable_row - row);
                        var levelingBonus = calculateLevelingBonus(col, col+1);
                        var rand = irandom(10);
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "horizontal",
                            score: 20 + dangerScore + levelingBonus + rand
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
                
                // Pattern: 1 1 2 -> after swap: 1 2 1
                if (col > 1) {
                    if (rightBlock.type == grid[col-1, row].type && 
                        rightBlock.type == grid[col-2, row].type &&
                        !grid[col-1, row].falling && !grid[col-1, row].popping &&
                        !grid[col-2, row].falling && !grid[col-2, row].popping) {
                        
                        var dangerScore = max(0, self.bottom_playable_row - row);
                        var levelingBonus = calculateLevelingBonus(col, col+1);
                        var rand = irandom(10);
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "horizontal",
                            score: 20 + dangerScore + levelingBonus + rand
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
                
                // Pattern: 2 1 1 -> after swap: 1 2 1
                if (col < self.width - 3) {
                    if (currentBlock.type == grid[col+2, row].type && 
                        currentBlock.type == grid[col+3, row].type &&
                        !grid[col+2, row].falling && !grid[col+2, row].popping &&
                        !grid[col+3, row].falling && !grid[col+3, row].popping) {
                        
                        var dangerScore = max(0, self.bottom_playable_row - row);
                        var levelingBonus = calculateLevelingBonus(col, col+1);
                        var rand = irandom(10);
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "horizontal",
                            score: 20 + dangerScore + levelingBonus + rand
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
            }
        }
        random_set_seed(player.random_seed);
    }

    /// Scan for vertical matches
    scanVerticalMatches = function(effective_top_row) {
        var grid = player.grid;
        randomize();
        var rand = irandom(10);
        
        for (var col = 0; col < self.width - 1; col++) {
            for (var row = effective_top_row; row < self.bottom_playable_row - 1; row++) {
                // Skip if blocks cannot be swapped
                var currentBlock = grid[col, row];
                var rightBlock = grid[col+1, row];
                
                if (currentBlock.type < 0 || rightBlock.type < 0 || 
                    currentBlock.falling || rightBlock.falling ||
                    currentBlock.popping || rightBlock.popping) {
                    continue;
                }
                
                // Various vertical match patterns
                // Pattern: right block forms vertical match with blocks above current
                if (row >= effective_top_row + 2) {
                    if (rightBlock.type == grid[col, row-1].type && 
                        rightBlock.type == grid[col, row-2].type &&
                        !grid[col, row-1].falling && !grid[col, row-1].popping &&
                        !grid[col, row-2].falling && !grid[col, row-2].popping) {
                        
                        var dangerScore = max(0, self.bottom_playable_row - row);
                        var heightBonus = calculateColumnHeightBonus(col);
                        var rand = irandom(10);
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "vertical",
                            score: 20 + dangerScore + heightBonus + rand
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
                
                // Pattern: current block forms vertical match with blocks above right
                if (row >= effective_top_row + 2) {
                    if (currentBlock.type == grid[col+1, row-1].type && 
                        currentBlock.type == grid[col+1, row-2].type &&
                        !grid[col+1, row-1].falling && !grid[col+1, row-1].popping &&
                        !grid[col+1, row-2].falling && !grid[col+1, row-2].popping) {
                        
                        var dangerScore = max(0, self.bottom_playable_row - row);
                        var heightBonus = calculateColumnHeightBonus(col+1);
                        var rand = irandom(10);
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "vertical",
                            score: 20 + dangerScore + heightBonus + rand
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
                
                // Pattern: right block forms vertical match with blocks below current
                if (row <= self.bottom_playable_row - 2) {
                    if (rightBlock.type == grid[col, row+1].type && 
                        rightBlock.type == grid[col, row+2].type &&
                        !grid[col, row+1].falling && !grid[col, row+1].popping &&
                        !grid[col, row+2].falling && !grid[col, row+2].popping) {
                        
                        var dangerScore = max(0, self.bottom_playable_row - row);
                        var heightBonus = calculateColumnHeightBonus(col);
                        
                        var rand = irandom(10);
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "vertical",
                            score: 20 + dangerScore + heightBonus + rand
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
                
                // Pattern: current block forms vertical match with blocks below right
                if (row <= self.bottom_playable_row - 2) {
                    if (currentBlock.type == grid[col+1, row+1].type && 
                        currentBlock.type == grid[col+1, row+2].type &&
                        !grid[col+1, row+1].falling && !grid[col+1, row+1].popping &&
                        !grid[col+1, row+2].falling && !grid[col+1, row+2].popping) {
                        
                        var dangerScore = max(0, self.bottom_playable_row - row);
                        var heightBonus = calculateColumnHeightBonus(col+1);
                        var rand = irandom(10);
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "vertical",
                            score: 20 + dangerScore + heightBonus + rand
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
            }
        }
        random_set_seed(player.random_seed);
    }
    
    
    scanMatches = function(effective_top_row) {
        var maxGap = 7;  // Check up to 4 spaces away
    
        for (var row = effective_top_row; row <= self.bottom_playable_row - 1; row++) {
            for (var col = 0; col < self.width; col++) {
                var block = player.grid[col, row];
    
                if (block.type < 0 || block.falling || block.popping) {
                    continue; // Skip unusable blocks
                }
    
                for (var gap = 1; gap <= maxGap; gap++) {
                    if checkGapMatch(col, row, gap, 100 - (gap * 5)) continue; // Scan rightward
                    if checkGapMatch(col, row, -gap, 100 - (gap * 5)) continue; // Scan leftward
                }
            }
        }
    }
    
    
    checkGapMatch = function(col, row, gap, baseScore) {
        
        var grid = player.grid;
        var targetCol = col + gap;
        if gap > 0 dir = 0;
        var dir = gap > 0 ? 0 : 1;    
        var moveCol = col - dir;

        if (targetCol < 0 || targetCol >= player.width) return false;
        
        var block1 = grid[col, row];
        var block1_left = grid[max(0, col - 1), row];
        var block1_right = grid[min(col + 1, player.width - 1), row];
        
        if (block1.type == BLOCK.NONE) return false;
        
        var block2 = grid[targetCol, row];
        var block3 = grid[targetCol - sign(gap), row]; 
        
        var block2_down_1 = grid[targetCol, row + 1].type;
        var block2_up_1 = grid[targetCol, row - 1].type;
        var block2_left_1 = grid[max(0,targetCol - 1), row].type;
        var block2_right_1 = grid[min(player.width - 1, targetCol + 1), row].type;
        
        
        
        if (block2.falling || block2.popping) {
            return false;
        }
        
        if (block1.type != block2_down_1
        && block1.type != block2_up_1
        && block1.type != block2_left_1
        && block1.type != block2_right_1) return false;
        
        if (dir == 0)
        {
            if (block1.type == block1_right.type) return false;
        }
        else {
            if (block1.type == block1_left.type) return false;
        }
    
        // Swap on the temp grid
        var type1 = block1.type;
        var type2 = block2.type;
        var type3 = block3.type;
    
        block1.type = type3;
        block3.type = type2;
        block2.type = type1;
    
        var valid = checkTempMatch(targetCol, row)
        var matchSize = countConnectedBlocksInGrid(targetCol, row);
        
        block1.type = type1;
        block2.type = type2;
        block3.type = type3;
        
        
        if (matchSize < 3 || !valid) return;
        
        show_debug_message("Col: " + string(col) + "\n"
                                + "Row: " + string(row) + "\n"
                                    + "Target Col: " + string(targetCol) + "\n"
                                        + "Move Col: " + string(moveCol) + "\n"
        + "Move Dir: " + string(dir) + "\n")
        
        show_debug_message("Match Size: " + string(matchSize) + "\n")
        randomize();
        // Check for match in the temp grid at the target position (where the moveBlock landed)
        var distance = (abs(player.hovered_block[0] - moveCol) + abs(player.hovered_block[1])) + (row * (2));
        var _score = (baseScore * 2) - ((distance) * (1 + irandom(1)));
    
        ds_queue_enqueue(self.match_queue, {
            x: moveCol,  // Where cursor needs to go to perform swap
            y: row,
            match_type: "indirect",
            size: matchSize,
            score: _score
        });
    
        return true;  // Found match, stop further scanning for this block
        random_set_seed(player.random_seed);
    }
    
    checkTempMatch = function(col, row) {
        if (col < 0 || col > player.width - 1) return false;
        var blockType = player.grid[col, row].type;
    
        if (blockType < 0) return false;
    
        // Horizontal check
        var horizontalCount = 1;
        for (var c = col - 1; c >= 0 && player.grid[c, row].type == blockType; c--) horizontalCount++;
        for (var c = col + 1; c < player.width && player.grid[c, row].type == blockType; c++) horizontalCount++;
    
        // Vertical check
        var verticalCount = 1;
        for (var r = row - 1; r >= player.topmost_row && player.grid[col, r].type == blockType; r--) verticalCount++;
        for (var r = row + 1; r <= player.bottom_playable_row && player.grid[col, r].type == blockType; r++) verticalCount++;
    
        if (horizontalCount >= 3 || verticalCount >= 3) return true;
        return false;
    }
    
    countConnectedBlocksInGrid = function(col, row) {
        if (col < 0 || col > player.width - 1) return false;
        var blockType = player.grid[col, row].type;
    
        var count = 1;  // Itself counts
        for (var c = col - 1; c >= 0 && player.grid[c, row].type == blockType; c--) count++;
        for (var c = col + 1; c < player.width - 1 && player.grid[c, row].type == blockType; c++) count++;
        for (var r = row - 1; r >= player.topmost_row && player.grid[col, r].type == blockType; r--) count++;
        for (var r = row + 1; r <= player.bottom_playable_row && player.grid[col, r].type == blockType; r++) count++;
    
        return count;
    }
    
    
        /// Helper function to calculate bonus for matches in tall columns
        calculateColumnHeightBonus = function(col) {
            var height = getColumnHeight(col);
            return max(0, height - 10) * 1; // Bonus points for taller columns
        }
    
        /// Helper function to calculate bonus for matches that level the board
        calculateLevelingBonus = function(col1, col2) {
            var height1 = getColumnHeight(col1);
            var height2 = getColumnHeight(col2);
            
            // Find the average height of all columns
            var totalHeight = 0;
            var columnCount = 0;
            
            for (var col = 0; col < self.width; col++) {
                var height = getColumnHeight(col);
                if (height > 0) {
                    totalHeight += height;
                    columnCount++;
                }
            }
            
            var avgHeight = columnCount > 0 ? totalHeight / columnCount : 0;
            
            // Bonus for reducing tall columns or filling short ones
            var bonus = 0;
            
            if (height1 > avgHeight + 3) {
                bonus += min(15, (height1 - avgHeight) * 2);
            }
            
            if (height2 > avgHeight + 3) {
                bonus += min(15, (height2 - avgHeight) * 2);
            }
            
            return bonus;
        }
    

    scanColumnTowers = function() {
        var grid = player.grid;
        var columnHeights = array_create(self.width, 0);
        var columnTopRows = array_create(self.width, self.bottom_playable_row);
    
        // Step 1: Measure heights and find top blocks
        for (var col = 0; col < self.width; col++) {
            for (var row = player.topmost_row; row <= self.bottom_playable_row; row++) {
                if (grid[col, row].type >= 0) {
                    columnHeights[col]++;
                    if (columnTopRows[col] == self.bottom_playable_row) {
                        columnTopRows[col] = row;
                    }
                }
            }
        }
    
        // Step 2: Scan for leveling opportunities between each column pair
        for (var col = 0; col < self.width; col++) {
            var height = columnHeights[col];
            if (height < 2) continue; // No point leveling tiny columns.
    
            // Check left and right neighbors
            var leftHeight = (col > 0) ? columnHeights[col - 1] : 999;
            var rightHeight = (col < self.width - 1) ? columnHeights[col + 1] : 999;
    
            var targetCol = -1;
            var heightDifference = 0;
    
            // Prefer balancing to the **shorter** side
            if (leftHeight < rightHeight) {
                targetCol = col - 1;
                heightDifference = height - leftHeight;
            } else {
                targetCol = col + 1;
                heightDifference = height - rightHeight;
            }
    
            if (targetCol < 0 || targetCol >= self.width) continue; // Out of bounds safety
    
            // Only act if the height difference is significant
            if (heightDifference < 2) continue;
    
            // Step 3: Find a **valid swap row** near the top of the taller column
            var sourceRow = columnTopRows[col];
            var targetRow = columnTopRows[targetCol];
    
            // Prefer swaps within 1-3 rows from the top (avoid deep digging)
            var swapRow = clamp(targetRow - (1 + irandom(1)), player.topmost_row, self.bottom_playable_row);
    
            // Step 4: Validate swap opportunity
            var sourceBlock = grid[col, swapRow];
            var targetBlock = grid[targetCol, swapRow];
            
            if (sourceBlock.type != BLOCK.NONE && targetBlock.type != BLOCK.NONE) return; 
                
            if (sourceBlock.type == targetBlock.type) return;
            
            // only decrement the swap side if we need to swap to left, as its set to righ naturally
            var swap_side = targetCol > col ? 0 : -1;
            
            // Step 5: Score and enqueue the swap move
            var distance = (abs(player.hovered_block[0] - col) + abs(player.hovered_block[1]))  + swapRow;
            var dangerScore = (self.bottom_playable_row - swapRow) * (5 + player.shift_speed);
            var levelingBonus = (heightDifference * (15));
    
            var match = {
                x: col + swap_side,
                y: swapRow,
                match_type: "tower_clear",
                target_x: targetCol,
                score: 15 + (levelingBonus + dangerScore) - (distance * (irandom(6 - player.ai_difficulty)))
            };
    
            ds_queue_enqueue(self.match_queue, match);
        }
    }
    
    
    scanPotentialPairs = function() {
        var grid = player.grid;
        var max_gap = 1;  // Max distance to check for potential pairs
        
        for (var row = self.top_playable_row; row <= self.bottom_playable_row - 1; row++) {
            for (var col = 0; col <= self.width - 1; col++) {
                
                var block = grid[col, row];
                if (block.type < 0 || block.falling || block.popping) continue;
                
                
                // Look ahead for a matching block
                for (var gap = 1; gap <= max_gap; gap++) {
                    var targetCol = col + gap;
                    if (targetCol >= self.width - 1) break; // Out of bounds
                    
                    if (grid[col, row].type == grid[col + 1, row].type) continue;
                        
                    var targetBlock = grid[targetCol, row];
                    if (targetBlock.type != block.type || targetBlock.falling || targetBlock.popping) continue;
    
                    // **Check if this pair is already part of a match**
                    if (isPartOfPair(col, row) || isPartOfPair(targetCol, row)) {
                        continue; // Skip queueing if already part of a match
                    }
    
                    // Check if there's space between them
                    for (var moveCol = col + 1; moveCol < targetCol; moveCol++) {
                            queuePotentialMove(col, row, moveCol, row, block.type, 50 - (gap * 5));
                            continue;
                        
                    }
                }
            }
        }
    }
    
    isPartOfPair = function(col, row) {
        var grid = player.grid;
        var blockType = grid[col, row].type;
        if (blockType < 0) return false;
    
        // Check **horizontal** pairs
        if (col > 0 && grid[col - 1, row].type == blockType) return true;
        if (col < self.width - 1 && grid[col + 1, row].type == blockType) return true;
    
        // Check **vertical** pairs
        if (row > self.top_playable_row && grid[col, row - 1].type == blockType) return true;
        if (row < self.bottom_playable_row && grid[col, row + 1].type == blockType) return true;
    
        return false;
    }
    
    
    // **Enqueues a potential move into the AI queue**
    queuePotentialMove = function(startCol, startRow, targetCol, targetRow, blockType, score) {
        ds_queue_enqueue(self.match_queue, {
            x: targetCol,   // AI will move this block
            y: startRow,
            target_x: targetCol,
            target_y: targetRow,
            match_type: "setup_pair",
            size: 2,  // It's a potential pair, not a full match yet
            score: score
        });
    
        show_debug_message("📌 Queued pair setup: Move [" + string(startCol) + "," + string(startRow) + "] ➡ [" + string(targetCol) + "," + string(targetRow) + "]");
    }
    
    
    
    
}
