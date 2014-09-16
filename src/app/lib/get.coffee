get = (path, callback) ->
  httpRequest = new XMLHttpRequest()
  httpRequest.onreadystatechange = ->
    if httpRequest.readyState == 4 and httpRequest.status == 200
      callback?(JSON.parse(httpRequest.responseText))
  httpRequest.open('GET', path)
  httpRequest.send()

module.exports = get
