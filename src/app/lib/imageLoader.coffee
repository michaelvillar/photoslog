EventDispatcher = require('eventDispatcher')

loads = {}

class Load extends EventDispatcher
  constructor: ->
    super
    @progress = null

  setProgress: (@progress) =>
    @trigger('progress', @)

  setURL: (@url) =>
    @trigger('load', @)

module.exports = {}
module.exports.get = (url) ->
  load = loads[url]
  return load if load?
  loads[url] = load = new Load

  xhr = new XMLHttpRequest()
  xhr.onload = (e) =>
    h = xhr.getAllResponseHeaders()
    m = h.match(/^Content-Type\:\s*(.*?)$/mi)
    mimeType = m[1] || 'image/png';

    blob = new Blob([xhr.response], { type: mimeType })
    load.setURL(window.URL.createObjectURL(blob))

  xhr.onprogress = (e) =>
    if e.lengthComputable
      load.setProgress(parseInt((e.loaded / e.total) * 100))

  xhr.onloadstart = =>
    load.setProgress(0)

  xhr.onloadend = =>
    load.setProgress(100)

  xhr.open('GET', url, true)
  xhr.responseType = 'arraybuffer'
  xhr.send()

  return load
