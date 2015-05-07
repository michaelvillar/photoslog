var express = require('express');
var app = express();
app.use(express.static(__dirname + '/public'));
app.get('*', function(req, res) {
  res.render('index', {
    title: process.env.PAGE_TITLE || "Photos Log",
    imagesRootPath: process.env.IMAGES_ROOT_PATH || "/data/"
  })
})

// Handlebars
var expressHbs = require('express-handlebars');
app.engine('hbs', expressHbs({extname:'hbs', defaultLayout:'main.hbs'}));
app.set('view engine', 'hbs');

var port = process.env.PORT || 8000;
app.listen(port);
console.info("Listening on port " + port);
