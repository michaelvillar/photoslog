var http = require('http');
var fs = require('fs');
var connect = require('connect');

var files = ["/index.html", "/css/index.css"];

var sendFile = function(filename, res) {
  fs.readFile(filename, "binary", function(err, file) {
    res.writeHead(200);
    res.write(file, "binary");
    res.end();
  });
};

var app = connect();
app.use(function (req, res) {
  if(fs.existsSync("./public/" + req.url))
    sendFile("./public/" + req.url, res);
  else
    sendFile("./public/index.html", res);
});

http.createServer(app).listen(8000);
console.info("Listening on port 8000")
