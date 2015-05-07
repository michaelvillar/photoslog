var express = require('express');
var app = express();
app.use(express.static(__dirname + '/public'));
app.get('*', function(req, res) {
  res.sendFile(__dirname + '/public/index.html', {}, function (err) {
    if (err) {
      res.status(err.status).end();
    }
  });
})
var port = process.env.PORT || 8000;
app.listen(port);
console.info("Listening on port " + port);
