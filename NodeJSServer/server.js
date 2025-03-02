/**
 * Multiplayer Match-3 Game Server
 * 
 * This server handles UDP messaging for a match-3 game, supporting:
 * - Lobby creation and management
 * - Player connection/disconnection
 * - Game state synchronization
 * - Matchmaking for ranked games
 */

// =====================================================================
// SERVER INITIALIZATION
// =====================================================================
const dgram = require("dgram");
const server = dgram.createSocket("udp4");
const PORT = 7676;

// Message types for client-server communication
const DATA_TYPE = {
    CREATE_HOST: 0,       // Create a new game host/lobby
    JOIN_HOST: 1,         // Join an existing host/lobby
    STOP_HOST: 2,         // Stop/remove a host
    POSITION: 3,          // Update player position
    KEY_PRESS: 4,         // Player input
    DEBUG: 5,             // Debug message
    GET_HOSTS: 6,         // Request list of available hosts
    LEAVE_HOST: 7,        // Leave a host
    SEND_PLAYER_STATS: 8, // Send player statistics
    START_GAME: 9,        // Start the game
    SWAP_POSITION: 10,    // Swap pieces on the board
    GET_PLAYER_STATS: 11, // Request player statistics
    GET_NEW_PLAYERS: 12,  // Request new players that joined
    HEARTBEAT: 13,        // Connection heartbeat
    CREATE_LOBBY: 14,     // Create a named lobby with settings
    FIND_MATCH: 15,       // Request matchmaking for ranked play
};

// Initialize server data
let data;                 // Temporary storage for incoming message data
let data_arrived = false; // Flag for message receipt
let hosts = [];           // Legacy array for game hosts
let host_number = 0;      // Counter for host IDs

// =====================================================================
// IMPROVED DATA STRUCTURES
// =====================================================================

/**
 * Player object constructor
 * Represents a connected player with their state and input information
 */
function Player(player_number, x = 0, y = 0, action_key = false, left_key = false, 
                right_key = false, up_key = false, down_key = false) {
    this.player_number = player_number;
    this.x = x;
    this.y = y;
    this.score = 0;
    this.isAlive = true;
    this.lastUpdate = Date.now();
    this.action_key = action_key;
    this.left_key = left_key; 
    this.right_key = right_key;
    this.up_key = up_key; 
    this.down_key = down_key;
    this.clientInfo = null; // Will store client address/port for direct messaging
}

/**
 * Advanced lobby system - stores information about each game room
 * Enables more sophisticated game management than the simple hosts array
 */
let lobbies = {
    // Structure example:
    // "lobby123": {
    //     name: "Fun Match-3 Room",
    //     maxPlayers: 8,
    //     players: [Player objects],
    //     status: "waiting", // waiting, playing, ended
    //     settings: { difficulty: "normal", timeLimit: 300 },
    //     createdAt: timestamp
    // }
};

/**
 * Rating system for ranked matchmaking
 * Tracks player performance for skill-based matching
 */
let playerRatings = {
    // Structure example:
    // "player123": {
    //     rating: 1200,     // ELO-style rating
    //     matches: 0,       // Total matches played
    //     wins: 0,          // Total wins
    //     lastActive: timestamp
    // }
};

/**
 * Queue of players waiting for ranked matches
 */
let matchmakingQueue = [];

// =====================================================================
// CONNECTION MANAGEMENT
// =====================================================================

/**
 * Connection heartbeat system
 * Tracks client connections and handles timeouts
 */
const HEARTBEAT_INTERVAL = 3000; // Check every 3 seconds
const CLIENT_TIMEOUT = 10000;    // Disconnect after 10 seconds of inactivity

// Track last heartbeat from each client
let clientHeartbeats = {}; // {clientId: timestamp}

// Client ID generator (combines IP and port)
function generateClientId(rinfo) {
    return `${rinfo.address}:${rinfo.port}`;
}

// Update client heartbeat timestamp
function updateClientHeartbeat(rinfo) {
    const clientId = generateClientId(rinfo);
    clientHeartbeats[clientId] = Date.now();
}

// Check for timed-out clients
function checkClientTimeouts() {
    const now = Date.now();
    
    // Check each client's last heartbeat
    for (let clientId in clientHeartbeats) {
        if (now - clientHeartbeats[clientId] > CLIENT_TIMEOUT) {
            console.log(`Client ${clientId} timed out`);
            handleDisconnect(clientId);
        }
    }
}

