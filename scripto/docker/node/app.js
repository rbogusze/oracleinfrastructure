function sayHello(name) {
    console.log('Hello ' + name);
}
    
sayHello('Remi');

var http = require('http');
var userCount = 0;
var os = require("os");
var hostname = os.hostname();
http.createServer(function (request, response) {
    console.log('New connection');
    userCount++;
    response.write('<html><head><body>\n');
    response.write('<font color="red">RED</font><BR>');
    response.write('I am running on: '+hostname+'<BR>');
    response.write('We have had '+userCount+' visits!\n');
    response.write('</body></html></head>\n');
    response.end();
}).listen(8080);

console.log('Server started');
