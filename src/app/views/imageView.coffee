View = require('view')

class ImageView extends View
  className: 'imageView'

  constructor: ->
    super

    @bindEvents()

  bindEvents: =>
    @el.addEventListener('click', @onClick)

  load: =>
    if @options.queue?
      @options.queue.addJob(@_load)
    else
      @_load()

  _load: (done) =>
    @image = new Image
    @image.src = @options.imagePath
    @image.onload = =>
      done?()
      @onLoad()

  onLoad: =>
    @el.style.backgroundImage = "url(#{@options.imagePath})"

  onClick: =>
    @trigger('click', @)

module.exports = ImageView
