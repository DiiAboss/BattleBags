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
    
    // Scan for matches and add them to the match queue
    scanBoard = function() {
        // Clear previous matches
        ds_queue_clear(self.match_queue);
        
        // Scan for horizontal matches
        scanHorizontalMatches();
        
        // Scan for vertical matches
        scanVerticalMatches();
        
        return !ds_queue_empty(self.match_queue);
    }
    
    // Check for potential horizontal matches
    scanHorizontalMatches = function() {
        var grid = player.grid;
        
        // For each row in the playable area
        for (var row = self.top_playable_row; row <= self.bottom_playable_row; row++) {
            // Check each position that could be the start of a horizontal match
            for (var col = 0; col < self.width - 1; col++) {
                // Check if swapping col and col+1 would create a match
                var currentBlock = grid[col, row];
                var rightBlock = grid[col+1, row];
                
                // Skip if blocks cannot be swapped
                if (currentBlock.type < 0 || rightBlock.type < 0 || 
                    currentBlock.falling || rightBlock.falling ||
                    currentBlock.popping || rightBlock.popping ||
                    currentBlock.is_big || rightBlock.is_big) {
                    continue;
                }
                
                // Check patterns where swapping would create a horizontal match
                
                // Pattern: 1 2 1 1 -> after swap: 1 1 2 1
                if (col > 0 && col+2 < self.width) {
                    if (currentBlock.type == grid[col-1, row].type && 
                        currentBlock.type == grid[col+2, row].type &&
                        !grid[col-1, row].falling && !grid[col-1, row].popping &&
                        !grid[col+2, row].falling && !grid[col+2, row].popping) {
                        
                        // Found a potential match at col,row
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "horizontal",
                            score: 10 // Basic score for a match
                        };
                        
                        // Add to queue
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
                
                // Pattern: 1 1 2 -> after swap: 1 2 1
                if (col > 1) {
                    if (rightBlock.type == grid[col-1, row].type && 
                        rightBlock.type == grid[col-2, row].type &&
                        !grid[col-1, row].falling && !grid[col-1, row].popping &&
                        !grid[col-2, row].falling && !grid[col-2, row].popping) {
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "horizontal",
                            score: 10
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
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "horizontal",
                            score: 10
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
            }
        }
    }
    
    // Check for potential vertical matches
    scanVerticalMatches = function() {
        var grid = player.grid;
        
        // For each column
        for (var col = 0; col < self.width - 1; col++) {
            // For each position that could be the start of a vertical match
            for (var row = self.top_playable_row; row <= self.bottom_playable_row; row++) {
                // Check if swapping col and col+1 would create a match
                var currentBlock = grid[col, row];
                var rightBlock = grid[col+1, row];
                
                // Skip if blocks cannot be swapped
                if (currentBlock.type < 0 || rightBlock.type < 0 || 
                    currentBlock.falling || rightBlock.falling ||
                    currentBlock.popping || rightBlock.popping ||
                    currentBlock.is_big || rightBlock.is_big) {
                    continue;
                }
                
                // Check patterns where swapping would create a vertical match
                
                // Pattern: current block forms vertical match when swapped
                if (row >= self.top_playable_row + 2) {
                    // Check if the right block would form a match with the two blocks above current
                    if (rightBlock.type == grid[col, row-1].type && 
                        rightBlock.type == grid[col, row-2].type &&
                        !grid[col, row-1].falling && !grid[col, row-1].popping &&
                        !grid[col, row-2].falling && !grid[col, row-2].popping) {
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "vertical",
                            score: 15 // Slightly higher score for vertical matches
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
                
                if (row <= self.bottom_playable_row - 2) {
                    // Check if the right block would form a match with the two blocks below current
                    if (rightBlock.type == grid[col, row+1].type && 
                        rightBlock.type == grid[col, row+2].type &&
                        !grid[col, row+1].falling && !grid[col, row+1].popping &&
                        !grid[col, row+2].falling && !grid[col, row+2].popping) {
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "vertical",
                            score: 15
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
                
                if (row >= self.top_playable_row + 1 && row <= self.bottom_playable_row - 1) {
                    // Check if the right block would form a match with one above and one below
                    if (rightBlock.type == grid[col, row-1].type && 
                        rightBlock.type == grid[col, row+1].type &&
                        !grid[col, row-1].falling && !grid[col, row-1].popping &&
                        !grid[col, row+1].falling && !grid[col, row+1].popping) {
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "vertical",
                            score: 15
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
                
                // Now check if the current block forms vertical match when swapped with right
                if (row >= self.top_playable_row + 2) {
                    // Check if the current block would form a match with the two blocks above right
                    if (currentBlock.type == grid[col+1, row-1].type && 
                        currentBlock.type == grid[col+1, row-2].type &&
                        !grid[col+1, row-1].falling && !grid[col+1, row-1].popping &&
                        !grid[col+1, row-2].falling && !grid[col+1, row-2].popping) {
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "vertical",
                            score: 15
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
                
                if (row <= self.bottom_playable_row - 2) {
                    // Check if the current block would form a match with the two blocks below right
                    if (currentBlock.type == grid[col+1, row+1].type && 
                        currentBlock.type == grid[col+1, row+2].type &&
                        !grid[col+1, row+1].falling && !grid[col+1, row+1].popping &&
                        !grid[col+1, row+2].falling && !grid[col+1, row+2].popping) {
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "vertical",
                            score: 15
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
                
                if (row >= self.top_playable_row + 1 && row <= self.bottom_playable_row - 1) {
                    // Check if the current block would form a match with one above and one below right
                    if (currentBlock.type == grid[col+1, row-1].type && 
                        currentBlock.type == grid[col+1, row+1].type &&
                        !grid[col+1, row-1].falling && !grid[col+1, row-1].popping &&
                        !grid[col+1, row+1].falling && !grid[col+1, row+1].popping) {
                        
                        var matchInfo = {
                            x: col,
                            y: row,
                            match_type: "vertical",
                            score: 15
                        };
                        
                        ds_queue_enqueue(self.match_queue, matchInfo);
                    }
                }
            }
        }
    }
    
    // Get the next match from the queue
    getNextMatch = function() {
        if (ds_queue_empty(self.match_queue)) {
            return undefined;
        }
        
        return ds_queue_dequeue(self.match_queue);
    }
    
    // Clean up resources
    cleanup = function() {
        ds_queue_destroy(self.match_queue);
    }
}







///// @function AIBoardScanner
///// @param {struct} player The player struct
///// @returns {struct} Scanner struct
//function AIBoardScanner(player) constructor {
    //self.player = player;
    //
    //// Find vertical matches (3+ blocks of same color)
    //findVerticalMatch = function() {
        //var result = { found: false, color: -1, bottomRow: -1, topRow: -1 };
        //var grid = player.grid;
        //var min_row = 4;  // Top playable row
        //var max_row = 20; // Bottom playable row
        //
        //// Scan grid for vertical patterns of same color
        //for (var col = 0; col < 8; col++) {
            //var currentColor = -1;
            //var matchCount = 0;
            //var topRow = -1;
            //
            //for (var row = min_row; row <= max_row; row++) {
                //var block = grid[col, row];
                //
                //// Check if this is a valid colored block
                //if (block.type >= 0 && block.type <= 10 && !block.falling && !block.popping) {
                    //if (currentColor == -1) {
                        //// First block of potential match
                        //currentColor = block.type;
                        //matchCount = 1;
                        //topRow = row;
                    //} else if (block.type == currentColor) {
                        //// Continuing match
                        //matchCount++;
                    //} else {
                        //// Different color, check if we had a match
                        //if (matchCount >= 2) {
                            //result.found = true;
                            //result.color = currentColor;
                            //result.topRow = topRow;
                            //result.bottomRow = row - 1;
                            //return result;
                        //}
                        //
                        //// Reset for new potential match
                        //currentColor = block.type;
                        //matchCount = 1;
                        //topRow = row;
                    //}
                //} else {
                    //// Non-matchable block, reset
                    //if (matchCount >= 2) {
                        //result.found = true;
                        //result.color = currentColor;
                        //result.topRow = topRow;
                        //result.bottomRow = row - 1;
                        //return result;
                    //}
                    //
                    //currentColor = -1;
                    //matchCount = 0;
                    //topRow = -1;
                //}
            //}
            //
            //// Check for match at end of column
            //if (matchCount >= 2) {
                //result.found = true;
                //result.color = currentColor;
                //result.topRow = topRow;
                //result.bottomRow = max_row;
                //return result;
            //}
        //}
        //
        //return result;
    //}
    //
    //// Find potential vertical matches (2 blocks with one move)
    //findPotentialVerticalMatch = function() {
        //var grid = player.grid;
        //var min_row = 4;  // Top playable row
        //var max_row = 20; // Bottom playable row
        //var result = { found: false, pos_x: 0, pos_y: 0, color: -1 };
        //
        //// Look for pairs of same-colored blocks separated by one position
        //for (var col = 0; col < 8; col++) {
            //var sameColorBlocks = [];
            //
            //// Collect valid blocks of the same color
            //for (var row = min_row; row <= max_row; row++) {
                //var block = grid[col, row];
                //if (block.type >= 0 && block.type <= 10 && !block.falling && !block.popping && !block.is_big) {
                    //// Store row positions of same-colored blocks
                    //var entry = {row: row, color: block.type};
                    //sameColorBlocks[array_length(sameColorBlocks)] = entry;
                //}
            //}
            //
            //// Look for patterns like X-X where X is the same color and - is a gap
            //for (var i = 0; i < array_length(sameColorBlocks) - 1; i++) {
                //for (var j = i + 1; j < array_length(sameColorBlocks); j++) {
                    //var block1 = sameColorBlocks[i];
                    //var block2 = sameColorBlocks[j];
                    //
                    //// Check if same color
                    //if (block1.color == block2.color) {
                        //// Check if they have 1 block between them
                        //if (abs(block1.row - block2.row) == 2) {
                            //var middleRow = (block1.row + block2.row) / 2;
                            //
                            //// Look left and right for a block of the same color
                            //for (var checkCol = 0; checkCol < 8; checkCol++) {
                                //if (checkCol != col) {
                                    //var potentialBlock = grid[checkCol, middleRow];
                                    //if (potentialBlock.type == block1.color && 
                                        //!potentialBlock.falling && 
                                        //!potentialBlock.popping && 
                                        //!potentialBlock.is_big) {
                                        //
                                        //// Found a potential match!
                                        //result.found = true;
                                        //result.pos_x = checkCol;
                                        //result.pos_y = middleRow;
                                        //result.color = block1.color;
                                        //return result;
                                    //}
                                //}
                            //}
                        //}
                    //}
                //}
            //}
        //}
        //
        //return result;
    //}
    //
    //// Find chain reactions where one match leads to another
    //findChainReaction = function() {
        //var grid = player.grid;
        //var min_row = 4;
        //var max_row = 20;
        //var result = { found: false, pos_x: 0, pos_y: 0 };
        //
        //// Look for potential chain reactions - where a match would cause blocks to fall into another match
        //for (var col = 0; col < 7; col++) {
            //for (var row = min_row; row <= max_row - 3; row++) {
                //// Look for a potential match at the current position
                //var block1 = grid[col, row];
                //var block2 = grid[col+1, row];
                //
                //// Skip invalid blocks
                //if (block1.type < 0 || block2.type < 0 || 
                    //block1.falling || block2.falling ||
                    //block1.popping || block2.popping ||
                    //block1.is_big || block2.is_big) {
                    //continue;
                //}
                //
                //// Check for a match if we swap
                //var matchFound = false;
                //
                //// Temporarily swap blocks
                //var tempType = block1.type;
                //block1.type = block2.type;
                //block2.type = tempType;
                //
                //// Check if this creates a match (simplified version - only vertical)
                //if ((row >= min_row + 2 && block1.type == grid[col, row-1].type && block1.type == grid[col, row-2].type) ||
                    //(row <= max_row - 2 && block1.type == grid[col, row+1].type && block1.type == grid[col, row+2].type) ||
                    //(row >= min_row + 1 && row <= max_row - 1 && block1.type == grid[col, row-1].type && block1.type == grid[col, row+1].type) ||
                    //(row >= min_row + 2 && block2.type == grid[col+1, row-1].type && block2.type == grid[col+1, row-2].type) ||
                    //(row <= max_row - 2 && block2.type == grid[col+1, row+1].type && block2.type == grid[col+1, row+2].type) ||
                    //(row >= min_row + 1 && row <= max_row - 1 && block2.type == grid[col+1, row-1].type && block2.type == grid[col+1, row+1].type)) {
                    //
                    //// Now check if there's a potential chain reaction above that would fall into place
                    //var potentialChain = false;
                    //
                    //// Check blocks above that would fall
                    //for (var checkRow = row - 1; checkRow >= min_row; checkRow--) {
                        //var aboveBlock1 = grid[col, checkRow];
                        //var aboveBlock2 = grid[col+1, checkRow];
                        //
                        //// Simple check: if blocks above would form matches when they fall
                        //if (!aboveBlock1.is_big && !aboveBlock1.falling && !aboveBlock1.popping &&
                            //!aboveBlock2.is_big && !aboveBlock2.falling && !aboveBlock2.popping) {
                            //
                            //// Check if these blocks would form new matches after falling
                            //// This is simplified - a full implementation would need to simulate the falling and match logic
                            //if ((col >= 1 && aboveBlock1.type == grid[col-1, checkRow].type) || 
                                //(col+2 < 8 && aboveBlock2.type == grid[col+2, checkRow].type) ||
                                //(checkRow >= min_row + 1 && aboveBlock1.type == grid[col, checkRow-1].type) ||
                                //(checkRow >= min_row + 1 && aboveBlock2.type == grid[col+1, checkRow-1].type)) {
                                //
                                //potentialChain = true;
                                //break;
                            //}
                        //}
                    //}
                    //
                    //if (potentialChain) {
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
                    //return result;
                //}
            //}
        //}
        //
        //return result;
    //}
    //
    //// Evaluate how "good" the current board state is
    //evaluateBoard = function() {
        //var grid = player.grid;
        //var _score = 0;
        //
        //// Look for potential matches
        //var directMatches = 0;
        //var potentialMatches = 0;
        //
        //// Check for direct match opportunities
        //var swapMatch = { found: false };
        //for (var col = 0; col < 7; col++) {
            //for (var row = 4; row <= 20; row++) {
                //// Skip invalid blocks
                //if (grid[col, row].type < 0 || grid[col+1, row].type < 0 || 
                    //grid[col, row].falling || grid[col+1, row].falling ||
                    //grid[col, row].popping || grid[col+1, row].popping ||
                    //grid[col, row].is_big || grid[col+1, row].is_big) {
                    //continue;
                //}
                //
                //// Temporarily swap blocks
                //var tempType = grid[col, row].type;
                //grid[col, row].type = grid[col+1, row].type;
                //grid[col+1, row].type = tempType;
                //
                //// Check for matches
                //var matchFound = false;
                //
                //// Vertical matches for first block
                //if (row >= 6 && grid[col, row].type == grid[col, row-1].type && grid[col, row].type == grid[col, row-2].type) {
                    //matchFound = true;
                //}
                //
                //if (row <= 18 && grid[col, row].type == grid[col, row+1].type && grid[col, row].type == grid[col, row+2].type) {
                    //matchFound = true;
                //}
                //
                //if (row >= 5 && row <= 19 && grid[col, row].type == grid[col, row-1].type && grid[col, row].type == grid[col, row+1].type) {
                    //matchFound = true;
                //}
                //
                //// Vertical matches for second block
                //if (row >= 6 && grid[col+1, row].type == grid[col+1, row-1].type && grid[col+1, row].type == grid[col+1, row-2].type) {
                    //matchFound = true;
                //}
                //
                //if (row <= 18 && grid[col+1, row].type == grid[col+1, row+1].type && grid[col+1, row].type == grid[col+1, row+2].type) {
                    //matchFound = true;
                //}
                //
                //if (row >= 5 && row <= 19 && grid[col+1, row].type == grid[col+1, row-1].type && grid[col+1, row].type == grid[col+1, row+1].type) {
                    //matchFound = true;
                //}
                //
                //// Restore blocks
                //grid[col+1, row].type = grid[col, row].type;
                //grid[col, row].type = tempType;
                //
                //if (matchFound) {
                    //directMatches++;
                    //
                    //// Bonus for matches lower on the board
                    //_score += (row / 20) * 50;
                //}
            //}
        //}
        //
        //// Award points for direct matches
        //_score += directMatches * 100;
        //
        //// Count potential vertical matches (X-X patterns)
        //for (var col = 0; col < 8; col++) {
            //for (var row = 4; row <= 18; row++) {
                //if (grid[col, row].type >= 0 && grid[col, row+2].type >= 0 && 
                    //grid[col, row].type == grid[col, row+2].type &&
                    //!grid[col, row].falling && !grid[col, row+2].falling &&
                    //!grid[col, row].popping && !grid[col, row+2].popping) {
                    //
                    //potentialMatches++;
                    //
                    //// Higher score for potential matches lower on the board
                    //_score += (row / 20) * 25;
                //}
            //}
        //}
        //
        //// Award points for potential matches
        //_score += potentialMatches * 50;
        //
        //// Evaluate board "cleanliness" - fewer colors is better for matching
        //var colorCounts = array_create(11, 0); // Assuming 11 possible block types
        //var distinctColors = 0;
        //
        //for (var col = 0; col < 8; col++) {
            //for (var row = 4; row <= 20; row++) {
                //var blockType = grid[col, row].type;
                //if (blockType >= 0 && blockType <= 10) {
                    //colorCounts[blockType]++;
                //}
            //}
        //}
        //
        //// Count distinct colors
        //for (var i = 0; i < 11; i++) {
            //if (colorCounts[i] > 0) {
                //distinctColors++;
            //}
        //}
        //
        //// Fewer distinct colors is better
        //_score -= distinctColors * 20;
        //
        //// Evaluate stack height - lower stacks are better
        //var stackHeightPenalty = 0;
        //for (var col = 0; col < 8; col++) {
            //var lowestEmptyRow = 20;
            //for (var row = 4; row <= 20; row++) {
                //if (grid[col, row].type == BLOCK.NONE) {
                    //lowestEmptyRow = row;
                    //break;
                //}
            //}
            //
            //// Penalize high stacks
            //stackHeightPenalty += (20 - lowestEmptyRow) * 5;
        //}
        //
        //_score -= stackHeightPenalty;
        //
        //return _score;
    //}
    //
    //// Find horizontal match potentials (where one move creates a match)
    //findHorizontalMatchPotential = function() {
        //var grid = player.grid;
        //var min_row = 4;
        //var max_row = 20;
        //var result = { found: false, from_x: 0, from_y: 0, to_x: 0, to_y: 0 };
        //
        //// Check for patterns like XX_X or X_XX where X is same color and _ is gap
        //for (var row = min_row; row <= max_row; row++) {
            //// Find matches of XX_X type (where _ is the gap)
            //for (var col = 0; col < 5; col++) {
                //var block1 = grid[col, row];
                //var block2 = grid[col+1, row];
                //var block3 = grid[col+3, row];
                //
                //// Check if first, second and fourth blocks are the same color
                //if (block1.type >= 0 && block1.type == block2.type && block1.type == block3.type &&
                    //!block1.falling && !block2.falling && !block3.falling &&
                    //!block1.popping && !block2.popping && !block3.popping) {
                    //
                    //var gapBlock = grid[col+2, row];
                    //
                    //// If gap block can be moved
                    //if (gapBlock.type >= 0 && gapBlock.type != block1.type && 
                        //!gapBlock.falling && !gapBlock.popping && !gapBlock.is_big) {
                        //
                        //// Find a block to swap with this gap
                        //for (var searchCol = 0; searchCol < 8; searchCol++) {
                            //if (abs(searchCol - (col+2)) == 1) { // Must be next to the gap
                                //var swapBlock = grid[searchCol, row];
                                //if (swapBlock.type == block1.type && 
                                    //!swapBlock.falling && !swapBlock.popping && !swapBlock.is_big) {
                                    //
                                    //result.found = true;
                                    //result.from_x = searchCol;
                                    //result.from_y = row;
                                    //result.to_x = col+2;
                                    //result.to_y = row;
                                    //return result;
                                //}
                            //}
                        //}
                    //}
                //}
            //}
            //
            //// Find matches of X_XX type
            //for (var col = 0; col < 5; col++) {
                //var block1 = grid[col, row];
                //var block3 = grid[col+2, row];
                //var block4 = grid[col+3, row];
                //
                //// Check if first, third and fourth blocks are the same color
                //if (block1.type >= 0 && block1.type == block3.type && block1.type == block4.type &&
                    //!block1.falling && !block3.falling && !block4.falling &&
                    //!block1.popping && !block3.popping && !block4.popping) {
                    //
                    //var gapBlock = grid[col+1, row];
                    //
                    //// If gap block can be moved
                    //if (gapBlock.type >= 0 && gapBlock.type != block1.type && 
                        //!gapBlock.falling && !gapBlock.popping && !gapBlock.is_big) {
                        //
                        //// Find a block to swap with this gap
                        //for (var searchCol = 0; searchCol < 8; searchCol++) {
                            //if (abs(searchCol - (col+1)) == 1) { // Must be next to the gap
                                //var swapBlock = grid[searchCol, row];
                                //if (swapBlock.type == block1.type && 
                                    //!swapBlock.falling && !swapBlock.popping && !swapBlock.is_big) {
                                    //
                                    //result.found = true;
                                    //result.from_x = searchCol;
                                    //result.from_y = row;
                                    //result.to_x = col+1;
                                    //result.to_y = row;
                                    //return result;
                                //}
                            //}
                        //}
                    //}
                //}
            //}
        //}
        //
        //return result;
    //}
    //
    //// Find column containing a specific color in a row
    //findColorCol = function(color, row) {
        //var grid = player.grid;
        //
        //for (var col = 0; col < 8; col++) {
            //if (grid[col, row].type == color && !grid[col, row].falling && !grid[col, row].popping) {
                //return col;
            //}
        //}
        //
        //return -1;
    //}
    //
    //// Find blocks that when moved would create a T or L shape (good for combos)
    //findShapeSetup = function() {
        //var grid = player.grid;
        //var min_row = 4;
        //var max_row = 20;
        //var result = { found: false, pos_x: 0, pos_y: 0 };
        //
        //// Search for potential T and L shaped patterns
        //for (var col = 1; col < 6; col++) {
            //for (var row = min_row + 1; row <= max_row - 1; row++) {
                //// Try to find a block that needs to be moved to create a T or L shape
                //
                //// Skip invalid blocks
                //if (grid[col, row].type < 0 || 
                    //grid[col, row].falling || 
                    //grid[col, row].popping || 
                    //grid[col, row].is_big) {
                    //continue;
                //}
                //
                //// Check for T shape potential (horizontal line with middle piece missing)
                //if (col > 0 && col < 7 && 
                    //grid[col-1, row].type >= 0 && grid[col+1, row].type >= 0 && 
                    //grid[col-1, row].type == grid[col+1, row].type &&
                    //grid[col, row].type != grid[col-1, row].type) {
                    //
                    //// Look for the needed piece nearby
                    //for (var searchCol = 0; searchCol < 8; searchCol++) {
                        //if (abs(searchCol - col) == 1) { // Must be adjacent
                            //for (var searchRow = row-1; searchRow <= row+1; searchRow++) {
                                //if (searchRow >= min_row && searchRow <= max_row && searchRow != row) {
                                    //if (grid[searchCol, searchRow].type == grid[col-1, row].type &&
                                        //!grid[searchCol, searchRow].falling &&
                                        //!grid[searchCol, searchRow].popping &&
                                        //!grid[searchCol, searchRow].is_big) {
                                        //
                                        //result.found = true;
                                        //result.pos_x = searchCol;
                                        //result.pos_y = searchRow;
                                        //return result;
                                    //}
                                //}
                            //}
                        //}
                    //}
                //}
                //
                //// Check for L shape potential (two adjacent pieces of same color with one missing)
                //if (row < max_row && col < 7 &&
                    //grid[col, row+1].type >= 0 && grid[col+1, row].type >= 0 &&
                    //grid[col, row+1].type == grid[col+1, row].type &&
                    //grid[col, row].type != grid[col, row+1].type) {
                    //
                    //// Look for the needed piece nearby
                    //for (var searchCol = 0; searchCol < 8; searchCol++) {
                        //if (abs(searchCol - col) <= 1 && searchCol != col) {
                            //for (var searchRow = row-1; searchRow <= row+1; searchRow++) {
                                //if (searchRow >= min_row && searchRow <= max_row && (searchRow != row || searchCol != col)) {
                                    //if (grid[searchCol, searchRow].type == grid[col, row+1].type &&
                                        //!grid[searchCol, searchRow].falling &&
                                        //!grid[searchCol, searchRow].popping &&
                                        //!grid[searchCol, searchRow].is_big) {
                                        //
                                        //result.found = true;
                                        //result.pos_x = searchCol;
                                        //result.pos_y = searchRow;
                                        //return result;
                                    //}
                                //}
                            //}
                        //}
                    //}
                //}
            //}
        //}
        //
        //return result;
    //}
    //
    //// Find a block that can be moved to make blocks fall
    //findStackFlatteningMove = function() {
        //var grid = player.grid;
        //var result = { pos_x: 0, pos_y: 0, dx: 0, dy: 0 };
        //var min_row = 4;  // Top playable row
        //var max_row = 20; // Bottom playable row
        //
        //// Look for blocks that can be moved horizontally to create drops
        //for (var row = max_row; row >= min_row; row--) {
            //for (var col = 0; col < 8; col++) {
                //// Check if this is a valid block that can be moved
                //if (grid[col, row].type >= 0 && !grid[col, row].falling && !grid[col, row].popping && !grid[col, row].is_big) {
                    //// Check left side for potential moves
                    //if (col > 0) {
                        //var found_gap = false;
                        //for (var checkCol = col-1; checkCol >= 0; checkCol--) {
                            //if (grid[checkCol, row].type != BLOCK.NONE) break;
                            //if (row < max_row && grid[checkCol, row+1].type == BLOCK.NONE) {
                                //found_gap = true;
                                //result.pos_x = col;
                                //result.pos_y = row;
                                //result.dx = checkCol;
                                //result.dy = row;
                                //return result;
                            //}
                        //}
                    //}
                    //
                    //// Check right side
                    //if (col < 7) {
                        //var found_gap = false;
                        //for (var checkCol = col+1; checkCol < 8; checkCol++) {
                            //if (grid[checkCol, row].type != BLOCK.NONE) break;
                            //if (row < max_row && grid[checkCol, row+1].type == BLOCK.NONE) {
                                //found_gap = true;
                                //result.pos_x = col;
                                //result.pos_y = row;
                                //result.dx = checkCol;
                                //result.dy = row;
                                //return result;
                            //}
                        //}
                    //}
                //}
            //}
        //}
        //
        //return result;
    //}
    //
    //// Find adjacent blocks that can be swapped to create matches
    //findSwapMatch = function() {
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
                //// Temporarily swap blocks to check for matches
                //var tempType = block1.type;
                //block1.type = block2.type;
                //block2.type = tempType;
                //
                //// Check for vertical matches after swapping
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
                //// For the first block
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
                //// For the second block
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
                    //return result;
                //}
            //}
        //}
        //
        //return result;
    //}
//}