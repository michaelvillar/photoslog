EventDispatcher = require('eventDispatcher')
require('dynamics.js')

dynamicViews = null
dynamicObj = null
obj = null

restore = (y) ->
  for view in dynamicViews
    view.css(translateY: 0, translateZ: 0)
  window.scrollTo(0, y)
  document.body.style.height = "auto"
  scroll.scrolling = false
  dynamicObj = null

scroll = new EventDispatcher

scroll.value =
  x: 0
  y: 0

scroll.scrolling = false

window.addEventListener('scroll', ->
  if dynamicObj?
    dynamicObj.stop()
    restore(obj.y)
  scroll.value =
    x: window.scrollX
    y: window.scrollY
  scroll.trigger('change')
)

scroll.to = (options = {}) ->
  if dynamicObj?
    dynamicObj.stop()
    dynamicObj = null

  scroll.scrolling = true
  body = document.body
  html = document.documentElement

  bodyHeight = Math.max(body.scrollHeight, body.offsetHeight,
                        html.clientHeight, html.scrollHeight, html.offsetHeight)
  document.body.style.height = bodyHeight + "px"

  # Max scroll value
  options.y = Math.min(options.y, bodyHeight - window.innerHeight)

  obj = { y: scroll.value.y }
  initial = window.scrollY
  dynamicViews = options.views.map (view) -> dynamic(view.el)
  dynamicObj = dynamic(obj)
  dynamicObj.to({
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
      restore(obj.y)
  }).start()

module.exports = scroll
