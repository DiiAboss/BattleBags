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
        var effective_top_row = min(self.top_playable_row, player.topmost_row);
        
        // Prioritize scanning edge columns first
        //scanEdgeColumnTowers();
        scanColumnTowers();
        scanDirectMatches(effective_top_row);
        
            
        scanIndirectMatches(effective_top_row);
        scanHorizontalMatches(effective_top_row);
        scanVerticalMatches(effective_top_row);
        scanForPotentialPairs();

            
        // Check for gravity swap opportunities between adjacent columns
        for (var _col = 0; _col < self.width - 1; _col++) {
            var _height = columnHeights[_col];
            var _nextHeight = columnHeights[_col+1];
            
            if (abs(_height - _nextHeight) >= 2) {
                scanForGravitySwap(_col, _col+1);
            }
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
        var bestScore = -1;

        
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
        var grid = player.grid;
    
        for (var row = effective_top_row; row <= self.bottom_playable_row - 1; row++) {
            for (var col = 0; col < self.width - 2; col++) {  // Scan 2 blocks apart first
                checkIndirectMatchAt(col, row, 2, 30); // Distance of 2, base score 30
            }
            for (var col = 0; col < self.width - 3; col++) {  // Scan 3 blocks apart
                checkIndirectMatchAt(col, row, 3, 20); // Distance of 3, lower base score 20
            }
            
            for (var col = 0; col < self.width - 4; col++) {  // Scan 3 blocks apart
                checkIndirectMatchAt(col, row, 4, 10); // Distance of 3, lower base score 20
            }
        }
    }
    
    // Helper function to scan a pair of blocks separated by 'gap' spaces
    checkIndirectMatchAt = function(col, row, gap, baseScore) {
        var grid = player.grid;
        
        var block1 = grid[col, row];
        var block2 = grid[col + gap, row];
        
        if (block1.type < 0 || block2.type < 0 || 
            block1.falling || block2.falling ||
            block1.popping || block2.popping) {
            return;
        }
        
        if (block1.type != block2.type) return;
    
        // Now check if the blocks between them are swappable
        var canSwap = true;
        for (var middle = 1; middle < gap; middle++) {
            var middleBlock = grid[col + middle, row];
            if (middleBlock.type < 0 || middleBlock.falling || middleBlock.popping) {
                canSwap = false;
                break;
            }
        }
        if (!canSwap) return;
    
        // Find the block to move (closest to a match)
        var bestMove = undefined;
        var bestScore = -9999;
    
        for (var middle = 1; middle < gap; middle++) {
            // Try swapping this middle block left or right
            var leftCol = col + middle - 1;
            var rightCol = col;
    
            // Temporarily swap left
            if (leftCol >= 0) {
                swapBlocks(col + middle, row, leftCol, row);
                if (checkForMatch(leftCol, row)) {
                    var matchSize = countConnectedBlocks(leftCol, row);
                    var distance = abs(player.hovered_block[0] - leftCol) + abs(player.hovered_block[1] - row);
                    var _score = baseScore + matchSize * 10 - distance * 5;
                    if (_score > bestScore) {
                        bestScore = _score;
                        bestMove = { x: leftCol, y: row };
                    }
                }
                swapBlocks(col + middle, row, leftCol, row);  // Undo
            }
    
            // Temporarily swap right
            if (rightCol < self.width) {
                swapBlocks(col + middle, row, rightCol, row);
                if (checkForMatch(rightCol, row)) {
                    var matchSize = countConnectedBlocks(rightCol, row);
                    var distance = abs(player.hovered_block[0] - rightCol) + abs(player.hovered_block[1] - row);
                    var _score = baseScore + matchSize * 10 - distance * 5;
                    if (_score > bestScore) {
                        bestScore = _score;
                        bestMove = { x: rightCol, y: row };
                    }
                }
                swapBlocks(col + middle, row, rightCol, row);  // Undo
            }
        }
    
        if (bestMove != undefined) {
            var matchInfo = {
                x: bestMove.x,
                y: bestMove.y,
                match_type: "indirect",
                match_size: 3, // Technically, you could pass the actual detected size
                score: bestScore
            };
            ds_queue_enqueue(self.match_queue, matchInfo);
        }
    }
    
    // Helper function to swap two blocks (this should already exist somewhere in your codebase)
    swapBlocks = function(x1, y1, x2, y2) {
        var temp = player.grid[x1, y1].type;
        player.grid[x1, y1].type = player.grid[x2, y2].type;
        player.grid[x2, y2].type = temp;
    }
    
    
    
    
    
    /// Scan for direct matches by temporary block swapping (continued)
    scanDirectMatches = function(effective_top_row) {
        var grid = player.grid;
        
        for (var row = effective_top_row; row <= self.bottom_playable_row - 1; row++) {
            for (var col = 0; col < self.width - 1; col++) {
                // Skip invalid blocks
                var block1 = grid[col, row];
                var block2 = grid[col+1, row];
                
                if (block1.type < 0 || block2.type < 0 || 
                    block1.falling || block2.falling || 
                    block1.popping || block2.popping) {
                    continue;
                }
                
                // Temporarily swap blocks
                var type1 = block1.type;
                var type2 = block2.type;
                
                // Do the swap
                block1.type = type2;
                block2.type = type1;
                
                // Now check for matches at both positions, but count match size
                var match_size1 = 0;
                var match_size2 = 0;
                
                // Only check if this could be a match (3 or more)
                if (checkForMatch(col, row)) {
                    match_size1 = countConnectedBlocks(col, row);
                }
                
                if (checkForMatch(col+1, row)) {
                    match_size2 = countConnectedBlocks(col+1, row);
                    
                }
                
                // Undo the swap
                block1.type = type1;
                block2.type = type2;
                
                // Use the larger of the two match sizes
                var max_match_size = max(match_size1, match_size2);
                
                if (max_match_size >= 3) {
                    // Calculate score with strong bias toward larger matches
                    var base_score = 40;
                    var size_bonus = 0;
                    
                    // Exponential bonus for larger matches
                    if (max_match_size == 4) {
                        size_bonus = 80;  // Big jump for 4-matches
                    } else if (max_match_size >= 5) {
                        size_bonus = 120;  // Even bigger for 5+
                    }
                    var distance = abs(player.hovered_block[0] - col) + abs(player.hovered_block[1] - row);
                    var matchInfo = {
                        x: col,
                        y: row,
                        match_type: max_match_size >= 4 ? "large_match" : "direct",
                        match_size: max_match_size,
                        score: (base_score + size_bonus - distance * 5)
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
                        score: 2 * strength - (distance * irandom(3)) // Nearby pairs more valuable
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
            var swapRow = clamp(targetRow - 2, player.topmost_row, self.bottom_playable_row);
    
            // Step 4: Validate swap opportunity
            var sourceBlock = grid[col, swapRow];
            var targetBlock = grid[targetCol, swapRow];
            
            if (sourceBlock.type != BLOCK.NONE && targetBlock.type != BLOCK.NONE) return;
            
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
