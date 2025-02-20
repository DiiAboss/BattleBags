var dgram = require("dgram");


var server = dgram.createSocket("udp4");
//var server2 = dgram.createSocket("udp4");
var data;
var data_arrived = false;
var hosts = [];

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
    PLAYER_STATS : 8,
}

function player(player_number, x, y) {
    this.x = x;
    this.y = y;
    this.player_number = this.player_number;
}


server.on("message", function(msg, rinfo)
{
    data_arrived = true;
    console.log("< " + String(msg));
    data = JSON.parse(msg);
    
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
        case DATA_TYPE.PLAYER_STATS:
            join_host(data, rinfo);
        break;
        default:
        break;
    }
    

});

/*
server2.on("message", function(msg, rinfo)
{
    if (data_arrived)
    {
        server2.send(JSON.stringify(data), rinfo.port, rinfo.address);
    }
    
});
*/

server.bind(7676);
//server2.bind(7676);



function set_player_debug(data, rinfo)
{
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    //server2.send(JSON.stringify(data), rinfo.port, rinfo.address);
}

function create_host(data, rinfo)
{
    var host_number = hosts.length;
    hosts.push([new player(0, 0, 0)]);

    data.host_number   = host_number;
    data.player_number = 0;

    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    //server2.send(JSON.stringify(data), rinfo.port, rinfo.address);
    
    console.table(hosts);
}

function stop_host(data, rinfo)
{
    console.log("< Host Stopped");
    var host_to_stop = hosts.indexOf(data.host_number);
    hosts.splice(host_to_stop, 1);
    data.res = "stopped";
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    //server2.send(JSON.stringify(data), rinfo.port, rinfo.address);
}

function get_hosts(data, rinfo)
{
    console.log("< GET HOSTS");
    data.hosts = hosts;
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    //server2.send(JSON.stringify(data), rinfo.port, rinfo.address);
}

function join_host(data, rinfo)
{
    console.log("< JOIN HOST");
    var number_of_players = hosts[data.host_number].length;
    hosts[data.host_number].push(new player(number_of_players, 0, 0));
    data.player_number = number_of_players;
    data.host_number;
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    console.table(hosts);
    //server2.send(JSON.stringify(data), rinfo.port, rinfo.address);
}

function leave_host(data, rinfo)
{
    console.log("< LEAVE HOST");
    var _hosts = hosts[data.host_number];
    console.log("hosts[data.host_number]" + String(_hosts));
    var player_to_disconnect = data.player_number;
    console.log("player_to_disconnect" + String(player_to_disconnect));
    hosts[data.host_number].splice(player_to_disconnect, 1);
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    console.table(hosts);
    //server2.send(JSON.stringify(data), rinfo.port, rinfo.address);
}