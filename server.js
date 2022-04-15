/*
Websocket based Chat Server
Before you can run this app first execute:
>npm install ecstatic
Then launch this server:
>node app.js

Then open several browsers to: http://localhost:3000/index.html
*/

const http = require('http') //needed to receive http requests
const ecStatic = require('ecstatic')  //provides convenient static file server service
const WebSocketServer = require('ws').Server //provides web sockets

//static file server based on npm module ecstatic
var server = http.createServer(ecStatic({root: __dirname + '/www'}))

var wss = new WebSocketServer({server: server});
wss.on('connection', function(ws){
  console.log('Client connected');
  ws.on('message', function(msg){
    console.log('Message: ' + msg);
    broadcast(msg);
  });
  ws.send('Connected to Server');
});

function broadcast(msg){
  //send msg to all connected client sockets
  wss.clients.forEach(function(client){
    client.send(msg);
  });

}

server.listen(3000) //Server listening on port 3000
console.log('Server listening on port 3000.  CNTL-C to quit')
console.log('To Test: open several browsers to: http://localhost:3000/index.html')
