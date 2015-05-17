View = require('view')
imageLoader = require('imageLoader')

class ImageView extends View
  className: 'imageView'

  constructor: ->
    super

    @disabled = false
    @loaded = false
    @loadObject = null
    @bindEvents()

  bindEvents: =>
    @el.addEventListener('click', @onClick)

  load: (done) =>
    if @options.queue?
      @options.queue.addJob(@_load)
    else
      @_load(done)

  setDisabled: (bool) =>
    return if bool == @disabled
    @disabled = bool
    if bool
      @el.style.backgroundImage = "none"
    else if @loaded
      @apply()

  _load: (done) =>
    @loadObject = imageLoader.get(@options.imagePath)
    @loadObject.on('progress', =>

    )
    @loadObject.on('load', =>
      @loaded = true
      @apply()
      done()
    )

  apply: =>
    @el.style.backgroundImage = "url(#{@loadObject.url})"

  onClick: =>
    @trigger('click', @)

module.exports = ImageView
