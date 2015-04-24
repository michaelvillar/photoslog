Controller = require('controller')
View = require('view')
ImageView = require('imageView')
ratio = require('ratio')

class Fullscreen extends Controller
  constructor: ->
    super

    @view = new View(className: 'fullscreenView')
    @view.css(visibility: 'hidden')

    @backgroundView = new View(className: 'backgroundView')
    @backgroundView.css(opacity: 0)
    @view.addSubview(@backgroundView)

  open: (image, options = {}) =>
    filePath = image.files[ratio]
    imageView = new ImageView(
      className: image.type,
      imagePath: filePath,
      object: image
    )

    if options.view?
      visibleBounds = options.view.visibleBounds()
      imageView.css(
        left: visibleBounds.x,
        top: visibleBounds.y,
        width: options.view.width(),
        height: options.view.height()
      )

    @view.addSubview(imageView)
    @view.css(visibility: 'visible')

    @backgroundView.animate({
      opacity: 0.5
    }, {
      type: dynamics.EaseInOut,
      duration: 200
    })

module.exports = Fullscreen
