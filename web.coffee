express = require('express')
app = express()

app.use(express.static(__dirname + '/public'))
app.get('*', (req, res) ->
  res.render('index', {
    title: process.env.PAGE_TITLE ? "Photos Log",
    imagesRootPath: process.env.IMAGES_ROOT_PATH ? "/data/"
  })
)

# Handlebars
expressHbs = require('express-handlebars')
app.engine('hbs', expressHbs({extname:'hbs', defaultLayout:'main.hbs'}))
app.set('view engine', 'hbs')

port = process.env.PORT || 8000
app.listen(port)
console.info("Listening on port " + port)
