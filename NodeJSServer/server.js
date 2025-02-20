var dgram = require("dgram");

var server = dgram.createSocket("udp4");
var server2 = dgram.createSocket("udp4");
var data;

server.on("message", function(msg, rinfo)
{
    
    data = JSON.parse(msg);
    console.log("X: " + String(data.x));
    console.log("Y: " + String(data.y));
    console.log("ID: " + String(data.id));
    

});

server2.on("message", function(msg, rinfo)
{
    
    data = JSON.parse(msg);

    server2.send(JSON.stringify(data), rinfo.port, rinfo.address);


});

server.bind(7676);
server.bind(7677);