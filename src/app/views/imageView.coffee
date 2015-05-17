View = require('view')

class ImageView extends View
  className: 'imageView'

  constructor: ->
    super

    @disabled = false
    @loaded = false
    @blob = null
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
    xhr = new XMLHttpRequest()
    xhr.onload = (e) =>
      h = xhr.getAllResponseHeaders()
      m = h.match(/^Content-Type\:\s*(.*?)$/mi)
      mimeType = m[1] || 'image/png';

      blob = new Blob([xhr.response], { type: mimeType })
      @blob = window.URL.createObjectURL(blob)
      @onLoad()
      done()

    xhr.onprogress = (e) =>
      if e.lengthComputable
        @setProgress(parseInt((e.loaded / e.total) * 100))

    xhr.onloadstart = =>
      @setProgress(0)

    xhr.onloadend = =>
      @setProgress(100)

    xhr.open('GET', @options.imagePath, true)
    xhr.responseType = 'arraybuffer'
    xhr.send()

  setProgress: (progress) =>

  onLoad: =>
    @loaded = true
    @el.style.backgroundImage = "url(#{@blob})"

  onClick: =>
    @trigger('click', @)

module.exports = ImageView
