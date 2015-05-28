EventDispatcher = require('eventDispatcher')
scroll = require('scroll')
dynamics = require('dynamics')

clone = (obj) ->
  JSON.parse(JSON.stringify(obj))

getOffset = (el, property) ->
  value = 0
  while el?
    value += el[property]
    el = el.offsetParent
  value

convertCoordinateToScreen = (coordinates) ->
  obj = clone(coordinates)
  obj.x = coordinates.x - scroll.value.x
  obj.y = coordinates.y - scroll.value.y
  obj

getWindowSize = do ->
  size = {}
  gen = ->
    size =
      width: window.innerWidth
      height: window.innerHeight
  gen()
  window.addEventListener('resize', gen)
  -> size

getRectsIntersection = (a, b) ->
  x = Math.max(a.x, b.x);
  num1 = Math.min(a.x + a.width, b.x + b.width);
  y = Math.max(a.y, b.y);
  num2 = Math.min(a.y + a.height, b.y + b.height);
  if num1 >= x and num2 >= y
    return { x: x, y: y, width: num1 - x, height: num2 - y }
  null

getValueAndCache = (prop, fn) ->
  return @cachedFrameValues[prop] if @cachedFrameValues[prop]?
  value = fn()
  @cachedFrameValues[prop] = value if @cacheFrame
  value

class View extends EventDispatcher
  tag: 'div'

  constructor: (@options = {}) ->
    super
    @el = @el or @options.el or (
      if @xmlns? then document.createElementNS(@xmlns, @options['tag'] || @tag)
      else document.createElement(@options['tag'] || @tag)
    )

    for className in [@className, @options.className]
      for c in (className ? '').split(' ')
        @el.classList.add(c) if c != ''

    @subviews = []

    @cacheFrame = false
    @cachedFrameValues = {}

    @render?()
    @bindEvents?()
    @layout?()

  addSubview: (subview) =>
    @el.appendChild(subview.el)
    subview.setSuperview(@)
    @subviews.push(subview)

  addSubviews: (subviews = []) =>
    for subview in subviews
      @addSubview(subview)

  setSuperview: (superview) =>
    @superview = superview
    if @el.parentNode?
      @triggerToSubviews('addedToDOM')

  removeFromSuperview: =>
    @superview.el.removeChild(@el)
    @superview = null
    @triggerToSubviews('removedFromDOM')

  text: (text) =>
    @el.innerHTML = text

  invalidateCachedFrame: =>
    @cachedFrameValues = {}

  height: =>
    getValueAndCache.call(@, 'height', => @el.clientHeight)

  width: =>
    getValueAndCache.call(@, 'width', => @el.clientWidth)

  x: =>
    getValueAndCache.call(@, 'x', => getOffset(@el, 'offsetLeft'))

  y: =>
    getValueAndCache.call(@, 'y', => getOffset(@el, 'offsetTop'))

  position: =>
    x: @x()
    y: @y()

  size: =>
    width: @width()
    height: @height()

  frame: =>
    x: @x()
    y: @y()
    width: @width()
    height: @height()

  screenFrame: =>
    convertCoordinateToScreen(@frame())

  visibleBounds: =>
    windowFrame = getWindowSize()
    windowFrame.x = 0
    windowFrame.y = 0
    getRectsIntersection(@screenFrame(), windowFrame)

  isVisible: =>
    style = window.getComputedStyle(@el)
    style.display != 'none' and style.visibility != 'hidden'

  css: =>
    args = Array.prototype.slice.call(arguments)
    dynamics.css.apply(dynamics, [@el].concat(args))

  animate: =>
    args = Array.prototype.slice.call(arguments)
    dynamics.animate.apply(dynamics, [@el].concat(args))

module.exports = View
