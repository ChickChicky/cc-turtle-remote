const websocket = require('websocket');
const fs = require('fs');
var WebSocketServer = websocket.server;
const http = require('http');

let connections = fs.existsSync('computers.json') ? JSON.parse(fs.readFileSync('./computers.json')) : {};

function generateID() {
    return String(Math.round(Math.random()*1e3)).padEnd(3,'0');
}

function log(message) {
    console.log(`${new Date().toUTCString()} - ${message}`);
}

let server = http.createServer(function(request, response) {
    response.write(fs.readFileSync('./main.html','utf-8'));
    //response.setDefaultEncoding('utf-8')
    //response.writeHead(200);
    response.end();
});
server.listen(8080, 'localhost' , function() {
    console.log(`${new Date().toUTCString()} - Listening on port 8080`)
});

let wsServer = new WebSocketServer({
    httpServer: server,
    autoAcceptConnections: true
});

function isConnectionAllowed(origin) {
    return true;
}

wsServer.on('request', function(request) {
    console.log(request);
    request.reject();
});

function sleep(ms) {
    return new Promise((resolve)=>setTimeout(resolve,ms));
}

wsServer.on('connect', function(connection) {

    log(`Connection by ${connection.remoteAddress} using protocol ${connection.protocol}`);

    if (connection.protocol=='remote') {
        let attachedTurtle;
        connection.on('message',async function(rawData) {
            let data = JSON.parse(rawData.utf8Data);
            if (data.type == 'attachTurtle') {
                attachedTurtle = data.turtle;
                log(`remote control client ${connection.remoteAddress} attached to turtle ${attachedTurtle}`);
            } else
            if (data.type == 'eval') {
                if (connections[attachedTurtle].evalQueue.length < 1 && !data.bypassQueueSize) {
                    connections[attachedTurtle].evalQueue.push(data.func);
                }
            }
        });
        let loop = setInterval(()=>{
            if (attachedTurtle) {
                connection.send(JSON.stringify({
                    type: 'turtleStatusUpdate',
                    ...connections[attachedTurtle].envData
                }));
            }
        },100);

    } else
    if (connection.protocol == 'turtle') {
        let peerID;
        let sessionData = {evalQueue:[],env:{}};
        
        connection.on('message',async function(rawData) {
            let data = JSON.parse(rawData.utf8Data);

            //console.log(data.type);
    
            if (!peerID) {
                if (data.type=='connect') {
                    if (!data.id) {
                        peerID = generateID();
                        await sleep(100);
                        connection.send(JSON.stringify({id:peerID}));
                        log(`New peer connected, assigning id ${peerID}`)
                    } else {
                        peerID = data.id;
                        let resp;
                        if (Object.keys(connections).includes(peerID)) {
                            resp = {id:peerID,newId:false};
                            log(`${connection.remoteAddress} identified as ${peerID}`);
                            sessionData = connections[peerID];
                        } else {
                            peerID = generateID();
                            resp = {id:peerID,newId:true};
                            log(`${connection.remoteAddress} identified with invalid id, assigning ${peerID}`)
                        }
                        connection.send(JSON.stringify(resp))
                    }
                    connections[peerID] = sessionData
                } else {
                    log(`Unindentified peer ${connection.remoteAddress} sending some data, closing connection`);
                    connection.close()
                }
            }
    
            if (data.type == 'ready') {
                await sleep(100);
                if (data.action == 'eval') {
                    connection.send(JSON.stringify({
                        func: sessionData.evalQueue.pop()??''
                    }));
                }
            } else

            if (data.type == 'status_update') {
                await sleep(100);
                sessionData.envData = data.env;
            } else
    
            {
    
            }
        });

        connection.on('close', function(code,desc) {
            delete connection[peerID];
            log(`Connection with ${connection.remoteAddress} (${peerID}) closed with code ${code} (${desc})`);
        });
    }
});

process.on('SIGINT', ()=>{
    fs.writeFileSync('./computers.json',JSON.stringify(connections));
    process.exit();
});