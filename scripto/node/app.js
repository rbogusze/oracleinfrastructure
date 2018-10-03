function sayHello(name) {
    console.log('Hello ' + name);
}
    
sayHello('Remi');

var http = require('http');
var userCount = 0;
http.createServer(function (request, response) {
    console.log('New connection');
    userCount++;
    response.writeHead(200, {'Content-Type': 'text/plain'});
    response.write('Green\n');
    response.write('Green\n');
    response.write('Green\n');
    response.write('We have had '+userCount+' visits!\n');
    response.end('Hello Node JS World\n');
}).listen(8080);

console.log('Server started');