// Handle client disconnection
function handleDisconnect(clientId) {
    // Remove client from heartbeat tracking
    delete clientHeartbeats[clientId];
    
    // Find and remove client from all hosts/lobbies
    // This is simplified - you'd need to actually find which host/lobby they're in
    console.log(`Client ${clientId} disconnected`);
    
    // TODO: Implement proper cleanup of disconnected players from hosts and lobbies
}

// Initialize heartbeat checking interval
setInterval(checkClientTimeouts, HEARTBEAT_INTERVAL);

// =====================================================================
// MESSAGE HANDLING
// =====================================================================

// Handle incoming UDP messages
server.on("message", function(msg, rinfo) {
    try {
        // Update client heartbeat
        updateClientHeartbeat(rinfo);
        
        // Check if message is empty
        if (!msg || msg.length === 0) {
            return;
        }

        // Parse the JSON message
        data = JSON.parse(msg);
        
        // Validate message structure
        if (!data || typeof data.type === 'undefined') {
            console.log("Invalid message format");
            return;
        }
    
        // Process message based on type
        switch(data.type) {
            case DATA_TYPE.DEBUG:
                set_player_debug(data, rinfo);
                break;
            case DATA_TYPE.CREATE_HOST:
                create_host(data, rinfo);
                break;
            case DATA_TYPE.STOP_HOST:
                stop_host(data, rinfo);
                break;
            case DATA_TYPE.GET_HOSTS:
                get_hosts(data, rinfo);
                break;
            case DATA_TYPE.JOIN_HOST:
                join_host(data, rinfo);
                break;
            case DATA_TYPE.LEAVE_HOST:
                leave_host(data, rinfo);
                break;
            case DATA_TYPE.SEND_PLAYER_STATS:
                send_player_stats(data, rinfo);
                break;
            case DATA_TYPE.GET_PLAYER_STATS:
                get_player_stats(data, rinfo);
                break;
            case DATA_TYPE.START_GAME:
                start_game(data, rinfo);
                break;
            case DATA_TYPE.GET_NEW_PLAYERS:
                get_players(data, rinfo);
                break;
            case DATA_TYPE.HEARTBEAT:
                // Just update the heartbeat timestamp, already done above
                break;
            case DATA_TYPE.CREATE_LOBBY:
                createLobby(data, rinfo);
                break;
            case DATA_TYPE.FIND_MATCH:
                findMatch(data, rinfo);
                break;
            default:
                console.log(`Unknown message type: ${data.type}`);
                break;
        }
    } catch (error) {
        console.log("Error processing message:", error);
        
        // Send error response to client
        const errorResponse = {
            error: "Invalid message format",
            details: error.message
        };
        server.send(JSON.stringify(errorResponse), rinfo.port, rinfo.address);
    }
});

// Start listening on specified port
server.bind(PORT);
console.log(`Match-3 Game Server running on port ${PORT}`);

// =====================================================================
// GAME FUNCTIONS - PLAYER STATE
// =====================================================================

/**
 * Update a player's state based on client message
 */
function send_player_stats(data, rinfo) {
    console.log("STATS RECEIVED");
    
    // Validate host and player exist
    if (!hosts[data.host_number] || !hosts[data.host_number][data.player_number]) {
        console.log("Invalid host or player for stats update");
        return;
    }
    
    // Update player state with new values
    const player = hosts[data.host_number][data.player_number];
    player.x = data.x;
    player.y = data.y;
    player.action_key = data.action_key;
    player.left_key = data.left_key;
    player.up_key = data.up_key;
    player.down_key = data.down_key;
    player.right_key = data.right_key;
    player.lastUpdate = Date.now();
    
    // No response needed for stat updates to reduce bandwidth
}

/**
 * Send a player's state to the requesting client
 */
function get_player_stats(data, rinfo) {
    console.log("STATS SENT");
    
    // Validate host and player exist
    if (!hosts[data.host_number] || !hosts[data.host_number][data.player_number]) {
        console.log("Invalid host or player for stats request");
        data.error = "Invalid host or player";
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
        return;
    }
    
    // Add player stats to response
    data.player_stats = hosts[data.host_number][data.player_number];
    console.log(String(JSON.stringify(data.player_stats)));
    
    // Send stats back to client
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
}

/**
 * Get the number of players in a host
 */
