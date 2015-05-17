View = require('view')

class ImageView extends View
  className: 'imageView'

  constructor: ->
    super

    @bindEvents()

  bindEvents: =>
    @el.addEventListener('click', @onClick)

  load: (done) =>
    if @options.queue?
      @options.queue.addJob(@_load)
    else
      @_load(done)

  _load: (done) =>
    @image = new Image
    @image.src = @options.imagePath
    @image.onload = =>
      @onLoad()
      done?()

  onLoad: =>
    @el.style.backgroundImage = "url(#{@options.imagePath})"
    @el.classList.add('loaded')

  onClick: =>
    @trigger('click', @)

module.exports = ImageView
