var express = require('express');
var app = express();
app.use(express.static(__dirname + '/public'));
app.listen(8000);
console.info("Listening on port 8000")
