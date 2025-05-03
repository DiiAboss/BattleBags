/// @description Simplified Poker Fish Game
/// A fishing game where players catch fish with card values for poker combos

// Game phases
#macro PHASE_IDLE 0
#macro PHASE_DESCENDING 1
#macro PHASE_ASCENDING 2
#macro PHASE_RESULTS 3

// Card suits
#macro SUIT_HEARTS 0
#macro SUIT_DIAMONDS 1 
#macro SUIT_CLUBS 2
#macro SUIT_SPADES 3

// Card values
#macro VALUE_10 0
#macro VALUE_JACK 1
#macro VALUE_QUEEN 2
#macro VALUE_KING 3
#macro VALUE_ACE 4

/// @description Create a simplified PokerFishGame
/// @param {real} _well_width Width of the fishing well
/// @param {real} _max_depth Maximum fishing depth
/// @param {real} _line_strength Maximum weight line can hold
function PokerFishGame(_well_width, _max_depth, _line_strength) constructor {
    // Core properties
    self.well_width = _well_width;
    self.max_depth = _max_depth;
    self.line_strength = _line_strength;
    
    // Game state
    self.phase = PHASE_IDLE;
    self.current_depth = 0;
    self.hook_x = self.well_width / 2;
    self.score = 0;
    self.line_weight = 0;
    
    // Entities
    self.fish = [];
    self.obstacles = [];
    self.caught_items = [];
    
    // Fish rarity settings by depth
    self.fish_rarity_tiers = [
        { depth: 0, common: 0.9, uncommon: 0.1, rare: 0.0, legendary: 0.0 },
        { depth: 1000, common: 0.7, uncommon: 0.2, rare: 0.1, legendary: 0.0 },
        { depth: 2000, common: 0.5, uncommon: 0.3, rare: 0.15, legendary: 0.05 },
        { depth: 3000, common: 0.3, uncommon: 0.4, rare: 0.2, legendary: 0.1 },
        { depth: 4000, common: 0.1, uncommon: 0.3, rare: 0.4, legendary: 0.2 }
    ];
    
    // Fish properties by value
    self.fish_properties = [
        // VALUE_10
        { size: 1.2, speed: 0.7, weight: 1 },
        // VALUE_JACK
        { size: 1.0, speed: 0.9, weight: 2 },
        // VALUE_QUEEN
        { size: 0.9, speed: 1.2, weight: 3 },
        // VALUE_KING
        { size: 1.1, speed: 1.4, weight: 4 },
        // VALUE_ACE
        { size: 0.7, speed: 1.8, weight: 1 }
    ];
    
    /// @description Initialize or reset the game
    static Initialize = function() {
        self.phase = PHASE_IDLE;
        self.current_depth = 0;
        self.hook_x = self.well_width / 2;
        self.score = 0;
        self.line_weight = 0;
        
        // Clear entities
        self.fish = [];
        self.obstacles = [];
        self.caught_items = [];
        
        // Generate initial entities
        GenerateEntities(0, self.max_depth);
    }
    
    /// @description Start fishing
    static StartFishing = function() {
        self.phase = PHASE_DESCENDING;
        self.current_depth = 0;
    }
    
    /// @description Generate fish and obstacles
    /// @param {real} start_depth Starting depth
    /// @param {real} end_depth Ending depth
    static GenerateEntities = function(_start_depth, _end_depth) {
        var _depth_range = _end_depth - _start_depth;
        var _num_fish = round(_depth_range / 150); // 1 fish per 150 depth units
        var _num_obstacles = round(_depth_range / 300); // 1 obstacle per 300 depth units
        
        // Generate fish
        for (var i = 0; i < _num_fish; i++) {
            var _depth = random_range(_start_depth, _end_depth);
            
            // Determine rarity based on depth
            var _rarity = GetRarityAtDepth(_depth);
            
            // Determine card value based on rarity
            var _suit = irandom(3);
            var _value;
            var _r = random(1.0);
            
            if (_rarity == "legendary") {
                _value = VALUE_ACE;
            } else if (_rarity == "rare") {
                _value = (_r < 0.7) ? VALUE_KING : VALUE_ACE;
            } else if (_rarity == "uncommon") {
                _value = (_r < 0.5) ? VALUE_QUEEN : VALUE_JACK;
            } else {
                _value = VALUE_10;
            }
            
            // Get properties for this fish
            var _props = self.fish_properties[_value];
            
            // Create fish
            var _fish = {
                x: random_range(20, self.well_width - 20),
                y: _depth,
                suit: _suit,
                value: _value,
                rarity: _rarity,
                speed: _props.speed * (0.5 + random(1.0)),
                direction: choose(-1, 1),
                size: _props.size,
                weight: _props.weight,
                is_caught: false
            };
            
            array_push(self.fish, _fish);
        }
        
        // Generate obstacles
        for (var i = 0; i < _num_obstacles; i++) {
            var _depth = random_range(_start_depth, _end_depth);
            var _type = choose("ROCK", "BOOT", "TREASURE", "WILD_CARD", "PREDATOR");
            
            var _obstacle = {
                x: random_range(20, self.well_width - 20),
                y: _depth,
                type: _type,
                is_caught: false
            };
            
            // Set properties based on type
            switch (_type) {
                case "ROCK":
                    _obstacle.weight = 5;
                    _obstacle.multiplier = 1;
                    _obstacle.is_wild = false;
                    break;
                    
                case "BOOT":
                    _obstacle.weight = 3;
                    _obstacle.multiplier = 1;
                    _obstacle.is_wild = false;
                    break;
                    
                case "TREASURE":
                    _obstacle.weight = 8;
                    _obstacle.multiplier = 2;
                    _obstacle.is_wild = false;
                    break;
                    
                case "WILD_CARD":
                    _obstacle.weight = 2;
                    _obstacle.multiplier = 1;
                    _obstacle.is_wild = true;
                    break;
                    
                case "PREDATOR":
                    _obstacle.weight = 3;
                    _obstacle.multiplier = 0.5;
                    _obstacle.is_wild = false;
                    _obstacle.penalty = 200;
                    _obstacle.knock_power = 1 + irandom(2);
                    _obstacle.speed = 1.5 + random(1.0);
                    _obstacle.direction = choose(-1, 1);
                    break;
            }
            
            array_push(self.obstacles, _obstacle);
        }
    }
    
    /// @description Get rarity based on depth
    /// @param {real} depth Current depth
    static GetRarityAtDepth = function(_depth) {
        var _tiers = self.fish_rarity_tiers;
        
        // Find appropriate tier
        var _tier = _tiers[0];
        for (var i = 1; i < array_length(_tiers); i++) {
            if (_depth >= _tiers[i].depth) {
                _tier = _tiers[i];
            } else {
                break;
            }
        }
        
        // Roll for rarity
        var _roll = random(1.0);
        if (_roll < _tier.common) {
            return "common";
        } else if (_roll < _tier.common + _tier.uncommon) {
            return "uncommon";
        } else if (_roll < _tier.common + _tier.uncommon + _tier.rare) {
            return "rare";
        } else {
            return "legendary";
        }
    }
    
    /// @description Update game logic
    /// @param {real} delta_time Time since last frame in seconds
    static Update = function(_delta_time) {
        var _dt = _delta_time / 1000000; // Convert to seconds
        
        switch (self.phase) {
            case PHASE_DESCENDING:
                UpdateDescending(_dt);
                break;
                
            case PHASE_ASCENDING:
                UpdateAscending(_dt);
                break;
                
            case PHASE_RESULTS:
            case PHASE_IDLE:
                // Nothing to update
                break;
        }
    }
    
    /// @description Update descending phase
    /// @param {real} dt Time delta in seconds
    static UpdateDescending = function(_dt) {
        // Move downward
        self.current_depth += 120 * _dt; // 120 units per second
        
        // Update fish positions
        for (var i = 0; i < array_length(self.fish); i++) {
            var _fish = self.fish[i];
            if (!_fish.is_caught) {
                // Simple left-right movement
                _fish.x += _fish.speed * _fish.direction * 60 * _dt;
                
                // Bounce off walls
                if (_fish.x < 20 || _fish.x > self.well_width - 20) {
                    _fish.direction *= -1;
                    _fish.x = clamp(_fish.x, 20, self.well_width - 20);
                }
                
                // Occasionally change direction
                if (random(1.0) < 0.01) {
                    _fish.direction *= -1;
                }
            }
        }
        
        // Update predators
        for (var i = 0; i < array_length(self.obstacles); i++) {
            var _obstacle = self.obstacles[i];
            if (_obstacle.type == "PREDATOR" && !_obstacle.is_caught) {
                // Move predators faster
                _obstacle.x += _obstacle.speed * _obstacle.direction * 60 * _dt;
                
                // Bounce off walls
                if (_obstacle.x < 20 || _obstacle.x > self.well_width - 20) {
                    _obstacle.direction *= -1;
                    _obstacle.x = clamp(_obstacle.x, 20, self.well_width - 20);
                }
                
                // Predators change direction more frequently
                if (random(1.0) < 0.03) {
                    _obstacle.direction *= -1;
                }
            }
        }
        
        // Check for collisions with fish
        for (var i = 0; i < array_length(self.fish); i++) {
            var _fish = self.fish[i];
            if (!_fish.is_caught) {
                var _dist = point_distance(self.hook_x, self.current_depth, _fish.x, _fish.y);
                
                // Size-based collision radius
                var _collision_radius = 20 * _fish.size;
                
                if (_dist < _collision_radius) {
                    // Catch fish
                    _fish.is_caught = true;
                    array_push(self.caught_items, _fish);
                    self.line_weight += _fish.weight;
                    
                    // Switch to ascending
                    self.phase = PHASE_ASCENDING;
                    break;
                }
            }
        }
        
        // Check for collisions with obstacles
        for (var i = 0; i < array_length(self.obstacles); i++) {
            var _obstacle = self.obstacles[i];
            if (!_obstacle.is_caught) {
                var _dist = point_distance(self.hook_x, self.current_depth, _obstacle.x, _obstacle.y);
                
                // Type-based collision radius
                var _collision_radius = 20;
                if (_obstacle.type == "PREDATOR") {
                    _collision_radius = 25;
                } else if (_obstacle.type == "TREASURE" || _obstacle.type == "WILD_CARD") {
                    _collision_radius = 22;
                }
                
                if (_dist < _collision_radius) {
                    // Catch obstacle
                    _obstacle.is_caught = true;
                    array_push(self.caught_items, _obstacle);
                    self.line_weight += _obstacle.weight;
                    
                    // Switch to ascending (unless it's max depth)
                    self.phase = PHASE_ASCENDING;
                    break;
                }
            }
        }
        
        // Check if reached maximum depth
        if (self.current_depth >= self.max_depth) {
            self.phase = PHASE_ASCENDING;
        }
    }
    
    /// @description Update ascending phase
    /// @param {real} dt Time delta in seconds
    static UpdateAscending = function(_dt) {
        // Move upward (faster than descent)
        self.current_depth -= 180 * _dt; // 180 units per second
        
        // Update active fish
        for (var i = 0; i < array_length(self.fish); i++) {
            var _fish = self.fish[i];
            if (!_fish.is_caught) {
                // Simple left-right movement
                _fish.x += _fish.speed * _fish.direction * 60 * _dt;
                
                // Bounce off walls
                if (_fish.x < 20 || _fish.x > self.well_width - 20) {
                    _fish.direction *= -1;
                    _fish.x = clamp(_fish.x, 20, self.well_width - 20);
                }
                
                // Occasionally change direction
                if (random(1.0) < 0.01) {
                    _fish.direction *= -1;
                }
                
                // Check for collision with ascending hook
                var _dist = point_distance(self.hook_x, self.current_depth, _fish.x, _fish.y);
                var _collision_radius = 22 * _fish.size; // Slightly larger on ascent
                
                if (_dist < _collision_radius) {
                    // Catch fish
                    _fish.is_caught = true;
                    // Add some random offset to make the cluster look more natural
                    _fish.caught_offset_x = random_range(-10, 10);
                    _fish.caught_offset_y = random_range(5, 20);
                    array_push(self.caught_items, _fish);
                    self.line_weight += _fish.weight;
                    
                    // Check if line breaks
                    if (self.line_weight > self.line_strength) {
                        LineBroken();
                        return;
                    }
                }
            }
        }
        
        // All caught items follow the hook, but we don't need to calculate
        // exact positions here as they will be positioned during drawing
        // for visual purposes only. We just need to track the hook position.
        // The clustering effect happens in the Draw function.
        
        // Check for predator collisions with caught items
        for (var i = 0; i < array_length(self.obstacles); i++) {
            var _obstacle = self.obstacles[i];
            if (_obstacle.type == "PREDATOR" && !_obstacle.is_caught) {
                // Move predators
                _obstacle.x += _obstacle.speed * _obstacle.direction * 60 * _dt;
                
                // Bounce off walls
                if (_obstacle.x < 20 || _obstacle.x > self.well_width - 20) {
                    _obstacle.direction *= -1;
                    _obstacle.x = clamp(_obstacle.x, 20, self.well_width - 20);
                }
                
                // Check for collision with hook or caught items
                if (array_length(self.caught_items) > 0) {
                    var _dist = point_distance(self.hook_x, self.current_depth, _obstacle.x, _obstacle.y);
                    
                    if (_dist < 40) { // Large radius for predator attack
                        // Predator knocks off fish
                        var _knocked_off = min(_obstacle.knock_power, array_length(self.caught_items));
                        
                        // Remove the last X items
                        for (var j = 0; j < _knocked_off; j++) {
                            if (array_length(self.caught_items) > 0) {
                                var _item = self.caught_items[array_length(self.caught_items) - 1];
                                self.line_weight -= _item.weight;
                                array_resize(self.caught_items, array_length(self.caught_items) - 1);
                            }
                        }
                        
                        // Mark predator as used
                        _obstacle.is_caught = true;
                    }
                }
            }
        }
        
        // Check if reached the surface
        if (self.current_depth <= 0) {
            self.phase = PHASE_RESULTS;
            CalculateResults();
        }
    }
    
    /// @description Handle line breaking
    static LineBroken = function() {
        // Keep only a few items
        var _kept_items = [];
        var _keep_count = max(0, floor(self.line_strength * 0.1));
        
        for (var i = 0; i < min(_keep_count, array_length(self.caught_items)); i++) {
            array_push(_kept_items, self.caught_items[i]);
        }
        
        // Update the caught items
        self.caught_items = _kept_items;
        
        // Recalculate weight
        self.line_weight = 0;
        for (var i = 0; i < array_length(self.caught_items); i++) {
            self.line_weight += self.caught_items[i].weight;
        }
        
        // Continue ascending
        self.phase = PHASE_ASCENDING;
    }
    
    /// @description Move the hook left or right
    /// @param {real} amount Amount to move (-1 to 1)
    static MoveHook = function(_amount) {
        if (self.phase == PHASE_DESCENDING || self.phase == PHASE_ASCENDING) {
            self.hook_x += _amount * 200; // 200 units per second
            self.hook_x = clamp(self.hook_x, 20, self.well_width - 20);
        }
    }
    
    /// @description Calculate final results
    static CalculateResults = function() {
        self.score = 0;
        var _fish_cards = [];
        var _wild_cards = 0;
        var _multiplier = 1;
        var _penalty = 0;
        
        // Count wilds, multipliers, and cards
        for (var i = 0; i < array_length(self.caught_items); i++) {
            var _item = self.caught_items[i];
            
            if (variable_struct_exists(_item, "suit") && variable_struct_exists(_item, "value")) {
                // It's a fish
                array_push(_fish_cards, { suit: _item.suit, value: _item.value });
                
                // Add base score
                var _base_value = (_item.value + 10) * 10; // 10=100, J=110, Q=120, K=130, A=140
                self.score += _base_value;
            } else {
                // It's an obstacle
                if (_item.is_wild) {
                    _wild_cards++;
                }
                
                if (_item.multiplier != 1) {
                    _multiplier *= _item.multiplier;
                }
                
                if (_item.type == "PREDATOR" && variable_struct_exists(_item, "penalty")) {
                    _penalty += _item.penalty;
                }
            }
        }
        
        // Check for poker hands
        var _poker_multiplier = 1;
        var _hand_name = "No Hand";
        
        if (array_length(_fish_cards) + _wild_cards >= 5) {
            if (CheckRoyalFlush(_fish_cards, _wild_cards)) {
                _poker_multiplier = 100;
                _hand_name = "Royal Flush";
            } else if (CheckFourOfAKind(_fish_cards, _wild_cards)) {
                _poker_multiplier = 25;
                _hand_name = "Four of a Kind";
            } else if (CheckFullHouse(_fish_cards, _wild_cards)) {
                _poker_multiplier = 15;
                _hand_name = "Full House";
            } else if (CheckFlush(_fish_cards, _wild_cards)) {
                _poker_multiplier = 10;
                _hand_name = "Flush";
            } else if (CheckThreeOfAKind(_fish_cards, _wild_cards)) {
                _poker_multiplier = 5;
                _hand_name = "Three of a Kind";
            } else if (CheckTwoPair(_fish_cards, _wild_cards)) {
                _poker_multiplier = 3;
                _hand_name = "Two Pair";
            } else if (CheckPair(_fish_cards, _wild_cards)) {
                _poker_multiplier = 2;
                _hand_name = "Pair";
            }
        }
        
        // Apply multipliers and penalties
        self.score *= _poker_multiplier * _multiplier;
        self.score -= _penalty;
        
        // Store for display
        self.best_hand = _hand_name;
        self.poker_multiplier = _poker_multiplier;
        self.item_multiplier = _multiplier;
        self.penalty_score = _penalty;
    }
    
    // Simplified poker hand checking functions
    static CheckRoyalFlush = function(_cards, _wilds) {
        // Count cards by suit
        var _suits = [0, 0, 0, 0];
        for (var i = 0; i < array_length(_cards); i++) {
            _suits[_cards[i].suit]++;
        }
        
        // Find suit with most cards
        var _max_suit = 0;
        var _max_count = _suits[0];
        for (var i = 1; i < 4; i++) {
            if (_suits[i] > _max_count) {
                _max_count = _suits[i];
                _max_suit = i;
            }
        }
        
        // Check for 10-A in this suit (or with wilds)
        var _needed_values = [VALUE_10, VALUE_JACK, VALUE_QUEEN, VALUE_KING, VALUE_ACE];
        var _found = 0;
        
        for (var i = 0; i < array_length(_needed_values); i++) {
            for (var j = 0; j < array_length(_cards); j++) {
                if (_cards[j].suit == _max_suit && _cards[j].value == _needed_values[i]) {
                    _found++;
                    break;
                }
            }
        }
        
        return (_found + _wilds >= 5);
    }
    
    static CheckFourOfAKind = function(_cards, _wilds) {
        // Count by value
        var _values = [0, 0, 0, 0, 0]; // 10, J, Q, K, A
        
        for (var i = 0; i < array_length(_cards); i++) {
            _values[_cards[i].value]++;
        }
        
        // Check for 4+ of any value
        for (var i = 0; i < 5; i++) {
            if (_values[i] + _wilds >= 4) {
                return true;
            }
        }
        
        return false;
    }
    
    static CheckFullHouse = function(_cards, _wilds) {
        // Count by value
        var _values = [0, 0, 0, 0, 0]; // 10, J, Q, K, A
        
        for (var i = 0; i < array_length(_cards); i++) {
            _values[_cards[i].value]++;
        }
        
        // Sort values
        array_sort(_values, function(a, b) { return b - a; }); // Descending
        
        // Need top two values + wilds to be at least 5
        return (_values[0] + _values[1] + _wilds >= 5);
    }
    
    static CheckFlush = function(_cards, _wilds) {
        // Count by suit
        var _suits = [0, 0, 0, 0];
        
        for (var i = 0; i < array_length(_cards); i++) {
            _suits[_cards[i].suit]++;
        }
        
        // Check if any suit has 5+ cards
        for (var i = 0; i < 4; i++) {
            if (_suits[i] + _wilds >= 5) {
                return true;
            }
        }
        
        return false;
    }
    
    static CheckThreeOfAKind = function(_cards, _wilds) {
        // Count by value
        var _values = [0, 0, 0, 0, 0]; // 10, J, Q, K, A
        
        for (var i = 0; i < array_length(_cards); i++) {
            _values[_cards[i].value]++;
        }
        
        // Check for 3+ of any value
        for (var i = 0; i < 5; i++) {
            if (_values[i] + _wilds >= 3) {
                return true;
            }
        }
        
        return false;
    }
    
    static CheckTwoPair = function(_cards, _wilds) {
        // Count by value
        var _values = [0, 0, 0, 0, 0]; // 10, J, Q, K, A
        
        for (var i = 0; i < array_length(_cards); i++) {
            _values[_cards[i].value]++;
        }
        
        // Sort values
        array_sort(_values, function(a, b) { return b - a; }); // Descending
        
        // Need top two values + wilds to be at least 4
        return (_values[0] + _values[1] + _wilds >= 4);
    }
    
    static CheckPair = function(_cards, _wilds) {
        // Count by value
        var _values = [0, 0, 0, 0, 0]; // 10, J, Q, K, A
        
        for (var i = 0; i < array_length(_cards); i++) {
            _values[_cards[i].value]++;
        }
        
        // Check for 2+ of any value
        for (var i = 0; i < 5; i++) {
            if (_values[i] + _wilds >= 2) {
                return true;
            }
        }
        
        return false;
    }
    
/// @description Draw the game - COMPLETELY REWORKED DRAWING SYSTEM
    /// @param {real} view_x X position of view
    /// @param {real} view_y Y position of view
    /// @param {real} view_width Width of view
    /// @param {real} view_height Height of view
    static Draw = function(_view_x, _view_y, _view_width, _view_height) {
        // Calculate game-to-screen transformation constants
        var _game_width = self.well_width;
        var _visible_height = 600; // How much of the well to show at once
        
        // Horizontal scaling - map game width to screen width
        var _scale_x = _view_width / _game_width;
        
        // Vertical position - center the current_depth in the view
        var _visible_top = self.current_depth - _visible_height/2;
        var _visible_bottom = self.current_depth + _visible_height/2;
        
        // Background color based on depth
        var _depth_color = make_color_rgb(
            max(0, 20 - self.current_depth / 1000 * 20),
            max(0, 40 - self.current_depth / 1000 * 30),
            max(20, 80 - self.current_depth / 1000 * 40)
        );
        
        // Draw background
        draw_set_color(_depth_color);
        draw_rectangle(_view_x, _view_y, _view_x + _view_width, _view_y + _view_height, false);
        
        // Draw well walls
        draw_set_color(c_gray);
        draw_line(
            _view_x, _view_y,
            _view_x, _view_y + _view_height
        );
        draw_line(
            _view_x + _view_width, _view_y,
            _view_x + _view_width, _view_y + _view_height
        );
        
        // DRAW FISH
        for (var i = 0; i < array_length(self.fish); i++) {
            var _fish = self.fish[i];
            
            // Skip if caught or not visible
            if (_fish.is_caught || _fish.y < _visible_top || _fish.y > _visible_bottom) {
                continue;
            }
            
            // Draw FISH
            // Calculate screen position directly
            var _screen_x = _view_x + _fish.x * _scale_x;
            var _relative_depth = _fish.y - _visible_top;
            var _screen_height_ratio = _relative_depth / _visible_height;
            var _screen_y = _view_y + _view_height * _screen_height_ratio;
            
            // Use the helper function to draw fish
            DrawSwimmingFish(_fish.x, _fish.y, _screen_x, _screen_y, _fish, _scale_x);
        }
        
        // DRAW OBSTACLES
        for (var i = 0; i < array_length(self.obstacles); i++) {
            var _obstacle = self.obstacles[i];
            
            // Skip if caught or not visible
            if (_obstacle.is_caught || _obstacle.y < _visible_top || _obstacle.y > _visible_bottom) {
                continue;
            }
            
            // Calculate screen position directly
            var _screen_x = _view_x + _obstacle.x * _scale_x;
            var _relative_depth = _obstacle.y - _visible_top;
            var _screen_height_ratio = _relative_depth / _visible_height;
            var _screen_y = _view_y + _view_height * _screen_height_ratio;
            
            // Base size adjusted for screen scale
            var _obs_size = 20 * _scale_x;
            
            // Draw based on type - SIMPLIFIED SHAPES
            switch (_obstacle.type) {
                case "ROCK":
                    draw_set_color(c_gray);
                    draw_circle(_screen_x, _screen_y, _obs_size, false);
                    break;
                    
                case "BOOT":
                    draw_set_color(c_black);
                    draw_rectangle(
                        _screen_x - _obs_size, _screen_y - _obs_size,
                        _screen_x + _obs_size, _screen_y + _obs_size,
                        false
                    );
                    break;
                    
                case "TREASURE":
                    draw_set_color(c_yellow);
                    draw_rectangle(
                        _screen_x - _obs_size, _screen_y - _obs_size/2,
                        _screen_x + _obs_size, _screen_y + _obs_size/2,
                        false
                    );
                    break;
                    
                case "WILD_CARD":
                    draw_set_color(c_fuchsia);
                    draw_rectangle(
                        _screen_x - _obs_size, _screen_y - _obs_size*1.2,
                        _screen_x + _obs_size, _screen_y + _obs_size*1.2,
                        false
                    );
                    
                    draw_set_color(c_white);
                    draw_set_halign(fa_center);
                    draw_set_valign(fa_middle);
                    draw_text(_screen_x, _screen_y, "W");
                    break;
                    
                case "PREDATOR":
                    draw_set_color(c_red);
                    // Triangle for predator
                    draw_triangle(
                        _screen_x - _obs_size, _screen_y - _obs_size,
                        _screen_x - _obs_size, _screen_y + _obs_size,
                        _screen_x + _obs_size, _screen_y,
                        false
                    );
                    break;
            }
        }
        
        // DRAW HOOK AND LINE
        // Hook screen position (always centered vertically in the view)
        var _hook_screen_x = _view_x + self.hook_x * _scale_x;
        var _hook_screen_y = _view_y + _view_height / 2;
        
        // Draw line from top of screen to hook
        draw_set_color(c_white);
        draw_line(
            _hook_screen_x, _view_y, // Top of screen
            _hook_screen_x, _hook_screen_y // Hook position
        );
        
        // Draw hook as simple circle
        var _hook_size = 10 * _scale_x;
        draw_circle(_hook_screen_x, _hook_screen_y, _hook_size, false);
        
        // DRAW CAUGHT ITEMS - STRINGER APPROACH
        // First, draw the fishing line from hook to caught items
        draw_set_color(c_white);
        
        if (array_length(self.caught_items) > 0) {
            // Draw main line going down from hook
            var _stringer_length = min(array_length(self.caught_items) * 15 + 20, 120) * _scale_x;
            draw_line(
                _hook_screen_x, _hook_screen_y,
                _hook_screen_x, _hook_screen_y + _stringer_length
            );
        }
        
        // Loop through caught items
        for (var i = 0; i < array_length(self.caught_items); i++) {
            var _item = self.caught_items[i];
            
            // Calculate position on the stringer
            // All fish hang in a tight vertical column with slight offset
            var _stringer_position = 5 + i * 10; // Base position down the line
            var _side_variance = (i % 2 == 0) ? -1 : 1; // Alternate sides
            
            // Add slight horizontal offset to make it look more natural
            var _side_offset = _side_variance * (10 + (i % 3) * 3) * _scale_x;
            
            // Calculate screen position
            var _screen_x = _hook_screen_x + _side_offset;
            var _screen_y = _hook_screen_y + _stringer_position * _scale_x;
            
            // Only draw if on screen
            if (_screen_y > _view_y && _screen_y < _view_y + _view_height) {
                if (variable_struct_exists(_item, "suit") && variable_struct_exists(_item, "value")) {
                    // It's a fish - draw as fish-shaped oval
                    
                    // Determine color based on suit
                    var _fish_color;
                    switch (_item.suit) {
                        case SUIT_HEARTS: _fish_color = c_red; break;
                        case SUIT_DIAMONDS: _fish_color = c_orange; break;
                        case SUIT_CLUBS: _fish_color = c_lime; break;
                        case SUIT_SPADES: _fish_color = c_navy; break;
                    }
                    
                    // Fish is positioned horizontally and hangs from the line
                    // Unlike when swimming, caught fish are displayed sideways
                    var _base_size = 12 * _scale_x;
                    var _fish_width = _base_size * 2.5 * _item.size; // Longer fish
                    var _fish_height = _fish_width * 0.4; // Proper fish proportion
                    
                    // Draw fish body (horizontal oval)
                    draw_set_color(_fish_color);
                    draw_ellipse(
                        _screen_x - _fish_width/2, _screen_y - _fish_height/2,
                        _screen_x + _fish_width/2, _screen_y + _fish_height/2,
                        false
                    );
                    
                    // Draw small tail fin at right side
                    draw_triangle(
                        _screen_x + _fish_width/2, _screen_y - _fish_height/2,
                        _screen_x + _fish_width/2, _screen_y + _fish_height/2,
                        _screen_x + _fish_width/2 + _fish_height*0.8, _screen_y,
                        false
                    );
                    
                    // Draw small head/eye detail on left side
                    draw_set_color(c_white);
                    draw_circle(
                        _screen_x - _fish_width/2 + _fish_height*0.3,
                        _screen_y - _fish_height*0.2,
                        _fish_height*0.15,
                        false
                    );
                    
                    // Draw value text
                    draw_set_color(c_white);
                    draw_set_halign(fa_center);
                    draw_set_valign(fa_middle);
                    
                    var _value_text;
                    switch (_item.value) {
                        case VALUE_10: _value_text = "10"; break;
                        case VALUE_JACK: _value_text = "J"; break;
                        case VALUE_QUEEN: _value_text = "Q"; break;
                        case VALUE_KING: _value_text = "K"; break;
                        case VALUE_ACE: _value_text = "A"; break;
                    }
                    
                    draw_text(_screen_x, _screen_y, _value_text);
                } else {
                    // Draw based on type - SIMPLIFIED SHAPES
                    var _obs_size = 15 * _scale_x;
                    
                    switch (_item.type) {
                        case "ROCK":
                            draw_set_color(c_gray);
                            draw_circle(_screen_x, _screen_y, _obs_size, false);
                            break;
                            
                        case "BOOT":
                            draw_set_color(c_black);
                            // Boot shape - L-shaped rectangle
                            draw_rectangle(
                                _screen_x - _obs_size, _screen_y - _obs_size/2,
                                _screen_x, _screen_y + _obs_size,
                                false
                            );
                            draw_rectangle(
                                _screen_x - _obs_size*1.5, _screen_y + _obs_size*0.5,
                                _screen_x, _screen_y + _obs_size,
                                false
                            );
                            break;
                            
                        case "TREASURE":
                            draw_set_color(c_yellow);
                            // Treasure chest shape
                            draw_rectangle(
                                _screen_x - _obs_size, _screen_y - _obs_size/2,
                                _screen_x + _obs_size, _screen_y + _obs_size/2,
                                false
                            );
                            // Lid
                            draw_set_color(c_orange);
                            draw_triangle(
                                _screen_x - _obs_size, _screen_y - _obs_size/2,
                                _screen_x + _obs_size, _screen_y - _obs_size/2,
                                _screen_x, _screen_y - _obs_size,
                                false
                            );
                            break;
                            
                        case "WILD_CARD":
                            draw_set_color(c_fuchsia);
                            // Card shape
                            draw_rectangle(
                                _screen_x - _obs_size*0.7, _screen_y - _obs_size,
                                _screen_x + _obs_size*0.7, _screen_y + _obs_size,
                                false
                            );
                            
                            draw_set_color(c_white);
                            draw_set_halign(fa_center);
                            draw_set_valign(fa_middle);
                            draw_text(_screen_x, _screen_y, "W");
                            break;
                            
                        case "PREDATOR":
                            draw_set_color(c_red);
                            // Predator fish shape (more shark-like)
                            // Body
                            draw_ellipse(
                                _screen_x - _obs_size, _screen_y - _obs_size*0.5,
                                _screen_x + _obs_size, _screen_y + _obs_size*0.5,
                                false
                            );
                            // Triangular fin on top
                            draw_triangle(
                                _screen_x - _obs_size*0.3, _screen_y - _obs_size*0.5,
                                _screen_x + _obs_size*0.3, _screen_y - _obs_size*0.5,
                                _screen_x, _screen_y - _obs_size,
                                false
                            );
                            // Tail
                            draw_triangle(
                                _screen_x + _obs_size, _screen_y - _obs_size*0.5,
                                _screen_x + _obs_size, _screen_y + _obs_size*0.5,
                                _screen_x + _obs_size*1.5, _screen_y,
                                false
                            );
                            break;
                    }
                }
                
                // Draw line connecting item to main stringer line
                draw_set_color(c_white);
                draw_line(_hook_screen_x, _screen_y, _screen_x, _screen_y);
            }
        }
        
        // DRAW UI
        DrawUI(_view_x, _view_y, _view_width, _view_height);
        
        // Draw results screen if in results phase
        if (self.phase == PHASE_RESULTS) {
            DrawResults(_view_x, _view_y, _view_width, _view_height);
        }
    }
	
	
	 /// @description Draw fish while swimming
    /// @param {real} fish_x X position
    /// @param {real} fish_y Y position
    /// @param {real} screen_x Screen X position
    /// @param {real} screen_y Screen Y position
    /// @param {struct} fish Fish data
    /// @param {real} scale Scale factor
    static DrawSwimmingFish = function(_fish_x, _fish_y, _screen_x, _screen_y, _fish, _scale) {
        // Determine color based on suit
        var _fish_color;
        switch (_fish.suit) {
            case SUIT_HEARTS: _fish_color = c_red; break;
            case SUIT_DIAMONDS: _fish_color = c_orange; break;
            case SUIT_CLUBS: _fish_color = c_lime; break;
            case SUIT_SPADES: _fish_color = c_navy; break;
        }
        
        // Base size (adjusted for screen scale)
        var _base_size = 15 * _scale;
        var _fish_width = _base_size * 2 * _fish.size;
        var _fish_height = _fish_width * 0.5; // Proper fish proportion
        
        // Direction the fish is facing
        var _dir_sign = (_fish.direction < 0) ? -1 : 1;
        
        // Draw fish body (horizontal oval)
        draw_set_color(_fish_color);
        draw_ellipse(
            _screen_x - _fish_width/2, _screen_y - _fish_height/2,
            _screen_x + _fish_width/2, _screen_y + _fish_height/2,
            false
        );
        
        // Draw tail fin at appropriate side based on direction
        draw_triangle(
            _screen_x + _dir_sign * _fish_width/2, _screen_y - _fish_height/2,
            _screen_x + _dir_sign * _fish_width/2, _screen_y + _fish_height/2,
            _screen_x + _dir_sign * (_fish_width/2 + _fish_height*0.8), _screen_y,
            false
        );
        
        // Draw eye at opposite side from tail
        draw_set_color(c_white);
        draw_circle(
            _screen_x - _dir_sign * (_fish_width/2 - _fish_height*0.3),
            _screen_y - _fish_height*0.2,
            _fish_height*0.15,
            false
        );
        
        // Draw value text
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        var _value_text;
        switch (_fish.value) {
            case VALUE_10: _value_text = "10"; break;
            case VALUE_JACK: _value_text = "J"; break;
            case VALUE_QUEEN: _value_text = "Q"; break;
            case VALUE_KING: _value_text = "K"; break;
            case VALUE_ACE: _value_text = "A"; break;
        }
        
        draw_text(_screen_x, _screen_y, _value_text);
    }
	
	
	
    /// @description Draw UI with game info
    /// @param {real} x X coordinate for drawing
    /// @param {real} y Y coordinate for drawing
    /// @param {real} width Width of view
    /// @param {real} height Height of view
    static DrawUI = function(_x, _y, _width, _height) {
        // UI background
        draw_set_alpha(0.7);
        draw_set_color(c_black);
        draw_rectangle(_x, _y, _x + _width, _y + 60, false);
        draw_set_alpha(1.0);
        
        // Phase information
        var _phase_text;
        var _phase_color;
        
        switch (self.phase) {
            case PHASE_IDLE:
                _phase_text = "Ready to Fish";
                _phase_color = c_white;
                break;
            case PHASE_DESCENDING:
                _phase_text = "Descending...";
                _phase_color = c_aqua;
                break;
            case PHASE_ASCENDING:
                _phase_text = "Ascending!";
                _phase_color = c_lime;
                break;
            case PHASE_RESULTS:
                _phase_text = "Results";
                _phase_color = c_yellow;
                break;
        }
        
        draw_set_halign(fa_center);
        draw_set_color(_phase_color);
        draw_text_transformed(_x + _width / 2, _y + 10, _phase_text, 1.2, 1.2, 0);
        
        // Depth indicator
        draw_set_halign(fa_left);
        draw_set_color(c_white);
        draw_text(_x + 10, _y + 10, "Depth: " + string(round(self.current_depth)) + " / " + string(self.max_depth));
        
        // Line weight
        var _weight_ratio = self.line_weight / self.line_strength;
        var _weight_color = (_weight_ratio < 0.7) ? c_lime : (_weight_ratio < 0.9 ? c_yellow : c_red);
        
        draw_set_color(_weight_color);
        draw_text(_x + 10, _y + 30, "Line: " + string(self.line_weight) + " / " + string(self.line_strength));
        
        // Count caught fish
        var _fish_count = 0;
        for (var i = 0; i < array_length(self.caught_items); i++) {
            var _item = self.caught_items[i];
            if (variable_struct_exists(_item, "suit") && variable_struct_exists(_item, "value")) {
                _fish_count++;
            }
        }
        
        // Show caught fish
        draw_set_color(c_white);
        draw_text(_x + _width / 2, _y + 35, "Fish Caught: " + string(_fish_count));
        
        // Controls reminder
        draw_set_halign(fa_right);
        
        if (self.phase == PHASE_IDLE) {
            draw_text(_x + _width - 10, _y + 20, "Press SPACE to start");
            draw_text(_x + _width - 10, _y + 40, "LEFT/RIGHT to move hook");
        } else if (self.phase == PHASE_DESCENDING || self.phase == PHASE_ASCENDING) {
            draw_text(_x + _width - 10, _y + 30, "LEFT/RIGHT to move hook");
        }
        
        // Reset alignment
        draw_set_halign(fa_left);
    }
    
    /// @description Draw results screen
    /// @param {real} x X coordinate for drawing
    /// @param {real} y Y coordinate for drawing
    /// @param {real} width Width of view
    /// @param {real} height Height of view
    static DrawResults = function(_x, _y, _width, _height) {
        // Semi-transparent background
        draw_set_alpha(0.8);
        draw_set_color(c_black);
        draw_rectangle(_x, _y, _x + _width, _y + _height, false);
        draw_set_alpha(1.0);
        
        // Results title
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_text_transformed(_x + _width / 2, _y + 50, "FISHING RESULTS", 2, 2, 0);
        
        // Score
        draw_set_color(c_yellow);
        draw_text_transformed(_x + _width / 2, _y + 90, "Score: " + string(self.score), 1.5, 1.5, 0);
        
        // Poker hand
        if (self.best_hand != "No Hand") {
            draw_set_color(c_lime);
            draw_text(_x + _width / 2, _y + 130, "Best Hand: " + self.best_hand + " (x" + string(self.poker_multiplier) + ")");
        }
        
        // Item multiplier
        if (self.item_multiplier != 1) {
            draw_set_color(c_orange);
            draw_text(_x + _width / 2, _y + 160, "Item Multiplier: x" + string(self.item_multiplier));
        }
        
        // Penalty
        if (self.penalty_score > 0) {
            draw_set_color(c_red);
            draw_text(_x + _width / 2, _y + 190, "Penalties: -" + string(self.penalty_score));
        }
        
        // List caught items
        draw_set_halign(fa_left);
        draw_set_color(c_white);
        draw_text(_x + 50, _y + 230, "Caught Items:");
        
        var _item_y = _y + 260;
        var _max_items = min(array_length(self.caught_items), 10); // Show up to 10 items
        
        for (var i = 0; i < _max_items; i++) {
            var _item = self.caught_items[i];
            
            if (variable_struct_exists(_item, "suit") && variable_struct_exists(_item, "value")) {
                // It's a fish
                draw_set_color(c_aqua);
                
                var _value_names = ["10", "Jack", "Queen", "King", "Ace"];
                var _suit_names = ["Hearts", "Diamonds", "Clubs", "Spades"];
                
                draw_text(_x + 70, _item_y, _value_names[_item.value] + " of " + _suit_names[_item.suit]);
            } else {
                // It's an obstacle
                draw_set_color(c_gray);
                draw_text(_x + 70, _item_y, _item.type);
            }
            
            _item_y += 25;
        }
        
        // More items indicator
        if (array_length(self.caught_items) > 10) {
            draw_set_color(c_dkgray);
            draw_text(_x + 70, _item_y, "...and " + string(array_length(self.caught_items) - 10) + " more items");
        }
        
        // Restart prompt
        draw_set_halign(fa_center);
        draw_set_color(c_white);
        draw_text_transformed(_x + _width / 2, _y + _height - 40, "Press SPACE to fish again!", 1.3, 1.3, 0);
    }
}

/// @description Simple usage example
/*
// Create in a controller object's Create event:
fishing_game = new PokerFishGame(400, 5000, 25);
fishing_game.Initialize();

// In Step event:
if (keyboard_check_pressed(vk_space)) {
    if (fishing_game.phase == PHASE_IDLE) {
        fishing_game.StartFishing();
    } else if (fishing_game.phase == PHASE_RESULTS) {
        fishing_game.Initialize();
        fishing_game.StartFishing();
    }
}

if (keyboard_check(vk_left)) {
    fishing_game.MoveHook(-1 * delta_time / 1000000);
}

if (keyboard_check(vk_right)) {
    fishing_game.MoveHook(1 * delta_time / 1000000);
}

fishing_game.Update(delta_time);

// In Draw event:
fishing_game.Draw(0, 0, room_width, room_height);
*/