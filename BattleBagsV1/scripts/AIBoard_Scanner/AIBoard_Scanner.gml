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
        
        // Prioritize scanning edge columns first
        //scanEdgeColumnTowers();
        
        //scanDirectMatches(effective_top_row);
        scanHorizontalMatches(effective_top_row);
        scanVerticalMatches(effective_top_row);
        scanColumnTowers();
        scanIndirectMatches(effective_top_row);
        
        for (var row = self.top_playable_row; row <= self.bottom_playable_row; row++) {
                    var str = "ROW: " +string(row)
                    for (var col = 0; col < self.width - 1; col++) {
                        var _add = player.grid[col, row].type >= 0 ? string(player.grid[col, row].type) : "e";
                        
                        str += "[" + _add + "]";
                    }
                show_debug_message(str);
                    //str += "\n";
                    }
        show_debug_message("");
        
        if ds_queue_empty(self.match_queue) 
        {
            //scanForPotentialPairs(); 
        }
            
        
        return !ds_queue_empty(self.match_queue);
    }
    

    #region Column Heights
    

    /// @desc Calculates and updates the height of each column based on the current grid state.
    ///        This function measures from the **top playable row** down to the **bottom playable row**.
    ///
    /// @note The result is stored directly into `self.columnHeights`.
    ///       Each entry represents how many blocks are in each column.
    ///
    /// `Example Result (8 columns):
    /// [5, 4, 6, 3, 7, 5, 2, 4]`
    ///
    /// This function should be called whenever the grid changes due to new blocks or popping.
    function calculateColumnHeights() {
        for (var col = 0; col < self.width; col++) {
            self.columnHeights[col] = getColumnHeight(col);
        }
    }
     
      
    /// @function getColumnHeight
    /// @desc Calculates the height of a single column by counting how many blocks are present.
    /// @member {AIBoardScanner}
    /// @param {real} col - The column index (0 to width-1)
    /// @returns {real} The number of filled cells in the column.
    ///
    /// @note This only counts from `top_playable_row` downwards.
    ///       If a column has no blocks, the height is 0.
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
    
    #endregion

    
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



    /// Scan for bridge move opportunities
    scanBridgeMoves = function() {
        var grid = player.grid;
    
        for (var row = self.top_playable_row; row <= self.bottom_playable_row; row++) {
            for (var col = 0; col < self.width - 2; col++) {
                var blockA = grid[col, row];
                if (blockA.type < 0) continue;
    
                for (var checkCol = col + 2; checkCol < self.width; checkCol++) {
                    var blockB = grid[checkCol, row];
                    if (blockB.type != blockA.type || blockB.type < 0) continue;
    
                    // Check if the space between them is empty or mismatched
                    var validBridge = true;
                    for (var gapCol = col + 1; gapCol < checkCol; gapCol++) {
                        var betweenBlock = grid[gapCol, row];
                        if (betweenBlock.type >= 0 && betweenBlock.type == blockA.type) {
                            validBridge = false;
                            break;
                        }
                    }
    
                    if (validBridge) {
                        // Find fetch block (any matching block)
                        var fetchX = -1;
                        for (var searchCol = 0; searchCol < self.width; searchCol++) {
                            if (searchCol == col || searchCol == checkCol) continue;
                            if (grid[searchCol, row].type == blockA.type) {
                                fetchX = searchCol;
                                break;
                            }
                        }
    
                        if (fetchX != -1) {
                            var movePlan = {
                                x: col,
                                y: row,
                                match_type: "bridge",
                                color: blockA.type,
                                fetch_from_x: fetchX,
                                target_x: (fetchX < col) ? col - 1 : checkCol + 1,
                                score: 15 - abs(fetchX - col) * 2
                            };
    
                            ds_queue_enqueue(self.match_queue, movePlan);
                        }
                    }
                }
            }
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
    
    scanIndirectMatches = function(effective_top_row) {
        var maxGap = 7;  // Check up to 4 spaces away
    
        for (var row = effective_top_row; row <= self.bottom_playable_row - 1; row++) {
            for (var col = 0; col < self.width; col++) {
                var block = player.grid[col, row];
    
                if (block.type < 0 || block.falling || block.popping) {
                    continue; // Skip unusable blocks
                }
    
                for (var gap = 1; gap <= maxGap; gap++) {
                    if checkGapMatch(col, row, gap, 100 - gap * 10) continue; // Scan rightward
                    if checkGapMatch(col, row, -gap, 100 - gap * 10) continue; // Scan leftward
                }
            }
        }
    }
    
    
    checkGapMatch = function(col, row, gap, baseScore) {
        
        var grid = player.grid;
        var targetCol = col + gap;
        if gap > 0 dir = 0;
        var dir = gap > 0 ? 0 : 1;    
        //var move_dir = gap >= 0 ? 1 : 1;
        var moveCol = col - dir; // - move_dir;
        
        
        // [col] + 4 . 0-4, 1-5, 2-6, 3,7
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
        
        
        
        
        
        //0 -> 4
        //[0]
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
        var distance = abs(player.hovered_block[0] - moveCol) + abs(player.hovered_block[1] - row);
        var _score = (baseScore) - distance * 1 + irandom(5);
    
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
        if (horizontalCount >= 3) return true;
    
        // Vertical check
        var verticalCount = 1;
        for (var r = row - 1; r >= player.topmost_row && player.grid[col, r].type == blockType; r--) verticalCount++;
        for (var r = row + 1; r <= player.bottom_playable_row && player.grid[col, r].type == blockType; r++) verticalCount++;
        if (verticalCount >= 3) return true;
    
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
    
    scanDirectMatches = function(effective_top_row) {
        var grid = player.grid;
        
        for (var row = effective_top_row; row <= self.bottom_playable_row - 1; row++) {
            for (var col = 0; col < player.width - 1; col++) {
                // Skip invalid blocks - check everything at once
                var block1 = grid[col, row];
                var block2 = grid[col+1, row];
                
                if (block1.type < 0 || block2.type < 0 || 
                    block1.falling || block2.falling || 
                    block1.popping || block2.popping ||
                    block1.type == block2.type) {  // Important: skip same type blocks!
                    continue;
                }
                
                // Temporarily swap blocks and check for matches
                var type1 = block1.type;
                var type2 = block2.type;
                
                block1.type = type2;
                block2.type = type1;
                
                var match_size1 = 0;
                var match_size2 = 0;
                
                if (checkForMatch(col, row)) {
                    match_size1 = countConnectedBlocks(col, row);
                }
                
                if (checkForMatch(col+1, row)) {
                    match_size2 = countConnectedBlocks(col+1, row);
                }
                
                // Undo the swap
                block1.type = type1;
                block2.type = type2;
                
                var max_match_size = max(match_size1, match_size2);
                
                // Only queue legitimate matches
                if (max_match_size >= 3) {
                    var base_score = 40;
                    var size_bonus = 0;
                    
                    if (max_match_size == 4) {
                        size_bonus = 80;
                    } else if (max_match_size >= 5) {
                        size_bonus = 120;
                    }
                    var distance = abs(player.hovered_block[0] - col) + abs(player.hovered_block[1] - row);
                    var matchInfo = {
                        x: col,
                        y: row,
                        match_type: max_match_size >= 4 ? "large_match" : "direct",
                        match_size: max_match_size,
                        score: (base_score + size_bonus - distance * 5  - (row * 2))
                    };
                    
                    ds_queue_enqueue(self.match_queue, matchInfo);
                }
            }
        }
    }
    
        /// Count connected blocks of the same type
        countConnectedBlocks = function(startCol, startRow) {
            var grid = player.grid;
            var targetType = grid[startCol, startRow].type;
            var counted = array_create(self.width);
            
            // Create 2D array for tracking visited positions
            for (var col = 0; col < self.width; col++) {
                counted[col] = array_create(self.bottom_playable_row, false);
            }
            
            // Create a data structure to track positions to check
            var positionsToCheck = ds_queue_create();
            ds_queue_enqueue(positionsToCheck, [startCol, startRow]);
            counted[startCol][startRow] = true;
            
            var totalCount = 0;
            
            // Iterative flood fill (instead of recursive)
            while (!ds_queue_empty(positionsToCheck)) {
                var position = ds_queue_dequeue(positionsToCheck);
                var col = position[0];
                var row = position[1];
                
                // Count this position
                totalCount++;
                
                // Check all four adjacent positions
                var directions = [
                    [1, 0],  // right
                    [-1, 0], // left
                    [0, 1],  // down
                    [0, -1]  // up
                ];
                
                for (var i = 0; i < 4; i++) {
                    var newCol = col + directions[i][0];
                    var newRow = row + directions[i][1];
                    
                    // Check boundaries
                    if (newCol < 0 || newCol > self.width - 1 || 
                        newRow < player.topmost_row || newRow > self.bottom_playable_row - 1) {
                        continue;
                    }
                    
                    // Check if not visited and matches the target type
                    if (!counted[newCol][newRow] && 
                        grid[newCol, newRow].type == targetType && 
                        !grid[newCol, newRow].falling && 
                        !grid[newCol, newRow].popping) {
                        
                        counted[newCol][newRow] = true;
                        ds_queue_enqueue(positionsToCheck, [newCol, newRow]);
                    }
                }
            }
            
            // Clean up
            ds_queue_destroy(positionsToCheck);
            
            return totalCount;
        }
    
    
    
        /// Check if a position would form a match
        checkForMatch = function(col, row) {
            var grid = player.grid;
            var blockType = grid[col, row].type;
            
            if (blockType == BLOCK.NONE) return false;
            
            // Check horizontal matches (need at least 3 in a row)
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
            for (var c = col + 1; c < self.width - 1; c++) {
                if (grid[c, row].type == blockType) {
                    horizontalCount++;
                } else {
                    break;
                }
            }
            
            if (horizontalCount >= 3) return true;
            
            // Check vertical matches (need at least 3 in a column)
            var verticalCount = 1;
            
            // Count upward
            for (var r = row - 1; r >= player.topmost_row; r--) {
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
    
    
    
        /// Look for gravity-based swaps
        scanForGravitySwap = function(col1, col2) {
            var grid = player.grid;
            var height1 = getColumnHeight(col1);
            var height2 = getColumnHeight(col2);
            
            // Only care about significant height differences
            if (abs(height1 - height2) < 2) return;
            
            var tallCol = height1 > height2 ? col1 : col2;
            var shortCol = height1 > height2 ? col2 : col1;
            
            // Look at the interface between columns
            var interfaceRow = self.bottom_playable_row - min(height1, height2);
            
            if (interfaceRow < player.topmost_row) return; // No valid interface
            
            // Check blocks at the interface
            var tallBlock = grid[tallCol, interfaceRow];
            var shortBlock = grid[shortCol, interfaceRow];
            
            if (tallBlock.type == BLOCK.NONE || shortBlock.type == BLOCK.NONE ||
                tallBlock.falling || shortBlock.falling ||
                tallBlock.popping || shortBlock.popping) {
                return;
            }
            
            // Check if there's a gap below in the short column
            if (interfaceRow < self.bottom_playable_row - 1 && grid[shortCol, interfaceRow+1].type == BLOCK.NONE) {
                var matchInfo = {
                    x: min(tallCol, shortCol),
                    y: interfaceRow,
                    match_type: "gravity",
                    score: 25  
                };
                
                ds_queue_enqueue(self.match_queue, matchInfo);
            }
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

    
    
    scanForPotentialPairs = function() {
        var grid = player.grid;
        var effective_top_row = max(self.top_playable_row, player.topmost_row);
    
        for (var row = effective_top_row; row <= self.bottom_playable_row - 1; row++) {
            for (var col = 0; col < self.width - 1; col++) {
                var block1 = grid[col, row];
                var block2 = grid[col+1, row];
                
                if (block1.type == block2.type) continue;
                
                if (block1.type < 0 || block2.type < 0 || 
                    block1.falling || block2.falling || 
                    block1.popping || block2.popping) {
                    continue;
                }
    
                // Check if either block is already part of an existing match group
                if (isBlockInMatchGroup(col, row) || isBlockInMatchGroup(col+1, row)) {
                    continue;
                }
    
                // Temporarily swap them
                var type1 = block1.type;
                var type2 = block2.type;
                block1.type = type2;
                block2.type = type1;
                
                // Check if the swap creates any 2-block pair (not a full 3-match yet)
                var pairStrength = evaluate2BlockPotential(col, row) + evaluate2BlockPotential(col+1, row);
    
                // Undo swap
                block1.type = type1;
                block2.type = type2;
    
                if (pairStrength > 0) {
                    var distance = abs(player.hovered_block[0] - col) + abs(player.hovered_block[1] - row);
                    randomize();
                    
                    var strength = 1 + irandom(9);
                    
                    var movePlan = {
                        x: col,
                        y: row,
                        match_type: "potential_pair",
                        score: strength - (distance * irandom(3)) // Nearby pairs more valuable
                    };
                    random_set_seed(player.random_seed);
                    ds_queue_enqueue(self.match_queue, movePlan);
                }
            }
        }
    }
    
    // New helper function to check if a block is part of an existing match group
    isBlockInMatchGroup = function(col, row) {
        var grid = player.grid;
        var type = grid[col, row].type;
        if (type < 0) return false;
    
        // Count connected blocks in all 4 directions
        var matchCount = 1;  // Start with 1 (the block itself)
    
        // Check horizontal left
        for (var c = col - 1; c >= 0; c--) {
            if (grid[c, row].type == type && 
                !grid[c, row].falling && 
                !grid[c, row].popping) {
                matchCount++;
            } else {
                break;
            }
        }
    
        // Check horizontal right
        for (var c = col + 1; c < self.width - 1; c++) {
            if (grid[c, row].type == type && 
                !grid[c, row].falling && 
                !grid[c, row].popping) {
                matchCount++;
            } else {
                break;
            }
        }
    
        // If horizontal match exists, return true
        if (matchCount >= 2) return true;
    
        // Reset match count for vertical check
        matchCount = 1;
    
        // Check vertical up
        for (var r = row - 1; r >= self.top_playable_row; r--) {
            if (grid[col, r].type == type && 
                !grid[col, r].falling && 
                !grid[col, r].popping) {
                matchCount++;
            } else {
                break;
            }
        }
    
        // Check vertical down
        for (var r = row + 1; r <= self.bottom_playable_row; r++) {
            if (grid[col, r].type == type && 
                !grid[col, r].falling && 
                !grid[col, r].popping) {
                matchCount++;
            } else {
                break;
            }
        }
    
        // Return true if vertical match exists
        return matchCount >= 2;
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
            var distance = abs(player.hovered_block[0] - col) + abs(player.hovered_block[1] - swapRow);
            var dangerScore = (self.bottom_playable_row - swapRow);
            var levelingBonus = (heightDifference * 5);
    
            var match = {
                x: col + swap_side,
                y: swapRow,
                match_type: "tower_clear",
                target_x: targetCol,
                score: 15 + levelingBonus + dangerScore - (distance * (1 + irandom(4)))
            };
    
            ds_queue_enqueue(self.match_queue, match);
        }
    }
    
    
    // Helper to evaluate how "good" a 2-block potential is
        evaluate2BlockPotential = function(col, row) {
            var grid = player.grid;
            var type = grid[col, row].type;
            if (type < 0) return 0;
    
            var pairStrength = 0;
    
            // Horizontal neighbors
            if (col > 0 && grid[col-1, row].type == type) pairStrength++;
            if (col < self.width - 1 && grid[col+1, row].type == type) pairStrength++;
    
            // Vertical neighbors
            if (row > self.top_playable_row && grid[col, row-1].type == type) pairStrength++;
            if (row < self.bottom_playable_row - 1 && grid[col, row+1].type == type) pairStrength++;
    
            return pairStrength;
    }
}
