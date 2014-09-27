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
app.listen(8000);
console.info("Listening on port 8000")
