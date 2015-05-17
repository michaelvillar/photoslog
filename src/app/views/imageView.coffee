View = require('view')

class ImageView extends View
  className: 'imageView'

  constructor: ->
    super

    @disabled = false
    @loaded = false
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
      @onLoad()

  _load: (done) =>
    @image = new Image
    @image.src = @options.imagePath
    @image.onload = =>
      @onLoad()
      done?()

  onLoad: =>
    @loaded = true
    @el.style.backgroundImage = "url(#{@options.imagePath})"
    @el.classList.add('loaded')

  onClick: =>
    @trigger('click', @)

module.exports = ImageView
