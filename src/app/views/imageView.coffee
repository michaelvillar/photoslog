View = require('view')

class ImageView extends View
  className: 'imageView'

  constructor: ->
    super

    if @options.queue?
      @options.queue.addJob(@load)
    else
      @load()

  load: (done) =>
    @image = new Image
    @image.src = @options.imagePath
    @image.onload = =>
      done?()
      @onLoad()

  onLoad: =>
    @el.style.backgroundImage = "url(#{@options.imagePath})"

module.exports = ImageView
