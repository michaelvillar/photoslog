require('dynamics.js')

scroll = {}

scroll.to = (y) ->
  obj = { y: window.scrollY }
  dynamic(obj).to({
    y: y
  }, {
    type: dynamic.Spring,
    frequency: 9,
    friction: 248,
    anticipationStrength: 82,
    anticipationSize: 34,
    duration: 1000,
    change: ->
      window.scrollTo(0, obj.y)
  }).start()

scroll.to(1000)

module.exports = scroll
