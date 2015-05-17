Controller = require('controller')
View = require('view')
ImageView = require('imageView')
ratio = require('ratio')
config = require('config')

class Fullscreen extends Controller
  constructor: ->
    super

    @view = new View(className: 'fullscreenView')
    @view.css(visibility: 'hidden')
    @view.el.addEventListener('click', @onClick)

    @backgroundView = new View(className: 'backgroundView')
    @backgroundView.css(opacity: 0)
    @view.addSubview(@backgroundView)

    @imageView = null
    @originalView = null

  open: (image, options = {}) =>
    filePath = image.files[ratio]
    @imageView = new ImageView(
      imagePath: config.imagesRootPath + filePath,
      object: image
    )

    @originalView = options.view
    frame = @originalView.screenFrame()
    @imageView.css(
      left: frame.x,
      top: frame.y,
      width: frame.width,
      height: frame.height,
      scaleX: 1,
      scaleY: 1
    )

    @imageView.load =>
      @view.addSubview(@imageView)
      @view.css(visibility: 'visible')

      @backgroundView.animate({
        opacity: 1
      }, {
        type: dynamics.EaseInOut,
        duration: 200
      })

      @imageView.animate({
        left: 0,
        top: 0,
        width: @view.width(),
        height: @view.height()
      }, {
        type: dynamics.Spring,
        frequency: 10,
        friction: 500,
        anticipationStrength: 0,
        anticipationSize: 0,
        duration: 1000,
      })

  # Events
  onClick: =>
    frame = @originalView.screenFrame()
    @imageView.animate({
      left: frame.x,
      top: frame.y,
      width: frame.width,
      height: frame.height
    }, {
      type: dynamics.EaseInOut,
      duration: 400,
      complete: =>
        @imageView.removeFromSuperview()
        @view.css(visibility: 'hidden')
    })

    @backgroundView.animate({
      opacity: 0
    }, {
      type: dynamics.EaseInOut,
      duration: 200
    })

module.exports = Fullscreen
