var dgram = require("dgram");

const DATA_TYPE =
{
    CREATE_HOST : 0,
    JOIN_HOST   : 1,
    STOP_HOST   : 2,
    POSITION    : 3,
    KEY_PRESS   : 4,
    DEBUG       : 5,
}

var server = dgram.createSocket("udp4");
var server2 = dgram.createSocket("udp4");
var data;
var data_arrived = false;

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
        
        default:
        break;
    }
    

});

server2.on("message", function(msg, rinfo)
{
    if (data_arrived)
    {
        server2.send(JSON.stringify(data), rinfo.port, rinfo.address);
    }
    
});

server.bind(8080);
server2.bind(8081);



function set_player_debug(data, rinfo)
{
    server.send(JSON.stringify(data), rinfo.port, rinfo.address);
    server2.send(JSON.stringify(data), rinfo.port, rinfo.address);
}