function get_players(data, rinfo) {
    console.log("GETTING PLAYERS");
    
    // Validate host exists
    if (!hosts[data.host_number]) {
        console.log("Invalid host for player count request");
        data.error = "Invalid host";
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
        return;
    }
    
    // Add player count to response
    data.players = hosts[data.host_number].length;
    
    // Send player count back to client
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
}

/**
 * Send debug information back to client
 */
function set_player_debug(data, rinfo) {
    // Echo back the debug data
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
}

// =====================================================================
// GAME FUNCTIONS - HOST MANAGEMENT
// =====================================================================

/**
 * Create a new host (game room)
 */
function create_host(data, rinfo) {
    console.log("CREATING HOST");
    
    // Get new host number
    host_number = hosts.length;
    
    // First player is always player 0
    var pn = 0;

    // Create new host with initial player
    hosts.push([new Player(pn, 0, 0, 0, 0, 0, 0, 0)]);
    
    // Store client info for direct communication
    hosts[host_number][pn].clientInfo = {
        address: rinfo.address,
        port: rinfo.port
    };

    // Prepare response data
    data.host_number = host_number;
    data.player_number = pn;
    data.is_host = true;

    // Send confirmation to client
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    
    // Debug output
    console.table(hosts);
}

/**
 * Stop and remove a host
 */
function stop_host(data, rinfo) {
    console.log("< Host Stopped");
    
    // Validate host exists
    if (!hosts[data.host_number]) {
        console.log("Invalid host to stop");
        data.error = "Invalid host";
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
        return;
    }
    
    // Remove host from array
    var host_to_stop = data.host_number;
    hosts.splice(host_to_stop, 1);
    
    // Prepare response
    data.res = "stopped";
    
    // Send confirmation to client
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
}

/**
 * Get list of available hosts
 */
function get_hosts(data, rinfo) {
    console.log("< GET HOSTS");
    
    // Add hosts to response
    data.hosts = hosts;
    
    // Send host list to client
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
}

/**
 * Join an existing host
 */
function join_host(data, rinfo) {
    console.log("< JOIN HOST");
    
    // Validate host exists
    if (!hosts[data.host_number]) {
        console.log("Invalid host to join");
        data.error = "Invalid host";
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
        return;
    }
    
    // Get player number (next available slot)
    var number_of_players = hosts[data.host_number].length;
    
    // Add player to host
    hosts[data.host_number].push(new Player(number_of_players, 0, 0, 0, 0, 0, 0, 0));
    
    // Store client info
    hosts[data.host_number][number_of_players].clientInfo = {
        address: rinfo.address,
        port: rinfo.port
    };
    
    // Prepare response
    data.player_number = number_of_players;
    
    // Send confirmation to client
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    
    // Debug output
    console.table(hosts);
}

/**
 * Leave a host
 */
function leave_host(data, rinfo) {
    console.log(`${data.player_number} < LEAVE HOST ${data.host_number}`);
    
    // Validate host exists
    if (data.host_number >= hosts.length || !hosts[data.host_number]) {
        console.log("Error: Invalid host number", data.host_number);
        data.error = "Invalid host number";
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
        return;
    }

    var current_host = hosts[data.host_number];
    
    // Validate player exists
    if (data.player_number >= current_host.length || data.player_number < 0) {
        console.log("Error: Invalid player number", data.player_number);
        data.error = "Invalid player number";
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
        return;
    }

    try {
        // Remove player from host
        hosts[data.host_number].splice(data.player_number, 1);
        
        // If host is empty, remove it
        if (hosts[data.host_number].length === 0) {
            hosts.splice(data.host_number, 1);
            data.host_removed = true;
        }

        // Prepare response
        data.success = true;
        
        // Send confirmation to client
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
        
        // Debug output
        console.table(hosts);
    } catch (error) {
        console.log("Error during leave_host:", error);
        data.error = "Server error during disconnect";
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    }
}

/**
 * Start a game
 */
function start_game(data, rinfo) {
    console.log("< STARTING GAME");

    // Validate host exists and has players
    if (!hosts[data.host_number]) {
        console.log("Invalid host to start game");
        data.error = "Invalid host";
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
        return;
    }

    var current_host = hosts[data.host_number];

    if (current_host.length < 1) {
        console.log("No players in the host to start the game");
        data.error = "No players in host";
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
        return;
    }

    // Prepare response
    data.game_started = true;

    // Send game start notification to all players
    // TODO: This should notify all players in the host, not just the requester
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    
    console.log("Game started for host:", data.host_number);
    console.table(hosts);
}

