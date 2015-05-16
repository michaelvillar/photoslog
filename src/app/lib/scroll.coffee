EventDispatcher = require('eventDispatcher')

views = []
animating = false
animationOptions = {}
obj = null

restore = (y) ->
  for view in views
    view.css(translateY: 0, translateZ: 0)
  window.scrollTo(0, y)
  document.body.style.height = "auto"
  scroll.scrolling = false
  objAnimation = null

scroll = new EventDispatcher

scroll.delta =
  x: 0
  y: 0

scroll.value =
  x: 0
  y: 0

scroll.scrolling = false

window.addEventListener('scroll', ->
  if animating
    dynamics.stop(obj)
    restore(obj.y)
    animating = false
    animationOptions.complete?()
    animationOptions = {}
  oldValue = scroll.value
  scroll.value =
    x: window.scrollX
    y: window.scrollY
  scroll.delta =
    x: scroll.value.x - oldValue.x
    y: scroll.value.y - oldValue.y
  scroll.trigger('change')
)

scroll.to = (options = {}) ->
  if animating
    dynamics.stop(obj)
    animating = false

  scroll.scrolling = true
  body = document.body
  html = document.documentElement

  bodyHeight = Math.max(body.scrollHeight, body.offsetHeight,
                        html.clientHeight, html.scrollHeight, html.offsetHeight)
  document.body.style.height = bodyHeight + "px"

  # Max scroll value
  options.y = Math.min(options.y, bodyHeight - window.innerHeight)

  initial = window.scrollY
  views = options.views

  obj = { y: scroll.value.y }
  animating = true
  animationOptions = options
  dynamics(obj, {
    y: options.y
  }, {
    type: dynamics.Spring,
    frequency: 10,
    friction: Math.min(900, 500 + Math.abs(options.y - scroll.value.y) / 10),
    anticipationStrength: 0,
    anticipationSize: 0,
    duration: 1000,
    change: ->
      return unless scroll.scrolling
      for view in views
        view.css({ translateY: - obj.y + initial, translateZ: 0 })
      scroll.value =
        x: scroll.value.x
        y: obj.y
      scroll.trigger('change', obj.y)
    complete: ->
      return unless scroll.scrolling
      options.complete?()
      restore(obj.y)
  })

module.exports = scroll
