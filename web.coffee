request = require('request')
express = require('express')

port = process.env.PORT || 8000
representativeImage = null

app = express()

app.use(express.static(__dirname + '/public'))
app.get('*', (req, res) ->
  root = process.env.IMAGES_ROOT_PATH ? "/data/"
  if representativeImage?
    representativeImagePath = root + representativeImage.files["1x"]
  res.render('index', {
    title: process.env.PAGE_TITLE ? "Photos Log",
    imagesRootPath: root,
    representativeImagePath: representativeImagePath
  })
)

# Handlebars
expressHbs = require('express-handlebars')
app.engine('hbs', expressHbs({extname:'hbs', defaultLayout:'main.hbs'}))
app.set('view engine', 'hbs')

app.listen(port)
console.info("Listening on port " + port)

# Load info.json
request.get (process.env.IMAGES_ROOT_PATH ? "http://localhost:#{port}/data/") + "info.json", (error, response, body) ->
  if !error && response.statusCode == 200
    data = JSON.parse(body)
    groups = data.groups
    lastGroup = groups[groups.length - 1]
    representativeImage = lastGroup.images[0]
