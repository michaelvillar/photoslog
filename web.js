var http = require('http');
var fs = require('fs');
var connect = require('connect');

var files = ["/index.html", "/css/index.css"];

var sendFile = function(filename, res) {
  fs.readFile(filename, "utf8", function(err, file) {
    if(err) {
      res.writeHead(404);
    }
    else {
      var args = filename.split('.');
      var ext = args[args.length - 1];
      if(ext == 'html')
        res.setHeader("Content-Type", "text/html; charset=utf-8");
      else if(ext == 'js')
        res.setHeader("Content-Type", "application/javascript; charset=utf-8");
      else if(ext == 'css')
        res.setHeader("Content-Type", "text/css; charset=utf-8");
      res.writeHead(200);
      res.write(file);
    }
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
