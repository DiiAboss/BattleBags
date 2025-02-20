var dgram = require("dgram");

var server = dgram.createSocket("udp4");

var data;
var data_arrived = false;
var hosts = [];
var host_number = 0;

const DATA_TYPE =
{
    CREATE_HOST  : 0,
    JOIN_HOST    : 1,
    STOP_HOST    : 2,
    POSITION     : 3,
    KEY_PRESS    : 4,
    DEBUG        : 5,
    GET_HOSTS    : 6,
    LEAVE_HOST   : 7,
    SEND_PLAYER_STATS : 8,
    START_GAME   : 9,
    SWAP_POSITION: 10,
    GET_PLAYER_STATS : 11,
    GET_NEW_PLAYERS   : 12,
}

function player(player_number, x, y, action_key, left_key, right_key, up_key, down_key) {
    this.player_number = player_number;
    this.x = x;
    this.y = y;
    this.score = 0;
    this.isAlive = true;
    //this.lastUpdate = Date.now();
    this.action_key = action_key;
    this.left_key = left_key; 
    this.right_key = right_key;
    this.up_key = up_key; 
    this.down_key = down_key;
}



server.on("message", function(msg, rinfo) {
    data_arrived = true;
    //console.log("< " + String(msg));
    
    try {
        // Check if message is empty
        if (!msg || msg.length === 0) {
            //console.log("Received empty message");
            return;
        }

        // Try to parse the JSON
        data = JSON.parse(msg);
        
        // Validate that data and type exist
        if (!data || typeof data.type === 'undefined') {
            console.log("Invalid message format");
            return;
        }
    
    switch(data.type)
    {
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

        default:
        break;
    }
    
} catch (error) {
    console.log("Error processing message:", error);
    // Optionally send error back to client
    const errorResponse = {
        error: "Invalid message format",
        details: error.message
    };
    server.send(JSON.stringify(errorResponse), rinfo.port, rinfo.address);
}
});

server.bind(7676);

function send_player_stats(data, rinfo)
{
    hosts[data.host_number][data.player_number].x = data.x;
    hosts[data.host_number][data.player_number].y = data.y;
    hosts[data.host_number][data.player_number].action_key = data.action_key;
    hosts[data.host_number][data.player_number].left_key = data.left_key;
    hosts[data.host_number][data.player_number].up_key = data.up_key;
    hosts[data.host_number][data.player_number].down_key = data.down_key;
    hosts[data.host_number][data.player_number].right_key = data.right_key;
    //server.send(JSON.stringify(data), rinfo.port, rinfo.address);
}

function get_player_stats(data, rinfo)
{
    data.player_stats = hosts[data.host_number][data.player_number];
    console.log(String(data.player_stats));
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
}

function get_players(data, rinfo)
{
    console.log("GETTING PLAYERS");
    data.players = hosts[data.host_number];
   
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
}

function set_player_debug(data, rinfo)
{
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
}

function create_host(data, rinfo)
{
    host_number = hosts.length;
    hosts.push([new player(0, 0, 0, 0, 0, 0, 0, 0)]);

    data.host_number   = host_number;
    data.player_number = 0;

    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    
    console.table(hosts);
}

function stop_host(data, rinfo)
{
    console.log("< Host Stopped");
    var host_to_stop = hosts.indexOf(data.host_number);
    hosts.splice(host_to_stop, 1);
    data.res = "stopped";
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
}

function get_hosts(data, rinfo)
{
    console.log("< GET HOSTS");
    data.hosts = hosts;
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
}

function join_host(data, rinfo)
{
    console.log("< JOIN HOST");
    var number_of_players = hosts[data.host_number].length;
    hosts[data.host_number].push(new player(number_of_players, 0, 0, 0, 0, 0, 0, 0));
    data.player_number = number_of_players;
    //data.host_number =   host_number;
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    console.table(hosts);
}

function leave_host(data, rinfo) {
    console.log(String(data.player_number) + "< LEAVE HOST " + String(data.host_number) );
    
    // Validate host number exists
    if (data.host_number >= hosts.length || !hosts[data.host_number]) {
        console.log("Error: Invalid host number", data.host_number);
        data.error = "Invalid host number";
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
        return;
    }

    var current_host = hosts[data.host_number];
    
    // Validate player number exists
    if (data.player_number >= current_host.length || data.player_number < 0) {
        console.log("Error: Invalid player number", data.player_number);
        data.error = "Invalid player number";
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
        return;
    }

    try {
        // Remove the player
        hosts[data.host_number].splice(data.player_number, 1);
        
        // If no players left in host, remove the host
        if (hosts[data.host_number].length === 0) {
            hosts.splice(data.host_number, 1);
            data.host_removed = true;
        }

        data.success = true;
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
        console.table(hosts);
    } catch (error) {
        console.log("Error during leave_host:", error);
        data.error = "Server error during disconnect";
        server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    }
}

    
    
function start_game(data, rinfo) {
    console.log("< STARTING GAME");
    
    // Get the current host
    var current_host = hosts[data.host_number];
    
    // Check if there are enough players (at least 2)
    if (current_host.length < 2) {
        console.log("Not enough players to start game");
        return;
    }

    // Set game started flag in data
    data.game_started = true;
    
    // Send start game message back to all clients
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    
    console.log("Game started for host:", data.host_number);
    console.table(hosts);
}