// =====================================================================
// ADVANCED FEATURES - LOBBIES AND MATCHMAKING
// =====================================================================

/**
 * Generate a unique lobby ID
 */
function generateUniqueLobbyId() {
    // Create a random alphanumeric ID
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let id = '';
    
    // Generate 8-character ID
    for (let i = 0; i < 8; i++) {
        id += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    
    // Ensure ID is unique
    if (lobbies[id]) {
        return generateUniqueLobbyId(); // Try again if ID exists
    }
    
    return id;
}

/**
 * Create a new lobby with custom settings
 */
function createLobby(data, rinfo) {
    console.log("CREATING LOBBY");
    
    // Generate unique lobby ID
    const lobbyId = generateUniqueLobbyId();
    
    // Create initial player
    const initialPlayer = new Player(0, 0, 0, 0, 0, 0, 0, 0);
    initialPlayer.clientInfo = {
        address: rinfo.address,
        port: rinfo.port
    };
    
    // Create lobby with settings
    lobbies[lobbyId] = {
        name: data.lobbyName || `Game ${lobbyId}`,
        maxPlayers: data.maxPlayers || 8,
        players: [initialPlayer],
        status: "waiting",
        settings: data.settings || {},
        createdAt: Date.now()
    };
    
    // Prepare response with lobby info
    data.lobbyId = lobbyId;
    data.playerNumber = 0;
    data.success = true;
    
    // Send confirmation to client
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    
    console.log(`Created lobby ${lobbyId}: ${lobbies[lobbyId].name}`);
}

/**
 * Get all currently waiting players for matchmaking
 */
function getWaitingPlayers() {
    return matchmakingQueue;
}

/**
 * Add player to matchmaking queue
 */
function addToWaitingQueue(playerId, rating, rinfo) {
    // Add player to queue with timestamp
    matchmakingQueue.push({
        id: playerId,
        rating: rating,
        joinedAt: Date.now(),
        clientInfo: {
            address: rinfo.address,
            port: rinfo.port
        }
    });
    
    console.log(`Player ${playerId} added to matchmaking queue`);
}

/**
 * Create a ranked game between matched players
 */
function createRankedGame(player1Id, player2Id) {
    // Generate unique lobby ID
    const lobbyId = generateUniqueLobbyId();
    
    // Get player info
    const player1 = matchmakingQueue.find(p => p.id === player1Id);
    const player2 = matchmakingQueue.find(p => p.id === player2Id);
    
    // Remove players from queue
    matchmakingQueue = matchmakingQueue.filter(p => 
        p.id !== player1Id && p.id !== player2Id);
    
    // Create player objects
    const player1Obj = new Player(0, 0, 0, 0, 0, 0, 0, 0);
    player1Obj.clientInfo = player1.clientInfo;
    
    const player2Obj = new Player(1, 0, 0, 0, 0, 0, 0, 0);
    player2Obj.clientInfo = player2.clientInfo;
    
    // Create ranked lobby
    lobbies[lobbyId] = {
        name: `Ranked Match`,
        maxPlayers: 2,
        players: [player1Obj, player2Obj],
        status: "waiting",
        settings: {
            isRanked: true,
            player1Rating: player1.rating,
            player2Rating: player2.rating
        },
        createdAt: Date.now()
    };
    
    // Notify both players
    const matchData = {
        type: DATA_TYPE.JOIN_HOST, // Reuse existing message type
        lobbyId: lobbyId,
        isRanked: true
    };
    
    // Send to player 1
    matchData.playerNumber = 0;
    server.send(JSON.stringify(matchData), 
        player1.clientInfo.port, player1.clientInfo.address);
    
    // Send to player 2
    matchData.playerNumber = 1;
    server.send(JSON.stringify(matchData), 
        player2.clientInfo.port, player2.clientInfo.address);
    
    console.log(`Created ranked match ${lobbyId} between ${player1Id} and ${player2Id}`);
}

/**
 * Find a match for a player based on rating
 */
function findMatch(data, rinfo) {
    const playerId = data.playerId;
    const rating = data.rating || 1200; // Default rating if not provided
    
    console.log(`Finding match for player ${playerId} with rating ${rating}`);
    
    // Find players with similar ratings waiting for a match
    const matchRange = 100; // Rating range to search within
    const waitingPlayers = getWaitingPlayers();
    
    // Filter for players within rating range
    const potentialMatches = waitingPlayers.filter(p => 
        Math.abs(p.rating - rating) <= matchRange);
    
    if (potentialMatches.length > 0) {
        // Match found, create a game with these players
        const matchedPlayer = potentialMatches[0];
        createRankedGame(playerId, matchedPlayer.id);
        
        // Send match found response
        data.success = true;
        data.matchFound = true;
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    } else {
        // Add to waiting queue
        addToWaitingQueue(playerId, rating, rinfo);
        
        // Send waiting response
        data.success = true;
        data.matchFound = false;
        data.inQueue = true;
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    }
}

// =====================================================================
// PLAYER GROUP MANAGEMENT
// =====================================================================

/**
 * Split players into manageable chunks for network updates
 */
function getPlayersInRoom(roomId) {
    // Validate lobby exists
    if (!lobbies[roomId]) {
        console.log(`Invalid lobby ID: ${roomId}`);
        return [];
    }
    
    // Get all players
    const allPlayers = lobbies[roomId].players;
    const playerChunks = [];
    
    // Group players into chunks of 10 for efficient updates
    for (let i = 0; i < allPlayers.length; i += 10) {
        playerChunks.push(allPlayers.slice(i, i + 10));
    }
    
    return playerChunks;
}

/**
 * Get players that are relevant to the given player
 * This is useful for large games where updates can be filtered
 * to only players that need to see each other
 */
function getRelevantPlayers(roomId, playerIndex) {
    // Validate lobby exists
    if (!lobbies[roomId]) {
        console.log(`Invalid lobby ID: ${roomId}`);
        return [];
    }
    
    const allPlayers = lobbies[roomId].players;
    
    // For a match-3 game, relevant players might be:
    // 1. Direct competitors (e.g., players sending garbage blocks)
    // 2. Players within view (for spectator mode)
    
    // Simple implementation - for small games, all players are relevant
    if (allPlayers.length <= 8) {
        return allPlayers;
    }
    
    // For larger games, you might implement more sophisticated filtering:
    // 1. Players directly competing with this player
    // 2. Players nearby in ranking
    // 3. Players in the same bracket of a tournament
    
    // This is a simplified example:
    const playerGroups = Math.ceil(allPlayers.length / 4);
    const playerGroup = Math.floor(playerIndex / 4);
    
    // Get players in the same group and adjacent groups
    const relevantPlayers = [];
    for (let i = 0; i < allPlayers.length; i++) {
        const group = Math.floor(i / 4);
        if (Math.abs(group - playerGroup) <= 1) {
            relevantPlayers.push(allPlayers[i]);
        }
    }
    
    return relevantPlayers;
}

/**
 * Send update to only relevant players instead of everyone
 */
function broadcastPlayerUpdate(roomId, playerIndex, playerData) {
    // Validate lobby exists
    if (!lobbies[roomId]) {
        console.log(`Invalid lobby ID: ${roomId}`);
        return;
    }
    
    // Get players that need this update
    const relevantPlayers = getRelevantPlayers(roomId, playerIndex);
    
    // Send update to each relevant player
    relevantPlayers.forEach(player => {
        if (player.clientInfo) {
            server.send(JSON.stringify(playerData), 
                player.clientInfo.port, player.clientInfo.address);
        }
    });
}

// =====================================================================
// VALIDATION FUNCTIONS
// =====================================================================

/**
 * Validate player action in a lobby
 */
function validatePlayerAction(data, rinfo) {
    // Verify lobby exists
    if (!data.lobbyId || !lobbies[data.lobbyId]) {
        return { valid: false, error: "Lobby not found" };
    }
    
    const lobby = lobbies[data.lobbyId];
    
    // Verify player is in lobby
    const playerIndex = lobby.players.findIndex(p => 
        p.player_number === data.playerNumber);
    
    if (playerIndex === -1) {
        return { valid: false, error: "Player not in lobby" };
    }
    
    // Verify client matches stored client info
    const player = lobby.players[playerIndex];
    if (player.clientInfo && 
        (player.clientInfo.address !== rinfo.address || 
         player.clientInfo.port !== rinfo.port)) {
        return { valid: false, error: "Client mismatch" };
    }
    
    // Verify action is allowed based on game state
    if (data.requiresGameInProgress && lobby.status !== "playing") {
        return { valid: false, error: "Game not in progress" };
    }
    
    return { valid: true };
}

// Log server start
console.log("Match-3 Game Server started");

