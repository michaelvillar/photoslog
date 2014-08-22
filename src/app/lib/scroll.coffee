EventDispatcher = require('eventDispatcher')
require('dynamics.js')

scroll = new EventDispatcher

scroll.value =
  x: 0
  y: 0

scroll.scrolling = false

window.addEventListener('scroll', ->
  scroll.value =
    x: window.scrollX
    y: window.scrollY
  scroll.trigger('change')
)

scroll.to = (options = {}) ->
  scroll.scrolling = true
  body = document.body
  html = document.documentElement

  bodyHeight = Math.max(body.scrollHeight, body.offsetHeight,
                        html.clientHeight, html.scrollHeight, html.offsetHeight)
  document.body.style.height = bodyHeight + "px"

  # Max scroll value
  options.y = Math.min(options.y, bodyHeight - window.innerHeight)

  obj = { y: scroll.value.y }
  initial = obj.y
  dynamicViews = options.views.map (view) -> dynamic(view.el)
  dynamic(obj).to({
    y: options.y
  }, {
    type: dynamic.Spring,
    frequency: 9,
    friction: 350,
    anticipationStrength: 82,
    anticipationSize: 34,
    duration: 1000,
    change: ->
      for view in dynamicViews
        view.css(translateY: - obj.y + initial, translateZ: 0)
      scroll.value =
        x: scroll.value.x
        y: obj.y
      scroll.trigger('change', obj.y)
    complete: ->
      for view in dynamicViews
        view.css(translateY: 0, translateZ: 0)
      window.scrollTo(0, obj.y)
      document.body.style.height = "auto"
      scroll.scrolling = false
  }).start()

module.exports = scroll
