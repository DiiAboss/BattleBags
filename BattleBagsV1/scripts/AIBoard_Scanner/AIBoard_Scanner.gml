/// @function AIBoardScanner
/// @param {struct} player The player struct
/// @returns {struct} Scanner struct
function AIBoardScanner(player) constructor {
    self.player = player;
    self.match_queue = ds_queue_create();
    
    // Game constants - will be picked up from player/controller
    self.top_playable_row = 4;
    self.bottom_playable_row = 20;
    self.width = 8;
    self.cleanup_timer = 0;
    
    // Scan for matches and add them to the match queue
    scanBoard = function() {
        // Clear previous matches
        ds_queue_clear(self.match_queue);
        
        var columnHeights = array_create(self.width, 0);
        
        for (var col = 0; col < self.width - 1; col++) {
            columnHeights[col] = getColumnHeight(col);
        }
        
        
        
        // Respect the topmost row when scanning
        var effective_top_row = min(self.top_playable_row, player.topmost_row);
        
        // Scan for direct matches (plain adjacent swaps that form matches)
                scanDirectMatches(effective_top_row);
                
        
        // Scan for horizontal matches
        scanHorizontalMatches(effective_top_row);
        
        // Scan for vertical matches
        scanVerticalMatches(effective_top_row);
        
        
        // Check for severe height differences that could use gravity
                for (var col = 0; col < self.width - 1; col++) {
                    var height = columnHeights[col];
                    var nextHeight = columnHeights[col+1];
                
                    if (abs(height - nextHeight) >= 2) {
                        scanForGravitySwap(col, col+1);
                    }
                }
        
        //if (self.cleanup_timer <= 0) {
            //scanForLevelingMoves();
            //self.cleanup_timer = irandom_range(8, 12);
        //} else {
                //self.cleanup_timer--;
            //}
        
        
        //// Scan for column reduction opportunities
        //scanForColumnReduction();
        //
        //// Prioritize tall column reduction if the board is getting dangerous
        //if (isInDangerZone()) {
            //applyDangerPriorities();
        //}
        
        return !ds_queue_empty(self.match_queue);
    }
    
    // Check for potential horizontal matches
    scanHorizontalMatches = function(effective_top_row) {
        var grid = player.grid;
        
        // For each row in the playable area
        for (var row = effective_top_row; row < self.bottom_playable_row - 1; row++) {
            // For each position that could be the start of a horizontal match
            for (var col = 0; col < self.width - 1; col++) {
                // Skip if blocks cannot be swapped
                var currentBlock = grid[col, row];
                var rightBlock = grid[col+1, row];
                
                if (currentBlock.type < 0 || rightBlock.type < 0 || 
                    currentBlock.falling || rightBlock.falling ||
                    currentBlock.popping || rightBlock.popping) {
                    continue;
                }
                
                // Pattern: 1 2 1 1 -> after swap: 1 1 2 1
                if (col > 0 && col+2 < self.width - 1) {
                    if (currentBlock.type == grid[col-1, row].type && 
                        currentBlock.type == grid[col+2, row].type &&
                        !grid[col-1, row].falling && !grid[col-1, row].popping &&
                        !grid[col+2, row].falling && !grid[col+2, row].popping) {
                        
                        // Calculate danger score - higher at the bottom of the board
                        var dangerScore = max(0, self.bottom_playable_row - row);
                        
                        // Add bonus for matches that would help level the board
                        var levelingBonus = calculateLevelingBonus(col, col+1);
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "horizontal",
                            score: 10 + dangerScore + levelingBonus
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
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "horizontal",
                            score: 10 + dangerScore + levelingBonus
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
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "horizontal",
                            score: 10 + dangerScore + levelingBonus
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
            }
        }
    }
    
    // Check for potential vertical matches
    scanVerticalMatches = function(effective_top_row) {
        var grid = player.grid;
        
        // For each column
        for (var col = 0; col < self.width - 1; col++) {
            // For each row position
            for (var row = effective_top_row; row < self.bottom_playable_row - 1; row++) {
                // Skip if blocks cannot be swapped
                var currentBlock = grid[col, row];
                var rightBlock = grid[col+1, row];
                
                if (currentBlock.type < 0 || rightBlock.type < 0 || 
                    currentBlock.falling || rightBlock.falling ||
                    currentBlock.popping || rightBlock.popping) {
                    continue;
                }
                
                // Pattern: right block forms vertical match with blocks above current
                if (row >= effective_top_row + 2) {
                    if (rightBlock.type == grid[col, row-1].type && 
                        rightBlock.type == grid[col, row-2].type &&
                        !grid[col, row-1].falling && !grid[col, row-1].popping &&
                        !grid[col, row-2].falling && !grid[col, row-2].popping) {
                        
                        var dangerScore = max(0, self.bottom_playable_row - row);
                        var heightBonus = calculateColumnHeightBonus(col);
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "vertical",
                            score: 15 + dangerScore + heightBonus
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
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "vertical",
                            score: 15 + dangerScore + heightBonus
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
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "vertical",
                            score: 15 + dangerScore + heightBonus
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
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "vertical",
                            score: 15 + dangerScore + heightBonus
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
            }
        }
    }
    
    
    // Modify your scanDirectMatches function:
    scanDirectMatches = function(effective_top_row) {
        var grid = player.grid;
        
        // For each position in the playable area
        for (var row = effective_top_row; row <= self.bottom_playable_row - 1; row++) {
            for (var col = 0; col < self.width - 1; col++) {
                // Skip invalid blocks (your existing code)
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
                    var base_score = 25;
                    var size_bonus = 0;
                    
                    // Exponential bonus for larger matches
                    if (max_match_size == 4) {
                        size_bonus = 40;  // Big jump for 4-matches
                    } else if (max_match_size >= 5) {
                        size_bonus = 70;  // Even bigger for 5+
                    }
                    
                    var matchInfo = {
                        x: col,
                        y: row,
                        match_type: max_match_size >= 4 ? "large_match" : "direct",
                        match_size: max_match_size,
                        score: base_score + size_bonus + (self.bottom_playable_row - row) * 2
                    };
                    
                    ds_queue_enqueue(self.match_queue, matchInfo);
                }
            }
        }
    }
    
    // Add this helper function to count connected blocks of the same type
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
    
    // Recursive helper for counting connected blocks
    floodFillCount = function(col, row, targetType, counted, count) {
        // Check boundaries
        if (col < 0 || col > self.width - 1 || 
            row < self.top_playable_row || row > self.bottom_playable_row) {
            return count;
        }
        
        // Skip if already counted or not the target type
        if (counted[col][row] || player.grid[col, row].type != targetType ||
            player.grid[col, row].falling || player.grid[col, row].popping) {
            return count;
        }
        
        // Count this block
        counted[col][row] = true;
        count++;
        
        // Continue in all four directions
        count = floodFillCount(col+1, row, targetType, counted, count); // right
        count = floodFillCount(col-1, row, targetType, counted, count); // left
        count = floodFillCount(col, row+1, targetType, counted, count); // down
        count = floodFillCount(col, row-1, targetType, counted, count); // up
        
        return count;
    }
    
    
    scanForLevelingMoves = function() {
        var grid = player.grid;
    
        var columnHeights = array_create(self.width, 0);
        for (var col = 0; col < self.width; col++) {
            columnHeights[col] = getColumnHeight(col);
        }
    
        var centerCol = self.width div 2;
    
        for (var col = 0; col < self.width - 1; col++) {
            //if (columnHeights[col] == 0) continue; // Skip empty columns
    
            var targetCol = (col < centerCol) ? col + 1 : col - 1;
            if (targetCol < 0 || targetCol >= self.width) continue; // Out of bounds safety
    
            var myHeight = columnHeights[col];
            var targetHeight = columnHeights[targetCol];
    
            if (targetHeight >= myHeight) continue; // Only pull down to lower columns
    
            for (var row = self.top_playable_row; row <= self.bottom_playable_row; row++) {
                var block = grid[col, row];
                if (block.type < 0) continue; // Skip empty blocks
    
                var adjBlock = grid[targetCol, row];
                if (adjBlock.type >= 0) continue; // Target spot already filled
    
                //if (!can_swap(block, adjBlock)) continue;
    
                ds_queue_enqueue(self.match_queue, {
                    x: min(col, targetCol),
                    y: row,
                    match_type: "leveling_move",
                    score: 25 + (self.bottom_playable_row - row)  // Prioritize lower moves first
                });
    
                // Only consider one move per column per scan (optional to avoid over-weighting)
                break;
            }
        }
    }
    
    
    // Add this helper function to count potential match size
    countMatchSize = function(col, row) {
        var grid = player.grid;
        var blockType = grid[col, row].type;
        var count = 0;
        
        // Count horizontal matches
        var hCount = 1;
        // Count left
        for (var c = col - 1; c >= 0; c--) {
            if (grid[c, row].type == blockType) {
                hCount++;
            } else {
                break;
            }
        }
        // Count right
        for (var c = col + 1; c < self.width; c++) {
            if (grid[c, row].type == blockType) {
                hCount++;
            } else {
                break;
            }
        }
        
        // Count vertical matches
        var vCount = 1;
        // Count up
        for (var r = row - 1; r >= player.topmost_row; r--) {
            if (grid[col, r].type == blockType) {
                vCount++;
            } else {
                break;
            }
        }
        // Count down
        for (var r = row + 1; r <= self.bottom_playable_row; r++) {
            if (grid[col, r].type == blockType) {
                vCount++;
            } else {
                break;
            }
        }
        
        return max(hCount, vCount);
    }
    
    // Add this function to estimate chain reaction potential
    estimateChainPotential = function(col, row) {
        var grid = player.grid;
        var potential = 0;
        
        // Check blocks above that would fall after a match
        for (var r = row - 1; r >= self.top_playable_row; r--) {
            if (grid[col, r].type >= 0 && !grid[col, r].falling && !grid[col, r].popping) {
                // This block would fall after a match
                potential += 2;
                
                // Check if it would form a new match when it falls
                var blockType = grid[col, r].type;
                var wouldMatch = false;
                
                // Check left/right at the position where it would fall
                for (var offset = -1; offset <= 1; offset += 2) {
                    var checkCol = col + offset;
                    if (checkCol >= 0 && checkCol < self.width) {
                        if (grid[checkCol, row].type == blockType && 
                            !grid[checkCol, row].falling && !grid[checkCol, row].popping) {
                            wouldMatch = true;
                            break;
                        }
                    }
                }
                
                if (wouldMatch) {
                    potential += 10; // Big bonus for chain reactions
                }
            }
        }
        
        return potential;
    }
    
    
    
    // Check if a position would form a match
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
        for (var c = col + 1; c < self.width; c++) {
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
    
    // Scan for column reduction opportunities
    scanForColumnReduction = function() {
        var tallestCol = findTallestColumn();
        if (tallestCol < 0) return;
        
        var grid = player.grid;
        
        // Check adjacent columns
        for (var offset = -1; offset <= 1; offset += 2) {
            var adjCol = tallestCol + offset;
            if (adjCol < 0 || adjCol >= self.width) continue;
            
            // Check each row in the tall column
            for (var row = player.topmost_row; row < self.bottom_playable_row - 1; row++) {
                var block = grid[tallestCol, row];
                var adjBlock = grid[adjCol, row];
                
                if (block.type < 0 || adjBlock.type < 0 || 
                    block.falling || adjBlock.falling ||
                    block.popping || adjBlock.popping) {
                    continue;
                }
                
                // Simulate swap and check if height decreases
                var beforeHeight = getColumnHeight(tallestCol);
                
                // Swap
                var tempType = block.type;
                block.type = adjBlock.type;
                adjBlock.type = tempType;
                
                var afterHeight = getColumnHeight(tallestCol);
                
                // Swap back
                adjBlock.type = block.type;
                block.type = tempType;
                
                if (afterHeight < beforeHeight) {
                    // Higher score for bigger height reduction
                    var heightDiff = beforeHeight - afterHeight;
                    
                    var matchInfo = {
                        x: min(tallestCol, adjCol),
                        y: row,
                        match_type: "column_reduction",
                        score: 15 + (heightDiff * 3)  // Reduced from 20 + (heightDiff * 5)
                    };
                    
                    ds_queue_enqueue(self.match_queue, matchInfo);
                }
            }
        }
    }
    
    // Look for gravity-based swaps
    scanForGravitySwap = function(col1, col2) {
        var grid = player.grid;
        var height1 = getColumnHeight(col1);
        var height2 = getColumnHeight(col2);
        
        // Only care about significant height differences
        if (abs(height1 - height2) < 1) return;
        
        var tallCol = height1 > height2 ? col1 : col2;
        var shortCol = height1 > height2 ? col2 : col1;
        
        // Look at the interface between columns
        var interfaceRow = self.bottom_playable_row - min(height1, height2);
        
        if (interfaceRow < self.top_playable_row - 1) return; // No valid interface
        
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
                score: 25  // Reduced from 35
            };
            
            ds_queue_enqueue(self.match_queue, matchInfo);
        }
    }
    
    // Helper function to find the tallest column
    findTallestColumn = function() {
        var tallest = -1;
        var maxHeight = 0;
        
        for (var col = 0; col < self.width; col++) {
            var height = getColumnHeight(col);
            if (height > maxHeight) {
                maxHeight = height;
                tallest = col;
            }
        }
        
        return tallest;
    }
    
    // Calculate column height
    getColumnHeight = function(col) {
        var grid = player.grid;
        
        for (var row = self.top_playable_row; row < self.bottom_playable_row - 1; row++) {
            if (grid[col, row].type >= 0) {
                return self.bottom_playable_row - row + 1;
            }
        }
        
        return 0;
    }
    
    // Check if the board is in a dangerous state
    isInDangerZone = function() {
        // Check if any column is dangerously high
        for (var col = 0; col < self.width; col++) {
            if (getColumnHeight(col) > 18) {
                return true;
            }
        }
        
        return false;
    }
    
    
    applyDangerPriorities = function() {
        if (ds_queue_empty(self.match_queue)) return;
        
        // Create temporary queue
        var temp_queue = ds_queue_create();
        
        // For each match in the queue
        while (!ds_queue_empty(self.match_queue)) {
            var match = ds_queue_dequeue(self.match_queue);
            
            // Check if this move affects a tall column
            var col = match.x;
            var nextCol = (match.match_type == "horizontal" || match.match_type == "direct") ? col + 1 : col;
            
            if (getColumnHeight(col) > 18 || getColumnHeight(nextCol) > 18) {
                match.score += 100; // Massive bonus for reducing dangerous columns
            }
            
            // Give direct matches an extra boost in non-danger situations
            if (match.match_type == "direct" && !isInDangerZone()) {
                match.score += 30; // Extra bonus to ensure direct matches get priority
            }
            
            // Re-add to temp queue
            ds_queue_enqueue(temp_queue, match);
        }
        
        // Restore from temp queue to match queue
        while (!ds_queue_empty(temp_queue)) {
            ds_queue_enqueue(self.match_queue, ds_queue_dequeue(temp_queue));
        }
        
        // Clean up
        ds_queue_destroy(temp_queue);
    }
    
    // Helper function to calculate bonus for matches in tall columns
    calculateColumnHeightBonus = function(col) {
        var height = getColumnHeight(col);
        return max(0, height - 10) * 1; // Bonus points for taller columns
    }
    
    // Helper function to calculate bonus for matches that level the board
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
    
    // Get the best match from the queue
    getNextMatch = function() {
        if (ds_queue_empty(self.match_queue)) {
            return undefined;
        }
        
        // Find the highest scored match
        var bestMatch = undefined;
        var bestScore = -1;
        
        // Create a temporary queue
        var tempQueue = ds_queue_create();
        
        // Find the best match
        while (!ds_queue_empty(self.match_queue)) {
            var match = ds_queue_dequeue(self.match_queue);
            
            if (bestMatch == undefined || match.score > bestScore) {
                bestMatch = match;
                bestScore = match.score;
            }
            
            ds_queue_enqueue(tempQueue, match);
        }
        
        // Restore all except the best match
        while (!ds_queue_empty(tempQueue)) {
            var match = ds_queue_dequeue(tempQueue);
            
            if (match != bestMatch) {
                ds_queue_enqueue(self.match_queue, match);
            }
        }
        
        // Clean up
        ds_queue_destroy(tempQueue);
        
        return bestMatch;
    }
    
    // Clean up resources
    cleanup = function() {
        if (ds_exists(self.match_queue, ds_type_queue)) {
            ds_queue_destroy(self.match_queue);
        }
    }
}


