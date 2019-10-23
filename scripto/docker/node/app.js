function sayHello(name) {
    console.log('Hello ' + name);
}
    
sayHello('Remi');

var http = require('http');
var userCount = 0;
var os = require("os");
var hostname = os.hostname();

var express = require('express');
var app = express();
app.use(express.static(__dirname + '/public'));

app.get('/', (req, res) => {
    console.log('New connection');
    userCount++;
    res.send('<html><head><body>\n<font color="green">GREEN</font><BR>I am running on: '+hostname+'<BR>We have had '+userCount+' visits!<BR><img src="/monty.jpg" alt="monty" height="420"> <BR></body></html></head>\n');
});

app.listen(8080);


console.log('Server started');
