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

    @imageView?.css(
      zIndex: 9
    )

    @imageView = new ImageView(
      imagePath: config.imagesRootPath + filePath,
      object: image
    )

    @originalView = options.view

    props = @scaleAndTranslate(@view, @originalView)
    props.left = 0
    props.top = 0
    props.width = @view.width()
    props.height = @view.height()
    props.transformOrigin = "0 0"

    @imageView.css(props)

    @applyProgress(@imageView)

    @loading = true
    @imageView.load =>
      @loading = false
      @trigger('progress', 0)
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
        scaleX: 1,
        scaleY: 1,
        translateX: 0,
        translateY: 0
      }, springOptions)

      window.addEventListener('resize', @layout)
      window.addEventListener('keydown', @onKeyDown)

  slide: (image, options={}) =>
    return if @hidden
    return if @loading

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

    @applyProgress(@imageView)
    @loading = true
    @imageView.load =>
      @loading = false
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
    @imageView.css(translateX: 0)
    @imageView.animate({
      translateX: -direction * 100
    }, {
      type: dynamics.bounce,
      frequency: 200,
      friction: 200,
      duration: 700
    })

  layout: =>
    @imageView.css({
      width: @view.width(),
      height: @view.height()
    })

  close: =>
    return if @hidden
    window.removeEventListener('resize', @layout)
    window.removeEventListener('keydown', @onKeyDown)
    @hidden = true
    @loading = false

    originalView = @originalView

    props = @scaleAndTranslate(@view, @originalView)

    body = new View(el: document.body)
    @imageView.el.classList.add('mainImageView')
    body.addSubview(@imageView)
    @imageView.css({
      top: scroll.value.y
    })

    imageView = @imageView
    @imageView.animate(props, tools.merge(springOptions, {
      complete: =>
        if @hidden || originalView != @originalView
          originalView.css(visibility: 'visible')
        imageView.removeFromSuperview()
        if @hidden
          @view.css(visibility: 'hidden')
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

  applyProgress: (imageView) =>
    imageView.on 'progress', (progress) =>
      @trigger('progress', progress)

  scaleAndTranslate: (viewA, viewB) =>
    frame = viewB.screenFrame()

    ratioOriginal = frame.width / frame.height
    ratioView = viewA.width() / viewA.height()
    scale = 0

    translateX = frame.x
    translateY = frame.y

    if ratioOriginal > ratioView
      scale = frame.width / viewA.width()
      translateY += (frame.height / scale - viewA.height()) / 2 * scale
    else
      scale = frame.height / viewA.height()
      translateX += (frame.width / scale - viewA.width()) / 2 * scale

    {
      translateX: translateX,
      translateY: translateY,
      scaleX: scale,
      scaleY: scale,
    }

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
