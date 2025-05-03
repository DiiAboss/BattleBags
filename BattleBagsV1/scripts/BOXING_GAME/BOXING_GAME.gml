/// @description Boxing Rhythm Game Constructor with Dynamic Patterns
/// @param {real} _difficulty - Difficulty level (affects timing, pattern complexity)
/// @param {real} _noteSpeed - Speed of notes coming down the screen
function BoxingRhythmGame(_difficulty, _noteSpeed) constructor {
    // Configuration
    difficulty = _difficulty;
    noteSpeed = _noteSpeed;
    
    // Control scheme selection
    // 0 = Keyboard (WASD)
    // 1 = Mouse (Click on lanes)
    controlScheme = 0;
    
    // Upgrade system variables
    upgrades = {
        lighter_gloves: 0,  // 0-3: Increases attack speed
        heavier_gloves: 0,  // 0-3: Increases damage but reduces speed
        turtle_shell: 0,    // 0-3: Makes defense easier but reduces everything else
        headgear: 0,        // 0-3: Reduces damage taken
        footwork: 0         // 0-3: Improves hit timing window
    };
    
    // Game state
    enum BoxingPhase {
        ENEMY_TURN,
        PLAYER_TURN,
        ENEMY_DAZED,
        PLAYER_DAZED,
        PHASE_TRANSITION,
        GAME_OVER
    }
    
    enum HitQuality {
        PERFECT,
        GOOD,
        POOR,
        MISS,
        BLOCKED
    }
    
    enum AttackPattern {
        SEQUENTIAL,    // 1, 2, 3, 4, 1, 2, 3, 4...
        OSCILLATING,   // 1, 2, 3, 4, 3, 2, 1, 2...
        SKIP,          // 1, 3, 2, 4, 1, 3, 2, 4...
        ZIGZAG,        // 1, 4, 2, 3, 1, 4, 2, 3...
        RANDOM         // Random selection
    }
    
    // Current game state
    currentPhase = BoxingPhase.PHASE_TRANSITION;
    phaseMessage = "ENEMY TURN";
    phaseMessageAlpha = 1.0;
    phaseTransitionTimer = 60; // 1 second at 60fps
    
    // Player and enemy stats
    playerHealth = 100;
    enemyHealth = 100 * difficulty;
    playerDazedThreshold = 30; // Damage to cause player to be dazed
    enemyDazedThreshold = 50;  // Damage to cause enemy to be dazed
    playerDamageCounter = 0;   // Tracks damage dealt to player in a turn
    enemyDamageCounter = 0;    // Tracks damage dealt to enemy in a turn
    playerNotes = [];       // Initialize empty arrays to avoid the error
	playerHitResults = [];
	playerAttacks = [];
	barSpacing = 120;  // Vertical spacing between bars (in pixels) - adjust as needed
	
	
	// Set the number of attacks the player can perform consecutively (e.g., 4 attacks per turn)
    for (var i = 0; i < 4; i++) {
        array_push(playerAttacks, {
            lane: i,              // One for each lane (left, right, up, down)
            y: room_height - 30,  // Start at the bottom of the screen
            active: true,         // Bar is active initially
            hitQuality: HitQuality.MISS  // Default quality
        });
    }
	
	
    // Stamina system
    maxStamina = 100;
    stamina = maxStamina;
    staminaRegenRate = 0.3;
    staminaDrainRate = 5;      // Stamina cost per attack/block
    
    // Universal button configuration
    keyboardControls = {
        LEFT: ord("A"),
        DOWN: ord("S"),
        UP: ord("W"),
        RIGHT: ord("D")
    };
    
    // Game layout
    lanes = 4; // LEFT, DOWN, UP, RIGHT
    laneWidth = 80;
    laneSpacing = 10;
    totalLaneWidth = (laneWidth * lanes) + (laneSpacing * (lanes - 1));
    laneStartX = (room_width - totalLaneWidth) / 2;
    laneColors = [c_red, c_blue, c_green, c_yellow]; // Color for each lane
    laneNames = ["LEFT", "DOWN", "UP", "RIGHT"];  // Names for each lane
    
    // Target zone positions
    enemyTargetY = 150;   // Enemy targets at top of screen
    playerTargetY = room_height - 150; // Player targets at bottom of screen
    targetHeight = 40;
    
    // Hit quality zones
    perfectZoneSize = 20;
    goodZoneSize = 40;
    poorZoneSize = 60;
    
    // Note properties
    noteRadius = 30;
    
    // Lane indicators (A, S, W, D or images)
    laneIndicators = ["A", "S", "W", "D"];
    hitBarEffects = [];  // Array to store hit bar visual effects
laneFlashEffects = []; // Array to store lane flash effects
    // Enemy attack variables
    enemyAttackCount = 4;         // Number of attacks per turn
    currentEnemyNotes = [];       // Current enemy attack notes
    enemyHitResults = [];         // Track hit quality for enemy attacks
    
    // Player attack variables
    attackBarY = room_height - 50;    // Starting position of attack bar
    attackBarHeight = 30;             // Height of the attack bar
    attackBarSpeed = 5;               // Speed the bar moves upward
    attackBarActive = false;          // Whether the bar is currently moving
    attackBarHitPosition = -1;        // Which position the player hit (-1 if none)
    attackBarHitQuality = HitQuality.MISS; // Quality of the hit
    playerAttackCounter = 0;          // Count of consecutive attacks
    playerAttackLimit = 4;            // How many consecutive attacks player gets
    
    // Enemy block pattern variables
    blockPatternTimer = 0;            // Timer for changing block pattern
    blockPatternSpeed = 20;           // How quickly block pattern changes (frames)
    enemyBlockedLanes = [];           // Current lanes enemy is blocking
    
    // Attack pattern variables
    currentAttackPattern = AttackPattern.SEQUENTIAL;
    currentAttackPosition = 0;  // Current position in pattern
    attackPatternPositions = []; // Array to hold the pattern sequence
    playerConsecutiveBlocks = 0;  // Track consecutive blocks for counter system
    
    // Visual and audio feedback
    hitEffects = [];
    screenShake = 0;
    combo = 0;                    // Current combo count
    maxCombo = 0;                 // Highest combo achieved
    
    // Apply upgrade effects to game parameters
    applyUpgradeEffects = function() {
        // Reset parameters to base values first
        perfectZoneSize = 20;
        goodZoneSize = 40;
        enemyAttackCount = 4;
        attackBarSpeed = 5;
        blockPatternSpeed = 20;
        
        // Lighter gloves: Improves attack speed
        attackBarSpeed += upgrades.lighter_gloves;
        
        // Heavier gloves: More damage but reduces stamina
        playerDamageMultiplier = 1 + (upgrades.heavier_gloves * 0.3);
        staminaDrainRate = 5 + (upgrades.heavier_gloves * 2);
        
        // Turtle shell: Makes defense easier but reduces everything else
        if (upgrades.turtle_shell > 0) {
            enemyAttackCount = max(2, 4 - upgrades.turtle_shell);
            attackBarSpeed = max(3, attackBarSpeed - upgrades.turtle_shell);
            // Enemy blocks move more slowly with turtle shell
            blockPatternSpeed += (upgrades.turtle_shell * 5);
        }
        
        // Footwork: Improves hit timing window
        perfectZoneSize += (upgrades.footwork * 5);
        goodZoneSize += (upgrades.footwork * 5);
    }
    
    // Generate enemy attack pattern with notes
    generateEnemyAttackPattern = function() {
        currentEnemyNotes = [];
        enemyHitResults = [];
        
        // Apply difficulty and turtle shell effect
        var attackCount = enemyAttackCount + floor(difficulty) - 1;
        
        // Generate attack pattern
        var spacing = 120; // Vertical spacing between notes
        
        for (var i = 0; i < attackCount; i++) {
            // Pick a random lane
            var lane = irandom(lanes - 1);
            
            // Create a note for this attack
            var newNote = {
                lane: lane,
                y: -100 - (i * spacing), // Start above screen with spacing
                radius: noteRadius,
                hit: false,
                processed: false,
                hitQuality: HitQuality.MISS
            };
            
            array_push(currentEnemyNotes, newNote);
            array_push(enemyHitResults, HitQuality.MISS); // Default to miss
        }
    }
    
    // Generate initial enemy blocking lanes
    generateEnemyBlocks = function() {
        enemyBlockedLanes = [];
        
        // Number of blocks increases with difficulty
        var blockCount = 1 + floor(difficulty / 2);
        if (currentPhase == BoxingPhase.ENEMY_DAZED) {
            blockCount = max(1, blockCount - 1); // Fewer blocks while dazed
        }
        
        // Ensure we don't block all lanes
        blockCount = min(blockCount, lanes - 1);
        
        // Generate random blocked lanes
        var availableLanes = [];
        for (var i = 0; i < lanes; i++) {
            availableLanes[i] = i;
        }
        
        for (var i = 0; i < blockCount; i++) {
            var idx = irandom(array_length(availableLanes) - 1);
            var lane = availableLanes[idx];
            array_push(enemyBlockedLanes, lane);
            
            // Remove from available lanes
            array_delete(availableLanes, idx, 1);
        }
        
        // Initialize block pattern timer
        blockPatternTimer = 0;
    }
    
    // Update enemy block pattern
    updateEnemyBlocks = function() {
        // Increment pattern timer
        blockPatternTimer++;
        
        // Change pattern when timer exceeds speed
        if (blockPatternTimer >= blockPatternSpeed) {
            blockPatternTimer = 0;
            
            // Number of blocks increases with difficulty
            var blockCount = 1 + floor(difficulty / 2);
            if (currentPhase == BoxingPhase.ENEMY_DAZED) {
                blockCount = max(1, blockCount - 1); // Fewer blocks while dazed
            }
            
            // Ensure we don't block all lanes
            blockCount = min(blockCount, lanes - 1);
            
            // Update block pattern based on current difficulty
            if (difficulty <= 1) {
                // Easiest: Just rotate blocks by 1 position
                var newBlocks = [];
                for (var i = 0; i < array_length(enemyBlockedLanes); i++) {
                    var newLane = (enemyBlockedLanes[i] + 1) % lanes;
                    array_push(newBlocks, newLane);
                }
                enemyBlockedLanes = newBlocks;
            } else if (difficulty <= 2) {
                // Medium: Random new blocks but keep count the same
                enemyBlockedLanes = [];
                var availableLanes = [];
                for (var i = 0; i < lanes; i++) {
                    availableLanes[i] = i;
                }
                
                for (var i = 0; i < blockCount; i++) {
                    var idx = irandom(array_length(availableLanes) - 1);
                    var lane = availableLanes[idx];
                    array_push(enemyBlockedLanes, lane);
                    
                    // Remove from available lanes
                    array_delete(availableLanes, idx, 1);
                }
            } else {
                // Hard: Random new blocks with random count (at least 1, at most lanes-1)
                enemyBlockedLanes = [];
                var availableLanes = [];
                for (var i = 0; i < lanes; i++) {
                    availableLanes[i] = i;
                }
                
                // Randomize block count between 1 and lanes-1
                blockCount = irandom_range(1, lanes-1);
                
                for (var i = 0; i < blockCount; i++) {
                    var idx = irandom(array_length(availableLanes) - 1);
                    var lane = availableLanes[idx];
                    array_push(enemyBlockedLanes, lane);
                    
                    // Remove from available lanes
                    array_delete(availableLanes, idx, 1);
                }
            }
        }
    }
    
    // Generate attack pattern sequence
    generateAttackPattern = function() {
        // Clear previous pattern
        attackPatternPositions = [];
        
        // Choose pattern type based on difficulty
        var patternOptions = [
            AttackPattern.SEQUENTIAL,
            AttackPattern.OSCILLATING,
            AttackPattern.SKIP,
            AttackPattern.ZIGZAG
        ];
        
        // If difficulty is high enough, add random pattern
        if (difficulty >= 3) {
            array_push(patternOptions, AttackPattern.RANDOM);
        }
        
        // Choose a pattern
        currentAttackPattern = patternOptions[irandom(array_length(patternOptions) - 1)];
        
        // Generate pattern sequence
        switch(currentAttackPattern) {
            case AttackPattern.SEQUENTIAL:
                // 0, 1, 2, 3, 0, 1, 2, 3...
                for (var i = 0; i < 16; i++) {
                    array_push(attackPatternPositions, i % lanes);
                }
                break;
                
            case AttackPattern.OSCILLATING:
                // 0, 1, 2, 3, 2, 1, 0, 1...
                var positions = [];
                for (var i = 0; i < lanes; i++) {
                    array_push(positions, i);
                }
                for (var i = lanes - 2; i > 0; i--) {
                    array_push(positions, i);
                }
                
                for (var i = 0; i < 16; i++) {
                    array_push(attackPatternPositions, positions[i % array_length(positions)]);
                }
                break;
                
            case AttackPattern.SKIP:
                // 0, 2, 1, 3, 0, 2, 1, 3...
                var positions = [0, 2, 1, 3]; // Skip pattern
                for (var i = 0; i < 16; i++) {
                    array_push(attackPatternPositions, positions[i % array_length(positions)]);
                }
                break;
                
            case AttackPattern.ZIGZAG:
                // 0, 3, 1, 2, 0, 3, 1, 2...
                var positions = [0, 3, 1, 2]; // Zigzag pattern
                for (var i = 0; i < 16; i++) {
                    array_push(attackPatternPositions, positions[i % array_length(positions)]);
                }
                break;
                
            case AttackPattern.RANDOM:
                // Random positions
                for (var i = 0; i < 16; i++) {
                    array_push(attackPatternPositions, irandom(lanes - 1));
                }
                break;
        }
        
        // Reset current position
        currentAttackPosition = 0;
    }
    
startAttackBar = function() {
    // Initialize all 4 attack bars at the same time with proper spacing
    playerAttacks = [];  // Reset the array
    
    for (var i = 0; i < playerAttackLimit; i++) {
        // Get position from attack pattern (optional - can use this to determine which lane each bar attacks)
        var pos = attackPatternPositions[(currentAttackPosition + i) % array_length(attackPatternPositions)];
        
        // Create new attack bar with vertical spacing (GML style)
        var attackBar = {};
        attackBar.lane = pos;                  // Lane this bar will hit (based on pattern)
        attackBar.y = room_height + (i * barSpacing); // Start below screen with spacing between bars
        attackBar.active = true;               // Bar is active initially
        attackBar.hitQuality = HitQuality.MISS;// Default quality until hit
        attackBar.processed = false;           // Track if this attack has been processed
        
        array_push(playerAttacks, attackBar);
    }
    
    // Reset counter for tracking completed attacks
    playerAttackCounter = 0;
}
	
// Update all attack bars simultaneously (move them upwards)
updatePlayerAttackBars = function() {
    var allCompleted = true;
    
    for (var i = 0; i < array_length(playerAttacks); i++) {
        var attack = playerAttacks[i];

        if (attack.active) {
            // Move the attack bar upward
            attack.y -= attackBarSpeed;
            allCompleted = false;

            // Auto-miss if the bar goes too far past the target
            if (attack.y < enemyTargetY - poorZoneSize * 2 && !attack.processed) {
                attack.hitQuality = HitQuality.MISS;
                attack.active = false;
                attack.processed = true;
                playerAttackCounter++;
                // Add this line to create the visual effect:
    addHitBarEffect(attack.lane, attack.y, HitQuality.MISS, false);
                // Add miss effect
                var effectX = getLaneX(attack.lane);
                
                // Create miss effect struct the GML way
                var missEffect = {};
                missEffect.x = effectX;
                missEffect.y = enemyTargetY;
                missEffect.frame = 0;
                missEffect.maxFrames = 5;
                missEffect.color = c_red;
                missEffect.text = "MISS!";
                
                array_push(hitEffects, missEffect);
                
                // Reset combo
                combo = 0;
            }
        }
    }
    
    // End turn if all attacks are completed
    if (allCompleted || playerAttackCounter >= playerAttackLimit) {
        processPlayerAttackResults();
    }
}
	
	// Initialize multiple attack bars for the player
initializePlayerAttackBars = function() {
    playerAttacks = [];  // Initialize the array to store player attack bars

    // Create 4 attack bars, one for each lane
    for (var i = 0; i < 4; i++) {
        array_push(playerAttacks, {
            lane: i,              // One attack bar for each lane (0 to 3)
            y: room_height - 30,  // Start at the bottom of the screen
            active: true,         // Bar is active initially
            hitQuality: HitQuality.MISS  // Default hit quality is miss
        });
    }
}
	
	
	
    // Process phase transition
    processPhaseTransition = function() {
        phaseTransitionTimer -= 1;
        phaseMessageAlpha = phaseTransitionTimer / 60; // Fade out
        
        if (phaseTransitionTimer <= 0) {
            // Transition to the next phase
            if (phaseMessage == "ENEMY TURN") {
                currentPhase = BoxingPhase.ENEMY_TURN;
                generateEnemyAttackPattern();
            } else if (phaseMessage == "PLAYER TURN") {
                currentPhase = BoxingPhase.PLAYER_TURN;
                generateEnemyBlocks();
                generateAttackPattern();
                playerConsecutiveBlocks = 0;
                playerAttackCounter = 0;
                startAttackBar(); // Start the attack bar moving
            } else if (phaseMessage == "ENEMY DAZED") {
                currentPhase = BoxingPhase.ENEMY_DAZED;
                generateEnemyBlocks();
                generateAttackPattern();
                playerAttackCounter = 0;
                startAttackBar(); // Start the attack bar moving
            } else if (phaseMessage == "PLAYER DAZED") {
                currentPhase = BoxingPhase.PLAYER_DAZED;
                generateEnemyAttackPattern();
            } else if (phaseMessage == "KO!") {
                currentPhase = BoxingPhase.GAME_OVER;
            }
        }
    }
    
    // Start a phase transition
    startPhaseTransition = function(newPhaseMessage) {
        currentPhase = BoxingPhase.PHASE_TRANSITION;
        phaseMessage = newPhaseMessage;
        phaseTransitionTimer = 60;
        phaseMessageAlpha = 1.0;
    }
    
// Function to calculate hit quality based on the distance from the target zone
calculateHitQuality = function(distanceFromTarget) {
    if (distanceFromTarget <= perfectZoneSize) {
        return HitQuality.PERFECT;
    } else if (distanceFromTarget <= goodZoneSize) {
        return HitQuality.GOOD;
    } else if (distanceFromTarget <= poorZoneSize) {
        return HitQuality.POOR;
    } else {
        return HitQuality.MISS;
    }
}

    // Get x position for a lane
    getLaneX = function(lane) {
        return laneStartX + (lane * (laneWidth + laneSpacing)) + (laneWidth / 2);
    }
    
    // Find the nearest note to the target zone in a specific lane
    findNearestNoteInLane = function(lane, notes) {
        var nearestNote = -1;
        var nearestDistance = 1000000;
        
        for (var i = 0; i < array_length(notes); i++) {
            var note = notes[i];
            if (note.lane == lane && !note.hit && !note.processed) {
                var distance = abs(note.y - playerTargetY);
                if (distance < nearestDistance) {
                    nearestDistance = distance;
                    nearestNote = i;
                }
            }
        }
        
        return nearestNote;
    }
    
    // Handle defense input for a specific lane
    handleDefenseInput = function(lane) {
        var noteIdx = findNearestNoteInLane(lane, currentEnemyNotes);
        
        if (noteIdx != -1) {
            var note = currentEnemyNotes[noteIdx];
            var distanceFromTarget = abs(note.y - playerTargetY);
            
            // Check if note is in hit range
            if (distanceFromTarget <= poorZoneSize) {
                // Calculate hit quality
                var quality = calculateHitQuality(distanceFromTarget);
                note.hitQuality = quality;
                note.hit = true;
                enemyHitResults[noteIdx] = quality;
                
                // Apply visual feedback
                var effectX = getLaneX(lane);
                var hitEffect = {
                    x: effectX,
                    y: playerTargetY,
                    frame: 0,
                    maxFrames: 5,
                    color: c_white,
                    text: ""
                };
                
                // Different color and text based on quality
                if (quality == HitQuality.PERFECT) {
                    hitEffect.color = c_lime;
                    hitEffect.text = "PERFECT!";
                    combo++;
                    
                    // Perfect block leads to counter
                    var counterDamage = 10 * playerDamageMultiplier;
                    enemyHealth -= counterDamage;
                    enemyDamageCounter += counterDamage;
                    screenShake = 5;
                } else if (quality == HitQuality.GOOD) {
                    hitEffect.color = c_green;
                    hitEffect.text = "GOOD!";
                    combo++;
                } else if (quality == HitQuality.POOR) {
                    hitEffect.color = c_orange;
                    hitEffect.text = "POOR";
                    combo = 0;
                    
                    // Poor block means taking some damage
                    playerHealth -= 5;
                    playerDamageCounter += 5;
                }
                
                array_push(hitEffects, hitEffect);
                maxCombo = max(maxCombo, combo);
            }
        }
    }
    
handleAttackInput = function(lane) {
    var hitProcessed = false;
    
    // Check all active attack bars to see if any are in the hit zone
    for (var i = 0; i < array_length(playerAttacks); i++) {
        var attack = playerAttacks[i];
        
        // Only process active, unprocessed attacks
        if (!attack.active || attack.processed) continue;
        
        // Check if this bar is in the target zone
        var distanceFromTarget = abs(attack.y - enemyTargetY);
        
        // Check if we're in range to hit and it's the correct lane
        if (distanceFromTarget <= poorZoneSize && attack.lane == lane) {
            // Check if this lane is blocked by the enemy
            var isBlocked = false;
            for (var j = 0; j < array_length(enemyBlockedLanes); j++) {
                if (enemyBlockedLanes[j] == lane) {
                    isBlocked = true;
                    break;
                }
            }
            
            if (isBlocked) {
                // Attack was blocked
                attack.hitQuality = HitQuality.BLOCKED;
                attack.active = false;
                attack.processed = true;
                playerAttackCounter++;
                // Add this line to create the visual effect:
    addHitBarEffect(lane, attack.y, HitQuality.BLOCKED, true);
                // Increment consecutive blocks counter
                playerConsecutiveBlocks++;
                combo = 0;
                
                // Add blocked effect
                var effectX = getLaneX(lane);
                
                // Create block effect struct the GML way
                var blockEffect = {};
                blockEffect.x = effectX;
                blockEffect.y = enemyTargetY;
                blockEffect.frame = 0;
                blockEffect.maxFrames = 5;
                blockEffect.color = c_red;
                blockEffect.text = "BLOCKED!";
                
                array_push(hitEffects, blockEffect);
                
                // Check for counter opportunity
                if (playerConsecutiveBlocks >= 2) {
                    // Enemy gets a counter after 2 consecutive blocks
                    playerDamageCounter += 15;
                    playerHealth -= 15;
                    
                    // Visual feedback
                    screenShake = 8;
                    
                    // Create counter effect struct the GML way
                    var counterEffect = {};
                    counterEffect.x = room_width/2;
                    counterEffect.y = 150;
                    counterEffect.frame = 0;
                    counterEffect.maxFrames = 5;
                    counterEffect.color = c_red;
                    counterEffect.text = "COUNTER!";
                    
                    array_push(hitEffects, counterEffect);
                    
                    // End player's turn after counter
                    processPlayerAttackResults();
                    return;
                }
            } else {
                // Attack was not blocked, calculate hit quality
                var quality = calculateHitQuality(distanceFromTarget);
                attack.hitQuality = quality;
                attack.active = false;
                attack.processed = true;
                playerAttackCounter++;
                addHitBarEffect(lane, attack.y, quality, false);
                // Reset consecutive blocks
                playerConsecutiveBlocks = 0;
                
                // Calculate damage based on hit quality
                var baseDamage = 0;
                switch (quality) {
                    case HitQuality.PERFECT:
                        baseDamage = 15;
                        combo++;
                        break;
                    case HitQuality.GOOD:
                        baseDamage = 10;
                        combo++;
                        break;
                    case HitQuality.POOR:
                        baseDamage = 5;
                        combo = 0;
                        break;
                    case HitQuality.MISS:
                        baseDamage = 0;
                        combo = 0;
                        break;
                }
                
                // Apply damage multiplier
                var damage = baseDamage * playerDamageMultiplier;
                enemyHealth -= damage;
                enemyDamageCounter += damage;
                
                // Visual feedback
                var effectX = getLaneX(lane);
                
                // In GML, create the struct and then set properties one by one
                var hitEffect = {};
                hitEffect.x = effectX;
                hitEffect.y = enemyTargetY;
                hitEffect.frame = 0;
                hitEffect.maxFrames = 5;
                
                // Set color and text based on quality
                if (quality == HitQuality.PERFECT) {
                    hitEffect.color = c_lime;
                    hitEffect.text = "PERFECT!";
                } else if (quality == HitQuality.GOOD) {
                    hitEffect.color = c_green;
                    hitEffect.text = "GOOD!";
                } else if (quality == HitQuality.POOR) {
                    hitEffect.color = c_orange;
                    hitEffect.text = "POOR";
                } else {
                    hitEffect.color = c_red;
                    hitEffect.text = "MISS!";
                }
                
                array_push(hitEffects, hitEffect);
                
                // Add screen shake for good hits
                if (quality == HitQuality.PERFECT) {
                    screenShake = 5;
                }
                
                // Update max combo
                maxCombo = max(maxCombo, combo);
            }
            
            hitProcessed = true;
            break; // We've processed a hit, no need to check other bars
        }
    }
    
    // Check if all attack bars have been processed
    var allProcessed = true;
    for (var i = 0; i < array_length(playerAttacks); i++) {
        if (!playerAttacks[i].processed) {
            allProcessed = false;
            break;
        }
    }
    
    // If all processed or we've hit the limit, end the turn
    if (allProcessed || playerAttackCounter >= playerAttackLimit) {
        processPlayerAttackResults();
    }
    
    // Check if enemy is dazed from damage
    if (enemyDamageCounter >= enemyDazedThreshold && currentPhase != BoxingPhase.ENEMY_DAZED) {
        // Enemy enters dazed state
        processPlayerAttackResults();
    }
    
    return hitProcessed;
}
	
    // Process enemy attack results
    processEnemyAttackResults = function() {
        var totalDamage = 0;
        
        // Calculate damage based on results
        for (var i = 0; i < array_length(enemyHitResults); i++) {
            var quality = enemyHitResults[i];
            
            // Apply damage based on hit quality
            if (quality == HitQuality.POOR) {
                totalDamage += 10;
            } else if (quality == HitQuality.MISS) {
                totalDamage += 20;
            }
        }
        
        // Apply headgear and turtle shell defense
        var defenseMultiplier = 1 - (upgrades.headgear * 0.15) - (upgrades.turtle_shell * 0.1);
        totalDamage *= defenseMultiplier;
        
        // Apply damage
        playerHealth -= totalDamage;
        playerDamageCounter += totalDamage;
        
        // Check for dazed state
        if (playerDamageCounter >= playerDazedThreshold) {
            startPhaseTransition("PLAYER DAZED");
        } else {
            startPhaseTransition("PLAYER TURN");
        }
        
        // Reset damage counter if not dazed
        if (playerDamageCounter < playerDazedThreshold) {
            playerDamageCounter = 0;
        }
        
        // Reset combo
        combo = 0;
    }
    
    // Check if all enemy notes have been processed
    checkAllEnemyNotesProcessed = function() {
        // Check if all notes have left the screen or been hit
        var allProcessed = true;
        
        for (var i = 0; i < array_length(currentEnemyNotes); i++) {
            var note = currentEnemyNotes[i];
            
            // Auto-miss if note has passed the zone
            if (!note.hit && note.y > playerTargetY + poorZoneSize) {
                note.hitQuality = HitQuality.MISS;
                note.processed = true;
                enemyHitResults[i] = HitQuality.MISS;
                
                // Breaking combo
                combo = 0;
                
                // Add miss effect
                var effectX = getLaneX(note.lane);
                var missEffect = {
                    x: effectX,
                    y: playerTargetY,
                    frame: 0,
                    maxFrames: 5,
                    color: c_red,
                    text: "MISS!"
                };
                array_push(hitEffects, missEffect);
            }
            
            if (!note.hit && !note.processed && note.y <= room_height) {
                allProcessed = false;
            }
        }
        
        return allProcessed;
    }
    
    // Check for input based on control scheme
    checkInput = function() {
        var lanePressed = -1;
        
        if (controlScheme == 0) {
            // Keyboard controls
            if (keyboard_check_pressed(keyboardControls.LEFT)) {
                lanePressed = 0; // Left lane
            } else if (keyboard_check_pressed(keyboardControls.DOWN)) {
                lanePressed = 1; // Down lane
            } else if (keyboard_check_pressed(keyboardControls.UP)) {
                lanePressed = 2; // Up lane
            } else if (keyboard_check_pressed(keyboardControls.RIGHT)) {
                lanePressed = 3; // Right lane
            }
        } else if (controlScheme == 1 && mouse_check_button_pressed(mb_left)) {
            // Mouse controls - check which lane was clicked
            for (var i = 0; i < lanes; i++) {
                var laneX = laneStartX + (i * (laneWidth + laneSpacing));
                
                // Check if clicked in defense zone
                if (mouse_x >= laneX && mouse_x < laneX + laneWidth) {
                    if (currentPhase == BoxingPhase.ENEMY_TURN || currentPhase == BoxingPhase.PLAYER_DAZED) {
                        if (mouse_y >= playerTargetY - targetHeight && mouse_y <= playerTargetY + targetHeight) {
                            lanePressed = i;
                            break;
                        }
                    } else if (currentPhase == BoxingPhase.PLAYER_TURN || currentPhase == BoxingPhase.ENEMY_DAZED) {
                        if (mouse_y >= enemyTargetY - targetHeight && mouse_y <= enemyTargetY + targetHeight) {
                            lanePressed = i;
                            break;
                        }
                    }
                }
            }
        }
        
        return lanePressed;
    }

	
// Function to handle player input for attack
handlePlayerInput = function(lane) {
    // Only process input if it's the player's turn
    if (currentPhase == BoxingPhase.PLAYER_TURN) {
        for (var i = 0; i < array_length(playerAttacks); i++) {
            var attack = playerAttacks[i];

            // If the attack bar is in range and the player presses the correct lane key
            if (attack.active && attack.y <= enemyTargetY && attack.y >= enemyTargetY - 50) {
                if (lane == attack.lane) {
                    // Calculate the hit quality based on distance from target
                    var distanceFromTarget = abs(attack.y - enemyTargetY);
                    attack.hitQuality = calculateHitQuality(distanceFromTarget);
                    processHit(attack.hitQuality);  // Process the result
                } else {
                    // Miss if the player presses the wrong key
                    attack.hitQuality = HitQuality.MISS;
                    processHit(attack.hitQuality);
                }
            }
        }
    }
}
	
// Function to process the hit based on the attack bar's hit quality
processHit = function(hitQuality) {
    switch (hitQuality) {
        case HitQuality.PERFECT:
            // Apply perfect hit logic, such as more damage
            break;
        case HitQuality.GOOD:
            // Apply good hit logic
            break;
        case HitQuality.POOR:
            // Apply poor hit logic, may deal less damage
            break;
        case HitQuality.MISS:
            // Apply miss logic, no damage dealt
            break;
        case HitQuality.BLOCKED:
            // Blocked hit logic, possibly apply damage to the player or other effects
            break;
    }
}
	
// Function to generate player attack pattern with multiple notes
generatePlayerAttackPattern = function() {
    // Clear existing attacks
    playerAttacks = [];
    
    // Create 4 attack notes with proper spacing (like enemy notes)
    var spacing = 100;
    
    for (var i = 0; i < playerAttackLimit; i++) {
        // Get position from attack pattern
        var pos = attackPatternPositions[(currentAttackPosition + i) % array_length(attackPatternPositions)];
        
        // Create new attack note
        var attack = {
            lane: pos,
            y: room_height + (i * spacing),
            radius: noteRadius,
            hit: false,
            processed: false,
            hitQuality: HitQuality.MISS
        };
        
        array_push(playerAttacks, attack);
    }
    
    // Reset counters
    playerAttackCounter = 0;
    playerConsecutiveBlocks = 0;
}

	// 3. Function to update player attack notes
updatePlayerAttacks = function() {
    var allProcessed = true;
    
    // Update each attack note
    for (var i = 0; i < array_length(playerAttacks); i++) {
        var attack = playerAttacks[i];
        
        // Skip processed attacks
        if (attack.processed || attack.hit) continue;
        
        // Move attack note upward
        attack.y -= attackBarSpeed;
        
        // Check if note passed the target zone
        if (attack.y < enemyTargetY - poorZoneSize * 2) {
            attack.processed = true;
            attack.hitQuality = HitQuality.MISS;
            
            // Add miss effect
            var effectX = getLaneX(attack.lane);
            var missEffect = {
                x: effectX,
                y: enemyTargetY,
                frame: 0,
                maxFrames: 5,
                color: c_red,
                text: "MISS!"
            };
            array_push(hitEffects, missEffect);
            
            // Reset combo
            combo = 0;
        }
        
        // Note still active
        if (!attack.processed && !attack.hit) {
            allProcessed = false;
        }
    }
    
    // End turn if all attacks processed
    if (allProcessed) {
        processPlayerAttackResults();
    }
}

// Modify the player attack input handling
handlePlayerAttackInput = function(lane) {
    if (!attackBarActive) return;  // Ensure attack is only processed if bar is active
    
    var distanceFromTarget = abs(attackBarY - enemyTargetY);  // Calculate distance to target zone

    if (distanceFromTarget <= poorZoneSize) {  // Check if we're in range to hit
        var currentPosition = attackPatternPositions[currentAttackPosition];
        
        // Check if the lane is blocked
        if (isBlockedLane(lane)) {
            // Handle block scenario, similar to what you have
            handleBlock(lane);
        } else {
            // Handle hit
            var hitQuality = calculateHitQuality(distanceFromTarget);
            processHit(lane, hitQuality);
            playerAttackCounter++;

            // If player has hit the attack limit, stop further attacks
            if (playerAttackCounter < playerAttackLimit) {
                startAttackBar();  // Start the next attack immediately
                currentAttackPosition = (currentAttackPosition + 1) % array_length(attackPatternPositions);
            } else {
                // End the player's turn
                processPlayerAttackResults();
            }
        }
    }
}

	
	
processPlayerAttackResults = function() {
    // Check if enemy should be dazed
    if (enemyDamageCounter >= enemyDazedThreshold && currentPhase != BoxingPhase.ENEMY_DAZED) {
        startPhaseTransition("ENEMY DAZED");
        return;
    }
    
    // Check if already in dazed state
    if (currentPhase == BoxingPhase.ENEMY_DAZED) {
        // Check if any attacks were blocked (to exit dazed state)
        var anyBlocked = false;
        for (var i = 0; i < array_length(playerAttacks); i++) {
            if (playerAttacks[i].hitQuality == HitQuality.BLOCKED) {
                anyBlocked = true;
                break;
            }
        }
        
        if (anyBlocked) {
            // Exit dazed state
            enemyDamageCounter = 0;
            startPhaseTransition("ENEMY TURN");
        } else {
            // Continue daze with harder blocks
            startPhaseTransition("ENEMY DAZED");
        }
    } else {
        // Normal turn end
        startPhaseTransition("ENEMY TURN");
    }
    
    // Reset damage counter if not dazed
    if (enemyDamageCounter < enemyDazedThreshold && currentPhase != BoxingPhase.ENEMY_DAZED) {
        enemyDamageCounter = 0;
    }
}

drawPlayerAttackBars = function() {
    // Draw enemy blocked lanes first
    for (var i = 0; i < array_length(enemyBlockedLanes); i++) {
        var blockedLane = enemyBlockedLanes[i];
        var laneX = laneStartX + (blockedLane * (laneWidth + laneSpacing)) + (laneWidth / 2);
        
        // Draw block indicator
        draw_set_color(c_red);
        draw_circle(laneX, enemyTargetY, 30, false);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(laneX, enemyTargetY, "X");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    
    // Draw each attack bar
    for (var i = 0; i < array_length(playerAttacks); i++) {
        var attack = playerAttacks[i];
        
        // Skip inactive or processed bars
        if (!attack.active) continue;
        
        // Draw the horizontal bar across all lanes
        draw_set_color(c_white);
        draw_rectangle(laneStartX, attack.y - attackBarHeight/2, 
                      laneStartX + totalLaneWidth, attack.y + attackBarHeight/2, false);
        
        // Draw a marker for the target lane
        var targetLaneX = laneStartX + (attack.lane * (laneWidth + laneSpacing));
        draw_set_color(c_yellow);
        draw_rectangle(targetLaneX, attack.y - attackBarHeight/2, 
                      targetLaneX + laneWidth, attack.y + attackBarHeight/2, true);
    }
}
// Function to update player notes positions
updatePlayerNotes = function() {
    // All notes move upward continuously
    for (var i = 0; i < array_length(playerNotes); i++) {
        var note = playerNotes[i];
        if (!note.hit && !note.processed) {
            // Move note upward
            note.y -= attackBarSpeed;
            
            // Check if note is past the hit zone
            if (note.y < enemyTargetY - poorZoneSize * 2) {
                note.hitQuality = HitQuality.MISS;
                note.processed = true;
                playerHitResults[i] = HitQuality.MISS;
                playerAttackCounter++;
                
                // Add miss effect
                var effectX = getLaneX(note.lane);
                var missEffect = {
                    x: effectX,
                    y: enemyTargetY,
                    frame: 0,
                    maxFrames: 5,
                    color: c_red,
                    text: "MISS!"
                };
                array_push(hitEffects, missEffect);
                
                // Reset combo
                combo = 0;
            }
        }
    }
    
    // Check if all notes are processed and end turn if needed
    if (checkAllPlayerAttacksProcessed()) {
        processPlayerAttackResults();
    }
}

// Function to find the nearest player note to the enemy target zone
findNearestPlayerNote = function(lane) {
    var nearestNoteIdx = -1;
    var nearestDist = 1000000;
    
    for (var i = 0; i < array_length(playerNotes); i++) {
        var note = playerNotes[i];
        if (!note.hit && !note.processed) {
            var dist = abs(note.y - enemyTargetY);
            // Only consider notes that are close to the target zone
            if (dist <= poorZoneSize * 1.5) {
                if (dist < nearestDist) {
                    nearestDist = dist;
                    nearestNoteIdx = i;
                }
            }
        }
    }
    
    return {
        index: nearestNoteIdx,
        distance: nearestDist
    };
}

// Function to check if all player attacks have been processed
checkAllPlayerAttacksProcessed = function() {
    var allProcessed = true;
    
    for (var i = 0; i < array_length(playerNotes); i++) {
        var note = playerNotes[i];
        if (!note.hit && !note.processed) {
            allProcessed = false;
            break;
        }
    }
    
    return allProcessed;
}

// Function to update game during player's turn
updatePlayerTurn = function() {
    // Update note positions
    updatePlayerNotes();
    
    // Update enemy blocks pattern
    updateEnemyBlocks();
    
    // Check for input
    var lanePressed = checkInput();
    if (lanePressed != -1) {
        handleAttackInput(lanePressed);
    }
}

// Drawing functions for player notes
drawPlayerNotes = function() {
    // Draw enemy blocked lanes
    for (var i = 0; i < array_length(enemyBlockedLanes); i++) {
        var blockedLane = enemyBlockedLanes[i];
        var laneX = laneStartX + (blockedLane * (laneWidth + laneSpacing)) + (laneWidth / 2);
        
        // Draw block indicator
        draw_set_color(c_red);
        draw_circle(laneX, enemyTargetY, 30, false);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(laneX, enemyTargetY, "X");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    
    // Draw player notes
    for (var i = 0; i < array_length(playerNotes); i++) {
        var note = playerNotes[i];
        
        // Skip notes that are hit or processed
        if (note.hit || note.processed) continue;
        
        var laneX = laneStartX + (note.lane * (laneWidth + laneSpacing)) + (laneWidth / 2);
        
        // Draw note
        draw_set_color(laneColors[note.lane]);
        draw_circle(laneX, note.y, note.radius, false);
        
        // Draw direction indicator
        draw_set_color(c_black);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(laneX, note.y, laneNames[note.lane]);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}
	
// Function to draw hit bar effects
drawHitBarEffects = function() {
    // Draw lane flash effects first (underneath everything)
    for (var i = 0; i < array_length(laneFlashEffects); i++) {
        var flash = laneFlashEffects[i];
        var laneX = laneStartX + (flash.lane * (laneWidth + laneSpacing));
        
        // Set color and alpha
        draw_set_color(flash.color);
        draw_set_alpha(flash.alpha);
        
        // Draw lane highlight
        draw_rectangle(laneX, 0, laneX + laneWidth, room_height, false);
        
        // Reset alpha
        draw_set_alpha(1.0);
    }
    
    // Draw hit bar effects
    for (var i = 0; i < array_length(hitBarEffects); i++) {
        var effect = hitBarEffects[i];
        
        // Apply shake effect
        var shakeX = 0;
        if (effect.shakeTime > 0) {
            shakeX = random_range(-effect.shakeAmount, effect.shakeAmount);
        }
        
        // Set alpha for fading
        draw_set_alpha(effect.alpha);
        
        // Draw the bar
        var barX = laneStartX + shakeX;
        draw_set_color(c_white);
        draw_rectangle(barX, effect.y - attackBarHeight/2, 
                      barX + totalLaneWidth, effect.y + attackBarHeight/2, false);
        
        // Highlight the lane that was hit
        var hitLaneX = laneStartX + (effect.lane * (laneWidth + laneSpacing)) + shakeX;
        
        // Different color based on hit quality
        if (effect.isBlocked) {
            draw_set_color(c_red);
        } else if (effect.quality == HitQuality.PERFECT) {
            draw_set_color(c_lime);
        } else if (effect.quality == HitQuality.GOOD) {
            draw_set_color(c_green);
        } else if (effect.quality == HitQuality.POOR) {
            draw_set_color(c_orange);
        } else {
            draw_set_color(c_gray);  // For misses
        }
        
        // Draw the highlighted lane
        draw_rectangle(hitLaneX, effect.y - attackBarHeight/2, 
                      hitLaneX + laneWidth, effect.y + attackBarHeight/2, true);
        
        // Draw hit quality text
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        var qualityText = "";
        if (effect.isBlocked) {
            qualityText = "BLOCKED";
        } else if (effect.quality == HitQuality.PERFECT) {
            qualityText = "PERFECT";
        } else if (effect.quality == HitQuality.GOOD) {
            qualityText = "GOOD";
        } else if (effect.quality == HitQuality.POOR) {
            qualityText = "POOR";
        } else {
            qualityText = "MISS";
        }
        
        // Draw text centered on the bar
        draw_text(barX + totalLaneWidth/2, effect.y, qualityText);
        
        // Reset alignment
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        
        // Reset alpha
        draw_set_alpha(1.0);
    }
}
    
	// Function to update hit bar effects animation
updateHitBarEffects = function() {
    // Update each hit bar effect
    for (var i = 0; i < array_length(hitBarEffects); i++) {
        var effect = hitBarEffects[i];
        
        // Update position (toss effect)
        effect.y += effect.speed;
        effect.speed += 0.5;  // Add gravity to create an arc motion
        
        // Update shake timer
        if (effect.shakeTime > 0) {
            effect.shakeTime--;
        }
        
        // Update lifespan and alpha
        effect.lifespan--;
        effect.alpha = effect.lifespan / 30;  // Fade out gradually
        
        // Remove if expired
        if (effect.lifespan <= 0) {
            array_delete(hitBarEffects, i, 1);
            i--;  // Adjust index since we removed an item
        }
    }
    
    // Update lane flash effects
    for (var i = 0; i < array_length(laneFlashEffects); i++) {
        var flash = laneFlashEffects[i];
        
        // Update lifespan and alpha
        flash.lifespan--;
        flash.alpha = flash.lifespan / 15;  // Fade out gradually
        
        // Remove if expired
        if (flash.lifespan <= 0) {
            array_delete(laneFlashEffects, i, 1);
            i--;  // Adjust index since we removed an item
        }
    }
}
	
	// Function to add a hit bar effect when a bar is hit
addHitBarEffect = function(lane, y, quality, isBlocked) {
    // Create a new hit bar effect
    var effect = {
    lane: lane,              // Which lane was hit
    y: y,                  // Vertical position of the hit
    quality: quality,        // Hit quality (PERFECT, GOOD, POOR, etc.)
    isBlocked:isBlocked,      // Whether this was blocked
    alpha: 1.0,                // Start fully visible
    shakeTime: 10,            // Number of frames to shake
    shakeAmount: 0,           // Amount of shake (set below)
    speed: 0,                  // Vertical movement speed (set below)
    lifespan: 30,              // How long the effect lasts
	}
	
	
    // Set shake amount based on quality (better hits shake more)
    if (quality == HitQuality.PERFECT) {
        effect.shakeAmount = 6;        // Shake a lot for perfect hits
    } else if (quality == HitQuality.GOOD) {
        effect.shakeAmount = 4;        // Medium shake for good hits
    } else {
        effect.shakeAmount = 2;        // Slight shake for other hits
    }
    
    // Set upward speed based on quality (better hits move faster)
    if (quality == HitQuality.PERFECT) {
        effect.speed = -8;             // Fast upward movement
    } else if (quality == HitQuality.GOOD) {
        effect.speed = -6;             // Medium upward movement
    } else {
        effect.speed = -4;             // Slow upward movement
    }
    
    // Add the effect to our effects array
    array_push(hitBarEffects, effect);
    
    // Now create a lane flash effect to highlight the lane
    var flash = {
    lane: lane,                 // Which lane to highlight
    alpha: 0.7,                 // Starting opacity
    lifespan: 15,    // How long the flash lasts
	}
    // Set flash color based on hit quality
    if (isBlocked) {
        flash.color = c_red;           // Red for blocked hits
    } else if (quality == HitQuality.PERFECT) {
        flash.color = c_lime;          // Bright green for perfect hits
    } else if (quality == HitQuality.GOOD) {
        flash.color = c_green;         // Green for good hits
    } else if (quality == HitQuality.POOR) {
        flash.color = c_orange;        // Orange for poor hits
    } else {
        flash.color = c_gray;          // Gray for misses
    }
    
    // Add the flash effect to our flash effects array
    array_push(laneFlashEffects, flash);
}
	
    // Update note positions
    updateNotes = function() {
        // Update enemy notes
        for (var i = 0; i < array_length(currentEnemyNotes); i++) {
            var note = currentEnemyNotes[i];
            if (!note.hit && !note.processed) {
                note.y += noteSpeed;
            }
        }
        
        // Update attack bar position if active
        if (attackBarActive) {
            attackBarY -= attackBarSpeed;
            
            // Check if bar has gone too far
            if (attackBarY < enemyTargetY - poorZoneSize * 2) {
                // Auto-miss if we went past the target
                attackBarHitPosition = attackPatternPositions[currentAttackPosition];
                attackBarHitQuality = HitQuality.MISS;
                attackBarActive = false;
                
                // Add miss effect
                var effectX = getLaneX(attackPatternPositions[currentAttackPosition]);
                var missEffect = {
                    x: effectX,
                    y: enemyTargetY,
                    frame: 0,
                    maxFrames: 5,
                    color: c_red,
                    text: "MISS!"
                };
                array_push(hitEffects, missEffect);
                
                // Reset combo
                combo = 0;
                
                // Increment attack counter
                playerAttackCounter++;
                
                // If we've reached the attack limit, end the turn
                if (playerAttackCounter >= playerAttackLimit) {
                    processPlayerAttackResults();
                } else {
                    // Start another attack if not at limit
                    startAttackBar();
                    currentAttackPosition = (currentAttackPosition + 1) % array_length(attackPatternPositions);
                }
            }
        }
        
        // Update enemy blocks pattern when in player turn or enemy dazed
        if (currentPhase == BoxingPhase.PLAYER_TURN || currentPhase == BoxingPhase.ENEMY_DAZED) {
            updateEnemyBlocks();
        }
    }
    
    // Main update function - call this in the Step event
    update = function() {
        // Reduce screen shake
        if (screenShake > 0) screenShake -= 0.5;
        
        // Update hit effects
        for (var i = 0; i < array_length(hitEffects); i++) {
            hitEffects[i].frame += 0.2;
            if (hitEffects[i].frame >= hitEffects[i].maxFrames) {
                array_delete(hitEffects, i, 1);
                i--;
            }
        }
        
		updateHitBarEffects();
		
        // Check for game over
        if (playerHealth <= 0 || enemyHealth <= 0) {
            if (currentPhase != BoxingPhase.GAME_OVER) {
                startPhaseTransition("KO!");
            }
            return "ongoing"; // Let the phase transition play out
        }
        
        // Phase-specific updates
        switch (currentPhase) {
            case BoxingPhase.PHASE_TRANSITION:
                processPhaseTransition();
                break;
                
            case BoxingPhase.ENEMY_TURN:
            case BoxingPhase.PLAYER_DAZED:
                // Update enemy note positions
                updateNotes();
                
                // Check for input
                var lanePressed = checkInput();
                if (lanePressed != -1) {
                    handleDefenseInput(lanePressed);
                }
                
                // Check if all notes have been processed
                if (checkAllEnemyNotesProcessed()) {
                    processEnemyAttackResults();
                }
                break;
                
            case BoxingPhase.PLAYER_TURN:
            case BoxingPhase.ENEMY_DAZED:

                 updatePlayerAttackBars();
				updateEnemyBlocks();
				
				// Check for input
				var lanePressed = checkInput();
				if (lanePressed != -1) {
					handleAttackInput(lanePressed);
				}
				break;
                
            case BoxingPhase.GAME_OVER:
                return (playerHealth > 0) ? "win" : "lose";
                break;
        }
        
        return "ongoing";
    }
    
    // Draw function using primitive draw functions - call this in the Draw event
    draw = function() {
        var centerX = room_width / 2;
        
        // Apply screen shake
        var shakeX = irandom_range(-screenShake, screenShake);
        var shakeY = irandom_range(-screenShake, screenShake);
        
        // Draw background
        draw_set_color(c_dkgray);
        draw_rectangle(0, 0, room_width, room_height, false);
        
		// Draw lane flash effects (lighting up the lanes when hit)
    drawHitBarEffects();  // THIS IS THE NEW LINE ADDED
		
        // Draw lanes
        for (var i = 0; i < lanes; i++) {
            var laneX = laneStartX + (i * (laneWidth + laneSpacing));
            
            // Lane background
            draw_set_color(c_black);
            draw_rectangle(laneX, 0, laneX + laneWidth, room_height, false);
            
            // Lane border
            draw_set_color(laneColors[i]);
            draw_rectangle(laneX, 0, laneX + laneWidth, room_height, true);
            
            // Draw lane separator lines
            draw_set_color(c_white);
            draw_set_alpha(0.3);
            draw_line(laneX, 0, laneX, room_height);
            draw_line(laneX + laneWidth, 0, laneX + laneWidth, room_height);
            draw_set_alpha(1.0);
        }
        
        // Draw player's target zone at bottom
        drawTargetZone(playerTargetY);
        
        // Draw enemy's target zone at top
        drawTargetZone(enemyTargetY);
        
        // Draw enemy
        draw_set_color(c_red);
        draw_ellipse(centerX - 50 + shakeX, 50 + shakeY, centerX + 50 + shakeX, 150 + shakeY, false);
        
        // Draw player
        draw_set_color(c_blue);
        draw_ellipse(centerX - 50 + shakeX, room_height - 150 + shakeY, centerX + 50 + shakeX, room_height - 50 + shakeY, false);
        
        // Draw health and stamina bars at top of screen
        var barWidth = 200;
        var barHeight = 20;
        
        // Player health bar
        draw_set_color(c_black);
        draw_rectangle(50, 30, 50 + barWidth, 30 + barHeight, false);
        draw_set_color(c_lime);
        draw_rectangle(50, 30, 50 + (barWidth * playerHealth / 100), 30 + barHeight, false);
        draw_set_color(c_white);
        draw_rectangle(50, 30, 50 + barWidth, 30 + barHeight, true);
        draw_text(50, 10, "Player Health: " + string(floor(playerHealth)));
        
        // Enemy health bar
        draw_set_color(c_black);
        draw_rectangle(room_width - 50 - barWidth, 30, room_width - 50, 30 + barHeight, false);
        draw_set_color(c_lime);
        draw_rectangle(room_width - 50 - barWidth, 30, room_width - 50 - barWidth + (barWidth * enemyHealth / (100 * difficulty)), 30 + barHeight, false);
        draw_set_color(c_white);
        draw_rectangle(room_width - 50 - barWidth, 30, room_width - 50, 30 + barHeight, true);
        draw_text(room_width - 50 - barWidth, 10, "Enemy Health: " + string(floor(enemyHealth)));
        
        // Stamina bar
        draw_set_color(c_black);
        draw_rectangle(50, 60, 50 + barWidth, 60 + barHeight, false);
        
        // Determine stamina bar color based on value
        if (stamina > 70) draw_set_color(c_blue);
        else if (stamina > 30) draw_set_color(c_orange);
        else draw_set_color(c_red);
        
        draw_rectangle(50, 60, 50 + (barWidth * stamina / maxStamina), 60 + barHeight, false);
        draw_set_color(c_white);
        draw_rectangle(50, 60, 50 + barWidth, 60 + barHeight, true);
        draw_text(50, 85, "Stamina: " + string(floor(stamina)));
        
        // Draw combo counter
        draw_set_color(c_yellow);
        draw_set_halign(fa_right);
        draw_text(room_width - 50, 60, "Combo: " + string(combo));
        draw_text(room_width - 50, 80, "Max Combo: " + string(maxCombo));
        draw_set_halign(fa_left);
        
        // Draw phase-specific elements
        switch (currentPhase) {
            case BoxingPhase.PHASE_TRANSITION:
                // Draw phase message with fade
                draw_set_color(c_yellow);
                draw_set_alpha(phaseMessageAlpha);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text_transformed(centerX, room_height / 2, phaseMessage, 2, 2, 0);
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
                draw_set_alpha(1.0);
                break;
                
            case BoxingPhase.ENEMY_TURN:
            case BoxingPhase.PLAYER_DAZED:
                // Draw enemy notes coming down
                for (var i = 0; i < array_length(currentEnemyNotes); i++) {
                    var note = currentEnemyNotes[i];
                    
                    // Skip notes that are hit or off screen
                    if (note.hit || note.y < 0 || note.y > room_height) continue;
                    
                    // Draw note
                    var laneX = laneStartX + (note.lane * (laneWidth + laneSpacing)) + (laneWidth / 2);
                    
                    // Different colors based on hit quality
                    var noteColor = laneColors[note.lane];
                    if (note.hitQuality == HitQuality.PERFECT) noteColor = c_lime;
                    else if (note.hitQuality == HitQuality.GOOD) noteColor = c_green;
                    else if (note.hitQuality == HitQuality.POOR) noteColor = c_orange;
                    else if (note.hitQuality == HitQuality.MISS && note.processed) noteColor = c_red;
                    
                    draw_set_color(noteColor);
                    draw_circle(laneX + shakeX, note.y + shakeY, note.radius, false);
                    
                    // Draw direction indicator
                    draw_set_color(c_black);
                    draw_set_halign(fa_center);
                    draw_set_valign(fa_middle);
                    draw_text(laneX + shakeX, note.y + shakeY, laneNames[note.lane]);
                    draw_set_halign(fa_left);
                    draw_set_valign(fa_top);
                }
                
                // Draw current phase info
                draw_set_halign(fa_center);
                if (currentPhase == BoxingPhase.PLAYER_DAZED) {
                    draw_set_color(c_red);
                    draw_text(centerX, room_height - 200, "DAZED! Block to survive!");
                } else {
                    draw_set_color(c_yellow);
                    draw_text(centerX, room_height - 200, "Enemy attacking: Block!");
                }
                draw_set_halign(fa_left);
                break;
                
            case BoxingPhase.PLAYER_TURN:
            case BoxingPhase.ENEMY_DAZED:
                // Draw enemy blocked lanes
                for (var i = 0; i < array_length(enemyBlockedLanes); i++) {
                    var blockedLane = enemyBlockedLanes[i];
                    var laneX = laneStartX + (blockedLane * (laneWidth + laneSpacing)) + (laneWidth / 2);
                    
                    // Draw block indicator
                    draw_set_color(c_red);
                    draw_circle(laneX, enemyTargetY, 30, false);
                    draw_set_color(c_white);
                    draw_set_halign(fa_center);
                    draw_set_valign(fa_middle);
                    draw_text(laneX, enemyTargetY, "X");
                    draw_set_halign(fa_left);
                    draw_set_valign(fa_top);
                }
                
               drawPlayerAttackBars();
                
                // Draw current phase info
                draw_set_halign(fa_center);
                if (currentPhase == BoxingPhase.ENEMY_DAZED) {
                    draw_set_color(c_lime);
                    draw_text(centerX, room_height - 200, "ENEMY DAZED! Keep attacking!");
                } else {
                    draw_set_color(c_yellow);
                    draw_text(centerX, room_height - 200, "Your turn: Attack through openings!");
                }
                draw_set_halign(fa_left);
                
                // Draw attack pattern info
                var patternName = "";
                switch(currentAttackPattern) {
                    case AttackPattern.SEQUENTIAL: patternName = "Sequential"; break;
                    case AttackPattern.OSCILLATING: patternName = "Oscillating"; break;
                    case AttackPattern.SKIP: patternName = "Skip"; break;
                    case AttackPattern.ZIGZAG: patternName = "Zigzag"; break;
                    case AttackPattern.RANDOM: patternName = "Random"; break;
                }
                draw_text(50, 110, "Attack Pattern: " + patternName);
                
                // Draw attack counter
                draw_text(50, 130, "Attacks: " + string(playerAttackCounter) + "/" + string(playerAttackLimit));
                
                // Draw consecutive blocks counter
                if (playerConsecutiveBlocks > 0) {
                    draw_set_color(c_red);
                    draw_text(50, 150, "Blocked: " + string(playerConsecutiveBlocks) + "/2 (Counter at 2)");
                }
                break;
                
            case BoxingPhase.GAME_OVER:
                // Draw game over message
                draw_set_color(playerHealth > 0 ? c_lime : c_red);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text_transformed(centerX, room_height / 2, playerHealth > 0 ? "YOU WIN!" : "KO! YOU LOSE!", 2, 2, 0);
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
                break;
        }
        
        // Draw hit effects
        for (var i = 0; i < array_length(hitEffects); i++) {
            var effect = hitEffects[i];
            
            // Draw circle effect
            draw_set_color(effect.color);
            var size = 30 - (effect.frame * 5);
            if (size > 0) {
                draw_circle(effect.x + shakeX, effect.y + shakeY, size, false);
            }
            
            // Draw text if present
            if (effect.text != "") {
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                var textScale = 1.0 + (1.0 - effect.frame / 5) * 0.5;
                var textAlpha = 1.0 - (effect.frame / 5);
                draw_set_alpha(textAlpha);
                draw_text_transformed(effect.x + shakeX, effect.y - 40 + shakeY, effect.text, textScale, textScale, 0);
                draw_set_alpha(1.0);
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
            }
        }
        
        // Draw control scheme info
        draw_set_color(c_white);
        var schemeText = (controlScheme == 0) ? "Controls: Keyboard (WASD)" : "Controls: Mouse";
        draw_text(centerX - 100, 10, schemeText);
    }
    
    // Draw target zone with perfect/good/poor indicators
    drawTargetZone = function(y_pos) {
        for (var i = 0; i < lanes; i++) {
            var laneX = laneStartX + (i * (laneWidth + laneSpacing));
            
            // Target background
            draw_set_color(c_dkgray);
            draw_rectangle(laneX, y_pos - targetHeight/2, laneX + laneWidth, y_pos + targetHeight/2, false);
            
            // Target border
            draw_set_color(c_white);
            draw_rectangle(laneX, y_pos - targetHeight/2, laneX + laneWidth, y_pos + targetHeight/2, true);
            
            // Perfect zone
            draw_set_color(c_lime);
            draw_set_alpha(0.3);
            draw_rectangle(laneX, y_pos - perfectZoneSize/2, laneX + laneWidth, y_pos + perfectZoneSize/2, false);
            
            // Good zone
            draw_set_color(c_green);
            draw_set_alpha(0.2);
            draw_rectangle(laneX, y_pos - goodZoneSize/2, laneX + laneWidth, y_pos + goodZoneSize/2, false);
            
            // Lane indicator
            draw_set_alpha(1.0);
            draw_set_color(laneColors[i]);
            draw_circle(laneX + laneWidth/2, y_pos, 25, false);
            draw_set_color(c_black);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(laneX + laneWidth/2, y_pos, laneIndicators[i]);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
    
    // Testing console GUI function - call this to show the upgrade testing panel
    drawTestConsole = function(x, y) {
        var consoleWidth = 350;
        var consoleHeight = 450;
        var padding = 10;
        
        // Draw console background
        draw_set_color(c_black);
        draw_set_alpha(0.8);
        draw_rectangle(x, y, x + consoleWidth, y + consoleHeight, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_rectangle(x, y, x + consoleWidth, y + consoleHeight, true);
        
        // Draw title
        draw_set_halign(fa_center);
        draw_text(x + consoleWidth / 2, y + padding, "BOXING TEST CONSOLE");
        
        // Draw current settings
        draw_set_halign(fa_left);
        draw_text(x + padding, y + padding * 3, "Difficulty: " + string(difficulty));
        draw_text(x + padding, y + padding * 5, "Note Speed: " + string(noteSpeed));
        draw_text(x + padding, y + padding * 7, "Block Pattern Speed: " + string(blockPatternSpeed));
        draw_text(x + padding, y + padding * 9, "Current Phase: " + string(currentPhase));
        
        // Control scheme selection
        draw_text(x + padding, y + padding * 11, "CONTROL SCHEME:");
        
        // Control scheme buttons
        var schemeY = y + padding * 13;
        var btnWidth = 160;
        var btnHeight = 25;
        var btnSpacing = 10;
        
        // Keyboard button
        draw_set_color(controlScheme == 0 ? c_lime : c_gray);
        draw_rectangle(x + padding, schemeY, x + padding + btnWidth, schemeY + btnHeight, false);
        draw_set_color(c_black);
        draw_set_halign(fa_center);
        draw_text(x + padding + btnWidth/2, schemeY + btnHeight/2, "Keyboard (WASD)");
        
        // Mouse button
        draw_set_color(controlScheme == 1 ? c_lime : c_gray);
        draw_rectangle(x + padding + btnWidth + btnSpacing, schemeY, x + padding + btnWidth*2 + btnSpacing, schemeY + btnHeight, false);
        draw_set_color(c_black);
        draw_text(x + padding + btnWidth*1.5 + btnSpacing, schemeY + btnHeight/2, "Mouse");
        
        // Draw upgrades and buttons to adjust them
        var startY = y + padding * 16;
        var lineHeight = 25;
        
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_text(x + padding, startY, "UPGRADES:");
        startY += lineHeight;
        
        // Upgrade: Lighter Gloves
        draw_text(x + padding, startY, "Lighter Gloves: " + string(upgrades.lighter_gloves) + "/3");
        // Minus button
        draw_set_color(c_gray);
        draw_rectangle(x + consoleWidth - 80, startY, x + consoleWidth - 60, startY + 20, false);
        draw_set_color(c_black);
        draw_text(x + consoleWidth - 70, startY + 10, "-");
        // Plus button
        draw_set_color(c_gray);
        draw_rectangle(x + consoleWidth - 50, startY, x + consoleWidth - 30, startY + 20, false);
        draw_set_color(c_black);
        draw_text(x + consoleWidth - 40, startY + 10, "+");
        draw_set_color(c_white);
        startY += lineHeight;
        
        // Upgrade: Heavier Gloves
        draw_text(x + padding, startY, "Heavier Gloves: " + string(upgrades.heavier_gloves) + "/3");
        // Minus button
        draw_set_color(c_gray);
        draw_rectangle(x + consoleWidth - 80, startY, x + consoleWidth - 60, startY + 20, false);
        draw_set_color(c_black);
        draw_text(x + consoleWidth - 70, startY + 10, "-");
        // Plus button
        draw_set_color(c_gray);
        draw_rectangle(x + consoleWidth - 50, startY, x + consoleWidth - 30, startY + 20, false);
        draw_set_color(c_black);
        draw_text(x + consoleWidth - 40, startY + 10, "+");
        draw_set_color(c_white);
        startY += lineHeight;
        
        // Upgrade: Turtle Shell
        draw_text(x + padding, startY, "Turtle Shell: " + string(upgrades.turtle_shell) + "/3");
        // Minus button
        draw_set_color(c_gray);
        draw_rectangle(x + consoleWidth - 80, startY, x + consoleWidth - 60, startY + 20, false);
        draw_set_color(c_black);
        draw_text(x + consoleWidth - 70, startY + 10, "-");
        // Plus button
        draw_set_color(c_gray);
        draw_rectangle(x + consoleWidth - 50, startY, x + consoleWidth - 30, startY + 20, false);
        draw_set_color(c_black);
        draw_text(x + consoleWidth - 40, startY + 10, "+");
        draw_set_color(c_white);
        startY += lineHeight;
        
        // Upgrade: Headgear
        draw_text(x + padding, startY, "Headgear: " + string(upgrades.headgear) + "/3");
        // Minus button
        draw_set_color(c_gray);
        draw_rectangle(x + consoleWidth - 80, startY, x + consoleWidth - 60, startY + 20, false);
        draw_set_color(c_black);
        draw_text(x + consoleWidth - 70, startY + 10, "-");
        // Plus button
        draw_set_color(c_gray);
        draw_rectangle(x + consoleWidth - 50, startY, x + consoleWidth - 30, startY + 20, false);
        draw_set_color(c_black);
        draw_text(x + consoleWidth - 40, startY + 10, "+");
        draw_set_color(c_white);
        startY += lineHeight;
        
        // Upgrade: Footwork
        draw_text(x + padding, startY, "Footwork: " + string(upgrades.footwork) + "/3");
        // Minus button
        draw_set_color(c_gray);
        draw_rectangle(x + consoleWidth - 80, startY, x + consoleWidth - 60, startY + 20, false);
        draw_set_color(c_black);
        draw_text(x + consoleWidth - 70, startY + 10, "-");
        // Plus button
        draw_set_color(c_gray);
        draw_rectangle(x + consoleWidth - 50, startY, x + consoleWidth - 30, startY + 20, false);
        draw_set_color(c_black);
        draw_text(x + consoleWidth - 40, startY + 10, "+");
        draw_set_color(c_white);
        startY += lineHeight * 1.5;
        
        // Apply changes button
        draw_set_color(c_green);
        draw_rectangle(x + padding, startY, x + consoleWidth - padding, startY + 30, false);
        draw_set_color(c_black);
        draw_set_halign(fa_center);
        draw_text(x + consoleWidth / 2, startY + 15, "APPLY CHANGES");
        
        // Reset game button
        startY += lineHeight * 1.5;
        draw_set_color(c_blue);
        draw_rectangle(x + padding, startY, x + consoleWidth - padding, startY + 30, false);
        draw_set_color(c_white);
        draw_text(x + consoleWidth / 2, startY + 15, "RESET GAME");
        
        // Reset color and alignment
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        
        // Draw debug info
        startY += lineHeight * 2;
        draw_text(x + padding, startY, "Player Damage Counter: " + string(playerDamageCounter) + "/" + string(playerDazedThreshold));
        startY += lineHeight;
        draw_text(x + padding, startY, "Enemy Damage Counter: " + string(enemyDamageCounter) + "/" + string(enemyDazedThreshold));
        startY += lineHeight;
        draw_text(x + padding, startY, "Combo: " + string(combo) + " (Max: " + string(maxCombo) + ")");
    }
    
	// Add this to your draw function in the player turn section
drawPlayerAttackBars = function() {
    // Draw enemy blocked lanes first
    for (var i = 0; i < array_length(enemyBlockedLanes); i++) {
        var blockedLane = enemyBlockedLanes[i];
        var laneX = laneStartX + (blockedLane * (laneWidth + laneSpacing)) + (laneWidth / 2);
        
        // Draw block indicator
        draw_set_color(c_red);
        draw_circle(laneX, enemyTargetY, 30, false);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(laneX, enemyTargetY, "X");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    
    // Draw each attack bar
    for (var i = 0; i < array_length(playerAttacks); i++) {
        var attack = playerAttacks[i];
        
        // Skip inactive or processed bars
        if (!attack.active) continue;
        
        // Draw the horizontal bar across all lanes
        draw_set_color(c_white);
        draw_rectangle(laneStartX, attack.y - attackBarHeight/2, 
                      laneStartX + totalLaneWidth, attack.y + attackBarHeight/2, false);
        
        // Draw a marker for the target lane
        var targetLaneX = laneStartX + (attack.lane * (laneWidth + laneSpacing));
        draw_set_color(c_yellow);
        draw_rectangle(targetLaneX, attack.y - attackBarHeight/2, 
                      targetLaneX + laneWidth, attack.y + attackBarHeight/2, true);
    }
}
	
	
    // Function to check mouse clicks in the test console
    checkTestConsoleInput = function(x, y) {
        if (!mouse_check_button_pressed(mb_left)) return;
        
        var consoleWidth = 350;
        var padding = 10;
        var btnWidth = 160;
        var btnHeight = 25;
        var btnSpacing = 10;
        
        // Check control scheme buttons
        var schemeY = y + padding * 13;
        
        // Keyboard button
        if (point_in_rectangle(mouse_x, mouse_y, x + padding, schemeY, x + padding + btnWidth, schemeY + btnHeight)) {
            controlScheme = 0;
        }
        
        // Mouse button
        if (point_in_rectangle(mouse_x, mouse_y, x + padding + btnWidth + btnSpacing, schemeY, 
                              x + padding + btnWidth*2 + btnSpacing, schemeY + btnHeight)) {
            controlScheme = 1;
        }
        
        // Check upgrade buttons
        var startY = y + padding * 16;
        var lineHeight = 25;
        
        // Skip the title line
        startY += lineHeight;
        
        // Check upgrade buttons
        var upgradesToCheck = ["lighter_gloves", "heavier_gloves", "turtle_shell", "headgear", "footwork"];
        
        for (var i = 0; i < array_length(upgradesToCheck); i++) {
            var currentY = startY + (lineHeight * i);
            
            // Check minus button
            if (point_in_rectangle(mouse_x, mouse_y, x + consoleWidth - 80, currentY, x + consoleWidth - 60, currentY + 20)) {
                var upgradeValue = variable_struct_get(upgrades, upgradesToCheck[i]);
                if (upgradeValue > 0) {
                    variable_struct_set(upgrades, upgradesToCheck[i], upgradeValue - 1);
                }
            }
            
            // Check plus button
            if (point_in_rectangle(mouse_x, mouse_y, x + consoleWidth - 50, currentY, x + consoleWidth - 30, currentY + 20)) {
                var upgradeValue = variable_struct_get(upgrades, upgradesToCheck[i]);
                if (upgradeValue < 3) {
                    variable_struct_set(upgrades, upgradesToCheck[i], upgradeValue + 1);
                }
            }
        }
        
        // Check apply changes button
        var applyY = startY + (lineHeight * (array_length(upgradesToCheck) + 1.5));
        if (point_in_rectangle(mouse_x, mouse_y, x + padding, applyY, x + consoleWidth - padding, applyY + 30)) {
            applyUpgradeEffects();
        }
        
        // Check reset game button
        var resetY = applyY + lineHeight * 1.5;
        if (point_in_rectangle(mouse_x, mouse_y, x + padding, resetY, x + consoleWidth - padding, resetY + 30)) {
            resetGame();
        }
    }
    
    // Set control scheme
    setControlScheme = function(scheme) {
        controlScheme = scheme;
    }
    
    // Reset the game
    resetGame = function() {
        playerHealth = 100;
        enemyHealth = 100 * difficulty;
        playerDamageCounter = 0;
        enemyDamageCounter = 0;
        combo = 0;
        maxCombo = 0;
        startPhaseTransition("ENEMY TURN");
    }
    
    // Initialize the game
    applyUpgradeEffects();
    startPhaseTransition("ENEMY TURN");
}

// Example of how to create and use the boxing minigame in a game object:
/*
// Create event
boxing = new BoxingRhythmGame(1, 5); // Difficulty 1, Note speed 5

// Step event
var result = boxing.update();
if (result == "win") {
    // Player won the boxing match
    // Add your code here
} else if (result == "lose") {
    // Player lost the boxing match
    // Add your code here
}

// Check for test console input
boxing.checkTestConsoleInput(10, 10);

// Draw event
boxing.draw();
boxing.drawTestConsole(10, 10);
*/

