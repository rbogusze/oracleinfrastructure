var http = require('http');
var url = require('url');

http.createServer(function (request, response) {
    response.writeHead(200, {'Content-Type': 'text/plain'});

    if( url.parse(request.url).pathname == '/wait' ){
        var startTime = new Date().getTime();
        while (new Date().getTime() < startTime + 15000);
        response.write('Thanks for waiting!');
    }
    else{
        response.write('Hello!');
    }

    response.end();
}).listen(8080);

console.log('Server started');
