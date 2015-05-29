View = require('view')
SVGView = require('svgView')
imageLoader = require('imageLoader')
roundf = require('tools').roundf
dynamics = require('dynamics')

class ImageView extends View
  className: 'imageView'

  constructor: ->
    super

    @disabled = false
    @willLoad = false
    @loaded = false
    @loadObject = null
    @bindEvents()

    if @options.loadingIndicator
      @cover = new View(className: 'cover')
      @cover.css(visibility: 'hidden')
      @addSubview(@cover)
      @hiddenCover = true

  bindEvents: =>
    @el.addEventListener('click', @onClick)

  load: (done) =>
    return if @willLoad or @loaded
    @willLoad = true
    if @options.queue?
      @options.queue.addJob(@loadJob, {
        cancelled: =>
          @willLoad = false
      })
    else
      @loadJob(done)

  setDisabled: (bool) =>
    return if bool == @disabled
    @disabled = bool
    if bool
      @el.style.backgroundImage = "none"
    else if @loaded
      @apply()

  showCover: =>
    return unless @cover?
    if @hiddenCover
      @cover.css(visibility: 'visible')
      @hiddenCover = false

  setLoadingProgress: (progress) =>
    return unless @options.loadingIndicator
    return if @loaded

    if progress < 100
      frame = @loadingIndicatorFrame(progress)
      @el.style.webkitClipPath = @insetFromFrame(frame)
      @showCover()

  loadingIndicatorFrame: (progress) =>
    frame = {}
    frame.width = progress / 100 * @width() * 0.3
    frame.height = 2
    frame.x = Math.round((@width() - frame.width) / 2)
    frame.y = Math.round((@height() - frame.height) / 2)
    frame

  insetFromFrame: (frame) =>
    "inset(#{roundf(frame.y, 2)}px #{roundf(frame.x, 2)}px #{roundf(@height() - frame.y - frame.height, 2)}px #{roundf(@width() - frame.x - frame.width, 2)}px)"

  show: (done) =>
    return unless @options.loadingIndicator

    frame = @loadingIndicatorFrame(100)

    if @visibleBounds()?
      @el.style.webkitClipPath = @insetFromFrame(frame)
      @showCover()

      cover = @cover
      frame.opacity = 1
      dynamics.animate(frame, {
        x: 0,
        y: 0
        width: @width(),
        height: @height(),
        opacity: 0
      }, {
        type: dynamics.easeInOut
        duration: 1000,
        friction: 200,
        change: =>
          @el.style.webkitClipPath = @insetFromFrame(frame)
          cover.css(opacity: frame.opacity)
        complete: =>
          cover.removeFromSuperview()
          done()
      })
    else
      @cover.removeFromSuperview()
      @el.style.webkitClipPath = 'none'
      done()
    @cover = null

  loadJob: (done) =>
    @loadObject = imageLoader.get(@options.imagePath)
    @loadObject.on('progress', =>
      @setLoadingProgress(@loadObject.progress)
    )
    @loadObject.on('load', =>
      @onLoad()
      done()
    )

    if @loadObject.url
      @onLoad()
      done()

  apply: =>
    @el.style.backgroundImage = "url(#{@loadObject.url})"

  onClick: =>
    @trigger('click', @)

  onLoad: =>
    @setLoadingProgress(100)
    @loaded = true
    @apply()
    @show =>
      @el.classList.add('loaded')

module.exports = ImageView
