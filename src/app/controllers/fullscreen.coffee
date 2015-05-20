Controller = require('controller')
View = require('view')
ImageView = require('imageView')
ratio = require('ratio')
config = require('config')
scroll = require('scroll')
dynamics = require('dynamics')
tools = require('tools')

springOptions = {
  type: dynamics.spring,
  frequency: 200,
  friction: 500,
  anticipationStrength: 0,
  anticipationSize: 0,
  duration: 1000
}

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
    @hidden = true

  open: (image, options = {}) =>
    return unless @hidden
    @hidden = false
    @image = image
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
      @originalView.css(visibility: 'hidden')
      @view.css(visibility: 'visible')

      @backgroundView.animate({
        opacity: 1
      }, {
        type: dynamics.easeInOut,
        duration: 200
      })

      @imageView.animate({
        left: 0,
        top: 0,
        width: @view.width(),
        height: @view.height()
      }, springOptions)

      window.addEventListener('resize', @layout)
      window.addEventListener('keydown', @onKeyDown)

  slide: (image, options={}) =>
    return if @hidden

    oldImageView = @imageView

    @image = image
    filePath = image.files[ratio]
    @originalView?.css(visibility: 'visible')
    @originalView = options.view
    @imageView = imageView = new ImageView(
      imagePath: config.imagesRootPath + filePath,
      object: image
    )
    @imageView.css({
      left: 0,
      top: 0,
      width: @view.width(),
      height: @view.height(),
      translateX: options.direction * @view.width()
    })
    @imageView.load =>
      oldImageView.animate({
        translateX: -options.direction * @view.width()
      }, tools.merge(springOptions, {
        complete: =>
          oldImageView.removeFromSuperview()
      }))
      @view.addSubview(imageView)
      options.view.css(visibility: 'hidden')
      imageView.animate({
        translateX: 0
      }, springOptions)

  bounce: (direction) =>
    @imageView.animate({
      translateX: -direction * 50
    }, {
      type: dynamics.easeInOut,
      duration: 100,
      complete: =>
        @imageView.animate({
         translateX: 0
        }, springOptions)
    })

  layout: =>
    @imageView.css({
      width: @view.width(),
      height: @view.height()
    })

  close: =>
    window.removeEventListener('resize', @layout)
    window.removeEventListener('keydown', @onKeyDown)

    frame = @originalView.screenFrame()
    originalView = @originalView

    body = new View(el: document.body)
    @imageView.el.classList.add('mainImageView')
    body.addSubview(@imageView)
    @imageView.css({
      top: scroll.value.y
    })

    imageView = @imageView
    @imageView.animate({
      left: frame.x,
      top: scroll.value.y + frame.y,
      width: frame.width,
      height: frame.height
    }, tools.merge(springOptions, {
      complete: =>
        originalView.css(visibility: 'visible')
        imageView.removeFromSuperview()
        @view.css(visibility: 'hidden')
        @hidden = true
    }))

    @backgroundView.animate({
      opacity: 0
    }, {
      type: dynamics.easeInOut,
      duration: 200
    })

  previous: =>
    return if @time and @time > Date.now() - 200
    @time = Date.now()
    o = @delegate?.previousImage(@image)
    if o?
      o.options.direction = -1
      @slide(o.image, o.options)
    else
      @bounce(-1)

  next: =>
    return if @time and @time > Date.now() - 200
    @time = Date.now()
    o = @delegate?.nextImage(@image)
    if o?
      o.options.direction = 1
      @slide(o.image, o.options)
    else
      @bounce(1)

  # Events
  onClick: =>
    @close()

  onKeyDown: (e) =>
    if e.keyCode == 27 or e.keyCode == 32
      @close()
      e.preventDefault()
      e.stopPropagation()
    else if e.keyCode == 39 or e.keyCode == 40
      @next()
      e.preventDefault()
      e.stopPropagation()
    else if e.keyCode == 37 or e.keyCode == 38
      @previous()
      e.preventDefault()
      e.stopPropagation()

module.exports = Fullscreen
